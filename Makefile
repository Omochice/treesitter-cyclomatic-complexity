.PHONY: test test-unit test-integration test-fixtures clean deps

# Default test command
test: test-unit test-integration test-fixtures

# Run unit tests
test-unit:
	@echo "Running unit tests..."
	nvim --headless --noplugin -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/unit { minimal_init = 'tests/minimal_init.lua' }"

# Run integration tests  
test-integration:
	@echo "Running integration tests..."
	nvim --headless --noplugin -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/integration { minimal_init = 'tests/minimal_init.lua' }"

# Run fixture tests
test-fixtures:
	@echo "Running fixture tests..."
	nvim --headless --noplugin -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/fixtures { minimal_init = 'tests/minimal_init.lua' }"

# Run specific test file
test-file:
	@if [ -z "$(FILE)" ]; then echo "Usage: make test-file FILE=path/to/test.lua"; exit 1; fi
	nvim --headless --noplugin -u tests/minimal_init.lua -c "PlenaryBustedFile $(FILE)"

# Install test dependencies
deps:
	@echo "Installing test dependencies..."
	@echo "Please ensure you have nvim-treesitter and plenary.nvim installed"
	@echo "Run the following commands if needed:"
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
	nvim --headless --noplugin -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests { minimal_init = 'tests/minimal_init.lua', sequential = true }"

# Help
help:
	@echo "Available targets:"
	@echo "  test           - Run all tests"
	@echo "  test-unit      - Run unit tests only"
	@echo "  test-integration - Run integration tests only"
	@echo "  test-fixtures  - Run fixture tests only"
	@echo "  test-file      - Run specific test file (use FILE=path)"
	@echo "  test-quick     - Run unit tests only (quick)"
	@echo "  test-verbose   - Run all tests with verbose output"
	@echo "  deps           - Show dependency installation instructions"
	@echo "  clean          - Clean test artifacts"
	@echo "  help           - Show this help"