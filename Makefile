# Simple Makefile for a Go project

# Build the application
all: build test
templ-install:
	go install github.com/a-h/templ/cmd/templ@latest

templ-watch: templ-install
	@echo "Watching Templ files..."
	templ generate -watch

tailwind-install:
	curl -sL https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-macos-arm64 -o tailwindcss
	chmod +x tailwindcss

tailwind-watch: tailwind-install
	@echo "Watching Tailwind files..."
	@./tailwindcss -i cmd/web/styles/input.css -o cmd/web/assets/css/output.css --watch

air-install:
	go install github.com/air-verse/air@latest

# Live Reload
watch:
	air

build:
	@templ generate
	@./tailwindcss -i cmd/web/styles/input.css -o cmd/web/assets/css/output.css
	@go build -o main cmd/api/main.go

# Run the application
run:
	go run cmd/api/main.go

# Test the application
test:
	@echo "Testing..."
	go test ./... -v

# Clean the binary
clean:
	@echo "Cleaning..."
	rm -f main
	rm -f tailwindcss
	find . -name "*_templ.go" -type f -delete

.PHONY: all build run test clean watch tailwind-install templ-install tailwind-watch templ-watch air-install
