# Requirements: TDD Refactor for Cyclomatic Complexity Plugin

## Overview

Refactor and enhance the existing nvim-treesitter cyclomatic complexity plugin using Test-Driven Development (TDD) methodology following t_wada's recommendations.

## Functional Requirements

### FR-1: Cyclomatic Complexity Calculation

- **FR-1.1**: Calculate cyclomatic complexity for functions in supported languages (Lua, JavaScript, TypeScript, Python, C, C++, Java, Go, Rust)
- **FR-1.2**: Calculate cyclomatic complexity for loop constructs
- **FR-1.3**: Count decision points correctly:
    - if/else statements
    - for/while/do loops
    - switch/case statements
    - try/catch blocks
    - ternary/conditional operators
    - Logical operators (&&, ||, and, or)
- **FR-1.4**: Base complexity starts at 1 for each function/loop
- **FR-1.5**: Support nested control flow structures

### FR-2: Display Functionality

- **FR-2.1**: Display complexity values as virtual text at end of line
- **FR-2.2**: Color-code complexity levels:
    - Low (<=5): Green
    - Medium (6-10): Yellow
    - High (11-15): Red
    - Very High (>15): Dark Red, Bold
- **FR-2.3**: Support customizable display format (e.g., "CC: %d")
- **FR-2.4**: Support configurable thresholds
- **FR-2.5**: Auto-update on text changes with debounce

### FR-3: Configuration

- **FR-3.1**: Enable/disable plugin globally
- **FR-3.2**: Enable/disable specific languages
- **FR-3.3**: Configurable thresholds for complexity levels
- **FR-3.4**: Configurable display format and position
- **FR-3.5**: Support both Lua and Vim configuration

### FR-4: Commands

- **FR-4.1**: Enable/Disable/Toggle commands
- **FR-4.2**: Update/Clear/Refresh commands
- **FR-4.3**: Buffer statistics retrieval

## Non-Functional Requirements

### NFR-1: Architecture

- **NFR-1.1**: Strict separation between calculation logic and display logic
- **NFR-1.2**: Calculation module must be pure functions (no Neovim API dependencies for core logic)
- **NFR-1.3**: Display module handles all Neovim API interactions
- **NFR-1.4**: Modular design allowing unit testing of each component

### NFR-2: Testing

- **NFR-2.1**: All calculation logic must have unit tests
- **NFR-2.2**: Test coverage for all supported languages
- **NFR-2.3**: Test edge cases (empty functions, deeply nested structures)
- **NFR-2.4**: Tests must be runnable without Neovim environment for calculation logic

### NFR-3: Performance

- **NFR-3.1**: Debounced updates (500ms) to prevent excessive recalculation
- **NFR-3.2**: Efficient tree traversal
- **NFR-3.3**: Minimal memory footprint

### NFR-4: Development Process

- **NFR-4.1**: Follow TDD red-green-refactor cycle
- **NFR-4.2**: Commit at each TDD stage:
    - Red: Test fails (test: prefix)
    - Green: Test passes (feat/fix: prefix based on user impact)
    - Refactor: Code improved (refactor: prefix)
- **NFR-4.3**: Use conventional-commit types based on user impact:
    - `feat`: New user-visible functionality
    - `fix`: Bug fixes affecting users
    - `test`: Test additions/changes
    - `refactor`: Code changes without user impact
    - `docs`: Documentation changes
    - `chore`: Maintenance tasks

## Test Strategy

### Unit Tests (Calculation Logic)

1. **Basic complexity calculation**
    - Empty function returns 1
    - Function with single if returns 2
    - Function with if-else returns 2
    - Function with multiple ifs returns correct count

2. **Loop complexity**
    - For loop returns correct complexity
    - While loop returns correct complexity
    - Nested loops accumulate correctly

3. **Control flow patterns per language**
    - Test each language's specific patterns
    - Test logical operators (&&, ||)
    - Test ternary operators

4. **Complexity level determination**
    - Low threshold correct
    - Medium threshold correct
    - High threshold correct
    - Very high threshold correct

### Integration Tests (Display Logic)

1. **Display formatting**
2. **Highlight group selection**
3. **Statistics calculation**

## Acceptance Criteria

1. All existing functionality preserved
2. 100% of calculation logic covered by tests
3. All TDD stages documented with commits
4. Clear separation between testable calculation and Neovim-dependent display
5. Tests can run in CI environment without Neovim

## Out of Scope

- Adding new language support (future enhancement)
- Changing treesitter query patterns
- UI/UX redesign

## Dependencies

- Neovim 0.8+
- nvim-treesitter
- Lua testing framework (busted or similar)
