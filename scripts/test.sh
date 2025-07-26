#!/bin/bash

# Test runner script for treesitter-cyclomatic-complexity

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
TEST_TYPE="all"
VERBOSE=false
MINIMAL_INIT="tests/minimal_init.lua"

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -t, --type TYPE         Test type: all, unit, integration, fixtures (default: all)"
    echo "  -v, --verbose           Enable verbose output"
    echo "  -f, --file FILE         Run specific test file"
    echo "  --minimal-init FILE     Use custom minimal init file"
    echo ""
    echo "Examples:"
    echo "  $0                      # Run all tests"
    echo "  $0 -t unit              # Run unit tests only"
    echo "  $0 -f tests/unit/config_spec.lua  # Run specific test file"
    echo "  $0 -v                   # Run all tests with verbose output"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -t|--type)
            TEST_TYPE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--file)
            TEST_FILE="$2"
            shift 2
            ;;
        --minimal-init)
            MINIMAL_INIT="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if Neovim is installed
if ! command -v nvim &> /dev/null; then
    echo -e "${RED}Error: Neovim is not installed${NC}"
    exit 1
fi

# Check if minimal init exists
if [ ! -f "$MINIMAL_INIT" ]; then
    echo -e "${RED}Error: Minimal init file not found: $MINIMAL_INIT${NC}"
    exit 1
fi

# Function to run tests
run_test() {
    local test_dir=$1
    local test_name=$2
    
    echo -e "${BLUE}Running $test_name tests...${NC}"
    
    if [ "$VERBOSE" = true ]; then
        nvim --headless --noplugin -u "$MINIMAL_INIT" \
            -c "PlenaryBustedDirectory $test_dir { minimal_init = '$MINIMAL_INIT', sequential = true }"
    else
        nvim --headless --noplugin -u "$MINIMAL_INIT" \
            -c "PlenaryBustedDirectory $test_dir { minimal_init = '$MINIMAL_INIT' }"
    fi
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ $test_name tests passed${NC}"
    else
        echo -e "${RED}❌ $test_name tests failed${NC}"
        return $exit_code
    fi
}

# Function to run specific test file
run_test_file() {
    local test_file=$1
    
    if [ ! -f "$test_file" ]; then
        echo -e "${RED}Error: Test file not found: $test_file${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Running test file: $test_file${NC}"
    
    nvim --headless --noplugin -u "$MINIMAL_INIT" \
        -c "PlenaryBustedFile $test_file"
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ Test file passed: $test_file${NC}"
    else
        echo -e "${RED}❌ Test file failed: $test_file${NC}"
        return $exit_code
    fi
}

# Check dependencies
echo -e "${BLUE}Checking dependencies...${NC}"

# Check if test directories exist
if [ ! -d "tests" ]; then
    echo -e "${RED}Error: tests directory not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dependencies check passed${NC}"

# Run tests based on type
case $TEST_TYPE in
    all)
        echo -e "${YELLOW}Running all tests...${NC}"
        run_test "tests/unit" "unit"
        run_test "tests/integration" "integration" 
        run_test "tests/fixtures" "fixture"
        echo -e "${GREEN}🎉 All tests completed successfully!${NC}"
        ;;
    unit)
        run_test "tests/unit" "unit"
        ;;
    integration)
        run_test "tests/integration" "integration"
        ;;
    fixtures)
        run_test "tests/fixtures" "fixture"
        ;;
    *)
        echo -e "${RED}Error: Unknown test type: $TEST_TYPE${NC}"
        echo "Valid types: all, unit, integration, fixtures"
        exit 1
        ;;
esac

# Run specific test file if provided
if [ -n "$TEST_FILE" ]; then
    run_test_file "$TEST_FILE"
fi

echo -e "${GREEN}🎉 Test run completed!${NC}"