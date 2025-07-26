.PHONY: test test-unit test-integration test-fixtures clean deps install-vusted

# Default test command
test: test-unit test-integration test-fixtures

# Install vusted
install-vusted:
	@echo "Installing vusted..."
	@if ! command -v luarocks >/dev/null 2>&1; then \
		echo "Error: luarocks is required to install vusted"; \
		echo "Please install luarocks first"; \
		exit 1; \
	fi
	luarocks install vusted

# Run all tests with vusted
test-all:
	@echo "Running all tests with vusted..."
	vusted

# Run unit tests
test-unit:
	@echo "Running unit tests with vusted..."
	vusted tests/unit/

# Run integration tests  
test-integration:
	@echo "Running integration tests with vusted..."
	vusted tests/integration/

# Run fixture tests
test-fixtures:
	@echo "Running fixture tests with vusted..."
	vusted tests/fixtures/

# Run specific test file
test-file:
	@if [ -z "$(FILE)" ]; then echo "Usage: make test-file FILE=path/to/test.lua"; exit 1; fi
	@echo "Running test file: $(FILE)"
	vusted $(FILE)

# Install test dependencies
deps:
	@echo "Installing test dependencies..."
	@echo "Please ensure you have the following installed:"
	@echo "  - luarocks (for installing vusted)"
	@echo "  - nvim-treesitter"
	@echo "Run the following commands if needed:"
	@echo "  luarocks install vusted"
	@echo "  :TSInstall lua javascript typescript python c cpp java go rust"

# Clean test artifacts
clean:
	@echo "Cleaning test artifacts..."
	@rm -rf .tests/
	@echo "Test artifacts cleaned"

# Run tests with coverage (if available)
test-coverage:
	@echo "Running tests with coverage..."
	@echo "Coverage reporting not implemented yet"

# Quick test (unit tests only)
test-quick: test-unit

# Verbose test output
test-verbose:
	@echo "Running all tests with verbose output..."
	vusted --verbose

# Help
help:
	@echo "Available targets:"
	@echo "  test           - Run all tests (unit + integration + fixtures)"
	@echo "  test-all       - Run all tests with vusted (alternative)"
	@echo "  test-unit      - Run unit tests only"
	@echo "  test-integration - Run integration tests only"
	@echo "  test-fixtures  - Run fixture tests only"
	@echo "  test-file      - Run specific test file (use FILE=path)"
	@echo "  test-quick     - Run unit tests only (quick)"
	@echo "  test-verbose   - Run all tests with verbose output"
	@echo "  install-vusted - Install vusted test runner"
	@echo "  deps           - Show dependency installation instructions"
	@echo "  clean          - Clean test artifacts"
	@echo "  help           - Show this help"