# Design: TDD Refactor for Cyclomatic Complexity Plugin

## Architecture Overview

```text
┌─────────────────────────────────────────────────────────┐
│                    User Interface                        │
│  (Commands, Autocmds, Virtual Text)                     │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│                   init.lua                               │
│  (Entry point, orchestration)                           │
└─────────────────────┬───────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
┌───────▼───────┐ ┌───▼───┐ ┌───────▼───────┐
│  display.lua  │ │config │ │   utils.lua   │
│ (Neovim API)  │ │ .lua  │ │  (Helpers)    │
└───────┬───────┘ └───────┘ └───────────────┘
        │
┌───────▼─────────────────────────────────────────────────┐
│                 Calculation Layer                        │
│  (Pure functions - NO Neovim API dependencies)          │
├─────────────────────┬───────────────────────────────────┤
│   complexity/       │                                    │
│   ├── init.lua      │  Main calculation interface        │
│   ├── counter.lua   │  Control flow counting logic       │
│   └── levels.lua    │  Complexity level determination    │
└─────────────────────┴───────────────────────────────────┘
        │
┌───────▼───────────────────────────────────────────────┐
│                   parser.lua                           │
│  (Treesitter node extraction - Neovim API boundary)   │
└───────────────────────────────────────────────────────┘
```

## Module Design

### 1. Calculation Layer (Pure Functions)

#### 1.1 `lua/treesitter-cyclomatic-complexity/complexity/counter.lua`

Pure functions for counting complexity. NO Neovim API calls.

```lua
-- Interface
local M = {}

-- Count complexity from a structured node representation
-- @param node_data table { type: string, children: table[], operator?: string }
-- @param lang string Language identifier
-- @return number Complexity count
M.count_complexity = function(node_data, lang)

-- Get control flow patterns for a language
-- @param lang string Language identifier
-- @return table List of pattern names
M.get_patterns = function(lang)

-- Check if node type is a decision point
-- @param node_type string
-- @param lang string
-- @return boolean
M.is_decision_point = function(node_type, lang)

-- Check if operator is logical (&&, ||, and, or)
-- @param operator string
-- @param lang string
-- @return boolean
M.is_logical_operator = function(operator, lang)

return M
```

#### 1.2 `lua/treesitter-cyclomatic-complexity/complexity/levels.lua`

Pure functions for determining complexity levels.

```lua
-- Interface
local M = {}

-- Get complexity level based on value and thresholds
-- @param complexity number
-- @param thresholds table { low: number, medium: number, high: number }
-- @return string "low" | "medium" | "high" | "very_high"
M.get_level = function(complexity, thresholds)

-- Default thresholds
M.default_thresholds = {
  low = 5,
  medium = 10,
  high = 15
}

return M
```

#### 1.3 `lua/treesitter-cyclomatic-complexity/complexity/init.lua`

Main calculation interface combining counter and levels.

```lua
-- Interface
local M = {}

-- Calculate complexity for function node data
-- @param node_data table Structured node representation
-- @param lang string Language identifier
-- @return number Complexity value
M.calculate_function_complexity = function(node_data, lang)

-- Calculate complexity for loop node data
-- @param node_data table Structured node representation
-- @param lang string Language identifier
-- @return number Complexity value
M.calculate_loop_complexity = function(node_data, lang)

-- Get complexity level
-- @param complexity number
-- @param thresholds table
-- @return string Level name
M.get_complexity_level = function(complexity, thresholds)

return M
```

### 2. Parser Layer (Neovim API Boundary)

#### 2.1 `lua/treesitter-cyclomatic-complexity/parser.lua`

Converts Treesitter nodes to structured data for calculation layer.

```lua
-- Interface
local M = {}

-- Convert treesitter node to structured data
-- @param node userdata Treesitter node
-- @param bufnr number Buffer number
-- @return table { type: string, children: table[], operator?: string }
M.node_to_data = function(node, bufnr)

-- Get function nodes as structured data
-- @param bufnr number
-- @param lang string
-- @return table[] Array of { node_data: table, start_row: number, name: string }
M.get_function_nodes = function(bufnr, lang)

-- Get loop nodes as structured data
-- @param bufnr number
-- @param lang string
-- @return table[] Array of { node_data: table, start_row: number }
M.get_loop_nodes = function(bufnr, lang)

-- Check if language is supported
-- @param lang string
-- @return boolean
M.is_language_supported = function(lang)

return M
```

### 3. Display Layer (Neovim API)

#### 3.1 `lua/treesitter-cyclomatic-complexity/display.lua`

Handles all Neovim API interactions for display.

```lua
-- Interface (unchanged from current)
local M = {}

M.get_highlight_group = function(complexity_value, thresholds)
M.format_complexity_text = function(complexity_value, format_string)
M.show_complexity = function(bufnr, line, complexity_value, opts)
M.clear_complexity = function(bufnr, line)
M.update_display = function(bufnr)
M.toggle_display = function(bufnr)
M.get_stats = function(bufnr)
M.setup = function()

return M
```

## Data Flow

### Complexity Calculation Flow

```text
1. display.update_display(bufnr)
   │
2. parser.get_function_nodes(bufnr, lang)
   │ → Returns: [{ node_data, start_row, name }]
   │
3. For each node_data:
   │
4. complexity.calculate_function_complexity(node_data, lang)
   │ │
   │ └─► counter.count_complexity(node_data, lang)
   │     │
   │     └─► Traverse node_data tree, count decision points
   │
5. complexity.get_complexity_level(value, thresholds)
   │ │
   │ └─► levels.get_level(value, thresholds)
   │
6. display.show_complexity(bufnr, line, value)
```

### Node Data Structure

```lua
-- Treesitter node converted to testable data structure
node_data = {
  type = "if_statement",      -- Node type string
  children = {                 -- Child nodes (recursive)
    {
      type = "binary_expression",
      operator = "&&",         -- For operator nodes
      children = { ... }
    },
    {
      type = "for_statement",
      children = { ... }
    }
  }
}
```

## Test Structure

### Directory Layout

```text
tests/
├── spec/
│   ├── complexity/
│   │   ├── counter_spec.lua    -- counter.lua unit tests
│   │   └── levels_spec.lua     -- levels.lua unit tests
│   ├── complexity_spec.lua     -- complexity/init.lua tests
│   └── helpers.lua             -- Test utilities
└── minimal_init.lua            -- Minimal Neovim config for tests
```

### Test Categories

#### Pure Unit Tests (No Neovim)

```lua
-- counter_spec.lua
describe("counter", function()
  describe("count_complexity", function()
    it("returns 1 for empty function", function()
      local node_data = { type = "function_definition", children = {} }
      assert.equals(1, counter.count_complexity(node_data, "lua"))
    end)

    it("returns 2 for function with single if", function()
      local node_data = {
        type = "function_definition",
        children = {
          { type = "if_statement", children = {} }
        }
      }
      assert.equals(2, counter.count_complexity(node_data, "lua"))
    end)
  end)
end)
```

#### Integration Tests (With Neovim)

```lua
-- parser_spec.lua (requires Neovim)
describe("parser", function()
  it("converts treesitter node to data", function()
    -- Requires actual Neovim buffer with treesitter
  end)
end)
```

## Implementation Strategy

### Phase 1: Extract Pure Calculation Logic

1. Create `complexity/counter.lua` with pure functions
2. Create `complexity/levels.lua` with pure functions
3. Create `complexity/init.lua` as facade
4. Update `parser.lua` to provide `node_to_data`

### Phase 2: Add Tests (TDD Red)

1. Write tests for `counter.lua`
2. Write tests for `levels.lua`
3. Tests should fail initially (Red)

### Phase 3: Implement (TDD Green)

1. Implement counter logic to pass tests
2. Implement levels logic to pass tests
3. Commit when tests pass (Green)

### Phase 4: Refactor

1. Optimize code structure
2. Remove duplication
3. Improve naming
4. Commit refactoring changes

### Phase 5: Wire Up

1. Update `display.lua` to use new calculation layer
2. Ensure backward compatibility
3. Integration testing

## Backward Compatibility

- All public API remains unchanged
- `require('treesitter-cyclomatic-complexity')` interface preserved
- Commands unchanged
- Configuration unchanged

## File Changes Summary

| File                     | Action | Description             |
| ------------------------ | ------ | ----------------------- |
| `complexity/counter.lua` | Create | Pure counting logic     |
| `complexity/levels.lua`  | Create | Pure level logic        |
| `complexity/init.lua`    | Create | Calculation facade      |
| `complexity.lua`         | Modify | Delegate to new modules |
| `parser.lua`             | Modify | Add node_to_data        |
| `tests/spec/*.lua`       | Create | Unit tests              |
