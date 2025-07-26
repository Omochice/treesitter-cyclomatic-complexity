# Tests

This directory contains comprehensive tests for the treesitter-cyclomatic-complexity plugin.

## Test Structure

```
tests/
├── minimal_init.lua          # Minimal Neovim configuration for testing
├── test_helper.lua           # Test utility functions and helpers
├── unit/                     # Unit tests for individual modules
│   ├── complexity_spec.lua   # Tests for complexity calculation
│   ├── parser_spec.lua       # Tests for treesitter parsing
│   └── config_spec.lua       # Tests for configuration management
├── integration/              # Integration tests
│   └── display_spec.lua      # Tests for display functionality
├── fixtures/                 # Test data and sample code
│   ├── lua_samples.lua       # Lua code samples with known complexities
│   ├── javascript_samples.js # JavaScript code samples
│   ├── python_samples.py     # Python code samples
│   ├── c_samples.c           # C code samples
│   └── fixture_test_spec.lua # Tests validating fixture complexity
└── README.md                 # This file
```

## Running Tests

### Prerequisites

1. **Neovim 0.8+**: Required for running tests
2. **plenary.nvim**: Testing framework dependency
3. **nvim-treesitter**: Required for parsing functionality
4. **Treesitter parsers**: Install parsers for tested languages

```bash
# Install treesitter parsers
nvim -c "TSInstall lua javascript typescript python c cpp java go rust" -c "qa"
```

### Test Commands

#### Using Make

```bash
# Run all tests
make test

# Run specific test suites
make test-unit           # Unit tests only
make test-integration    # Integration tests only  
make test-fixtures       # Fixture validation tests only

# Run a specific test file
make test-file FILE=tests/unit/complexity_spec.lua

# Quick unit test run
make test-quick

# Verbose output
make test-verbose

# Show help
make help
```

#### Using Test Script

```bash
# Run all tests
./scripts/test.sh

# Run specific test type
./scripts/test.sh --type unit
./scripts/test.sh --type integration
./scripts/test.sh --type fixtures

# Run specific test file
./scripts/test.sh --file tests/unit/config_spec.lua

# Verbose output
./scripts/test.sh --verbose

# Show help
./scripts/test.sh --help
```

#### Manual Execution

```bash
# Run specific test directory
nvim --headless --noplugin -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/unit { minimal_init = 'tests/minimal_init.lua' }"

# Run specific test file
nvim --headless --noplugin -u tests/minimal_init.lua \
  -c "PlenaryBustedFile tests/unit/complexity_spec.lua"
```

## Test Categories

### Unit Tests

Tests individual modules in isolation:

- **complexity_spec.lua**: Tests cyclomatic complexity calculation algorithm
  - Validates complexity for different control structures
  - Tests multiple programming languages
  - Validates complexity level classification
  - Tests edge cases and error handling

- **parser_spec.lua**: Tests treesitter node extraction
  - Validates function and loop node detection
  - Tests multiple programming languages
  - Tests node text and range extraction
  - Tests error handling for unsupported languages

- **config_spec.lua**: Tests configuration management
  - Validates default configuration values
  - Tests configuration merging and validation
  - Tests vim global variable integration
  - Tests runtime configuration updates

### Integration Tests

Tests module interactions and end-to-end functionality:

- **display_spec.lua**: Tests display system integration
  - Tests virtual text creation and management
  - Tests highlight group assignment
  - Tests buffer statistics calculation
  - Tests multi-language display support
  - Tests error handling and edge cases

### Fixture Tests

Validates plugin accuracy using real code samples:

- **fixture_test_spec.lua**: Tests against known complexity samples
  - Validates expected complexity values
  - Tests cross-language consistency
  - Ensures parser accuracy across different code patterns

## Test Fixtures

Test fixtures contain real code samples with documented expected complexities:

### Language Coverage

- **Lua**: Functions, loops, conditionals, local functions
- **JavaScript**: Functions, arrow functions, classes, async/await, try/catch
- **Python**: Functions, async functions, comprehensions, decorators
- **C**: Functions, loops, switch statements, preprocessor conditionals

### Complexity Patterns

Each fixture includes examples of:
- Simple functions (CC: 1)
- Functions with conditionals (CC: 2-3)
- Functions with loops (CC: 2-4)
- Complex functions with nested structures (CC: 5+)
- Edge cases and language-specific constructs

## Writing Tests

### Test Structure

```lua
local helper = require('tests.test_helper')
local module = require('treesitter-cyclomatic-complexity.module')

describe("module description", function()
  local test_bufnr
  
  after_each(function()
    if test_bufnr then
      helper.cleanup_buffer(test_bufnr)
      test_bufnr = nil
    end
  end)

  it("should do something", function()
    local content = "test code"
    test_bufnr = helper.create_test_buffer(content, 'lua')
    assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")
    
    -- Test assertions
    local result = module.do_something(test_bufnr)
    assert.are.equal(expected, result)
  end)
end)
```

### Helper Functions

The `test_helper.lua` module provides utilities:

- `create_test_buffer(content, filetype)`: Create temporary test buffer
- `cleanup_buffer(bufnr)`: Clean up test buffer
- `wait_for_treesitter(bufnr)`: Wait for treesitter parsing
- `assert_complexity(expected, actual, msg)`: Assert complexity values
- `assert_node_count(expected, nodes, msg)`: Assert node counts
- `mock_config(config)`: Mock configuration for testing

### Best Practices

1. **Clean up resources**: Always clean up test buffers in `after_each`
2. **Wait for treesitter**: Use `wait_for_treesitter` before testing parsing results
3. **Test edge cases**: Include tests for invalid inputs and error conditions
4. **Use descriptive names**: Test descriptions should clearly indicate what's being tested
5. **Validate assumptions**: Use assertions to validate test setup

## Continuous Integration

Tests run automatically on:
- Pull requests to main branch
- Pushes to main and develop branches
- Multiple Neovim versions (stable and nightly)

The CI workflow:
1. Installs Neovim and dependencies
2. Installs required treesitter parsers
3. Runs all test suites
4. Checks code formatting with StyLua
5. Validates code quality standards

## Troubleshooting

### Common Issues

1. **Treesitter parsers not installed**
   ```bash
   nvim -c "TSInstall lua javascript python c" -c "qa"
   ```

2. **plenary.nvim not found**
   ```bash
   # Install plenary.nvim in your plugin manager or manually
   git clone https://github.com/nvim-lua/plenary.nvim ~/.local/share/nvim/site/pack/packer/start/plenary.nvim
   ```

3. **Tests timeout**
   - Increase wait time in `test_helper.lua`
   - Check if treesitter parsers are properly installed

4. **Buffer-related errors**
   - Ensure proper cleanup in `after_each` blocks
   - Check buffer validity before operations

### Debug Mode

Run tests with verbose output for debugging:

```bash
./scripts/test.sh --verbose
```

Or manually with detailed output:

```bash
nvim --headless --noplugin -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests { minimal_init = 'tests/minimal_init.lua', sequential = true }"
```