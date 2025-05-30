# Simple Makefile for a Go project

# Build the application
all: build test

templ-install:
	@if ! command -v templ > /dev/null; then \
		read -p "Go's 'templ' is not installed on your machine. Do you want to install it? [Y/n] " choice; \
		if [ "$$choice" != "n" ] && [ "$$choice" != "N" ]; then \
			go install github.com/a-h/templ/cmd/templ@latest; \
			if [ ! -x "$$(command -v templ)" ]; then \
				echo "templ installation failed. Exiting..."; \
				exit 1; \
			fi; \
		else \
			echo "You chose not to install templ. Exiting..."; \
			exit 1; \
		fi; \
	fi

tailwind-install:
	@if [ ! -f tailwindcss ]; then curl -sL https://github.com/tailwindlabs/tailwindcss/releases/download/v4.1.8/tailwindcss-macos-arm64 -o tailwindcss; fi
	@chmod +x tailwindcss
	@echo "Installed tailwindcss"

render:
	@echo "Generating HTML..."
	@go run github.com/a-h/templ/cmd/templ@latest generate
	@echo "Rendering HTML..."
	@go run cmd/render/main.go

copy-assets:
	@echo "Copying assets..."
	@mkdir -p dist/assets
	@cp -r cmd/web/assets/* dist/assets/

build: tailwind-install render
	@echo "Compiling styles..."
	@./tailwindcss -i cmd/web/styles/input.css -o cmd/web/assets/css/output.css
	@echo "Assembling assets..."
	@mkdir -p dist/assets
	@cp -r cmd/web/assets/* dist/assets/
	@echo "Building..."
	@go build -o main cmd/api/main.go
	@echo "Done!"

worker: render
	@echo "Starting deployment..."
	@echo "Installing tailwindcss..."
	@curl -sL https://github.com/tailwindlabs/tailwindcss/releases/download/v4.1.8/tailwindcss-linux-x64 -o tailwindcss
	@chmod +x tailwindcss
	@echo "Compiling CSS..."
	@./tailwindcss -i cmd/web/styles/input.css -o cmd/web/assets/css/output.css
	@echo "Assembling assets..."
	@mkdir -p dist/assets
	@cp -r cmd/web/assets/* dist/assets/
	@echo "Done!"

# Run the application
run:
	@go run cmd/api/main.go

# Test the application
test:
	@echo "Testing..."
	@go test ./... -v

# Clean the binary
clean:
	@echo "Cleaning..."
	@rm -f main

# Live Reload
watch:
	@if command -v air > /dev/null; then \
            air; \
            echo "Watching...";\
        else \
            read -p "Go's 'air' is not installed on your machine. Do you want to install it? [Y/n] " choice; \
            if [ "$$choice" != "n" ] && [ "$$choice" != "N" ]; then \
                go install github.com/air-verse/air@latest; \
                air; \
                echo "Watching...";\
            else \
                echo "You chose not to install air. Exiting..."; \
                exit 1; \
            fi; \
        fi

.PHONY: all build run test clean watch tailwind-install templ-install
