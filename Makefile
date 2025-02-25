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

templ-watch: templ-install
	@echo "Watching Templ files..."
	@templ generate -watch

tailwind-install:
	@if [ ! -f tailwindcss ]; then curl -sL https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-macos-arm64 -o tailwindcss; fi
	@chmod +x tailwindcss

tailwind-watch: tailwind-install
	@echo "Watching Tailwind files..."
	@./tailwindcss -i cmd/web/styles/input.css -o cmd/web/assets/css/output.css --watch

build: tailwind-install templ-install
	@echo "Building..."
	@templ generate
	@./tailwindcss -i cmd/web/styles/input.css -o cmd/web/assets/css/output.css
	@go build -o main cmd/api/main.go

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
	@rm -f tailwindcss
	@find . -name "*_templ.go" -type f -delete

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
