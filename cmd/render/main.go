package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"

	"github.com/keshsad/monorepo/apps/rishi/cmd/web/pages"
)

func renderStaticFiles() {
	// ensure dist/ exists
	if err := os.MkdirAll("dist", 0755); err != nil {
		panic(err)
	}

	// map of routes to page components
	pagesToRender := map[string]func(context.Context, *os.File) error{
		"index.html": func(ctx context.Context, w *os.File) error {
			return pages.Home().Render(ctx, w)
		},
		// add more routes here
	}

	ctx := context.Background()
	for filename, renderFunc := range pagesToRender {
		outPath := filepath.Join("dist", filename)
		f, err := os.Create(outPath)
		if err != nil {
			fmt.Printf("Failed to create %s: %v\n", outPath, err)
			continue
		}
		defer f.Close()
		if err := renderFunc(ctx, f); err != nil {
			fmt.Printf("Failed to render %s: %v\n", filename, err)
		} else {
			fmt.Printf("Rendered %s\n", filename)
		}
	}
}

func main() {
	renderStaticFiles()
}
