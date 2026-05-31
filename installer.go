package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"runtime"
)

const (
	ghUser     = "your-github-username"
	ghRepo     = "USBian"
	releaseTag = "v1.0"
	numBlocks  = 42
)

func main() {
	fmt.Println("==========================================================")
	fmt.Println("    USBian: UNIVERSAL DEBIAN PERSISTENCE USB INSTALLER")
	fmt.Println("==========================================================")

	if runtime.GOOS != "windows" {
		fmt.Println("[ERROR] This specific version is for Windows. Use the .sh for Linux.")
		return
	}

	// 1. Download Blocks
	fmt.Println("[TASK] Downloading blocks from GitHub...")
	os.Mkdir("tmp_blocks", 0755)
	for i := 0; i < numBlocks; i++ {
		blockName := fmt.Sprintf("debian_part_%02d", i)
		url := fmt.Sprintf("https://github.com/%s/%s/releases/download/%s/%s", ghUser, ghRepo, releaseTag, blockName)
		fmt.Printf("   -> Downloading %s...\n", blockName)
		if err := downloadFile("tmp_blocks/"+blockName, url); err != nil {
			fmt.Printf("[ERROR] Failed to download %s: %v\n", blockName, err)
			return
		}
	}

	// 2. Reassemble
	fmt.Println("[TASK] Reassembling image...")
	outFile, _ := os.Create("USBian_Restore.img.gz")
	for i := 0; i < numBlocks; i++ {
		blockName := fmt.Sprintf("debian_part_%02d", i)
		inFile, _ := os.Open("tmp_blocks/" + blockName)
		io.Copy(outFile, inFile)
		inFile.Close()
	}
	outFile.Close()

	fmt.Println("[SUCCESS] Image reassembled as USBian_Restore.img.gz")
	fmt.Println("[INFO] To flash this image on Windows, please use a tool like Rufus or BalenaEtcher.")
	fmt.Println("Press Enter to exit...")
	fmt.Scanln()
}

func downloadFile(filepath string, url string) error {
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	out, err := os.Create(filepath)
	if err != nil {
		return err
	}
	defer out.Close()
	_, err = io.Copy(out, resp.Body)
	return err
}
