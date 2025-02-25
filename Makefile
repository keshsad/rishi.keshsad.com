# Simple Makefile for a Go project

# Build the application
all: build test


# --- TEMPL RELATED ---
templ-install:
	go install github.com/a-h/templ/cmd/templ@latest

templ-watch: templ-install
	@echo "Watching Templ files..."
	templ generate -watch  # Explicit path to templ for watch

templ-generate: templ-install # New target for explicit generate
	templ generate      # Explicit path to templ for build


# --- TAILWIND RELATED ---
tailwind-install:
	curl -sL https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-macos-arm64 -o tailwindcss
	chmod +x tailwindcss

tailwind-watch: tailwind-install
	@echo "Watching Tailwind files..."
	@./tailwindcss -i cmd/web/styles/input.css -o cmd/web/assets/css/output.css --watch


# --- AIR RELATED ---
air-install:
	go install github.com/air-verse/air@latest

# Live Reload
watch:
	air


# --- BUILD TARGET ---
build: templ-install templ-generate tailwind-install tidy # Added tidy step, moved templ-generate earlier
	@./tailwindcss -i cmd/web/styles/input.css -o cmd/web/assets/css/output.css
	@go build -o main cmd/api/main.go


# --- TIDY TARGET (NEW) ---
tidy:
	@echo "Running go mod tidy"
	go mod tidy
	go mod download # Explicitly download modules

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

.PHONY: all build run test clean watch tailwind-install templ-install tailwind-watch templ-watch air-install templ-generate tidy
