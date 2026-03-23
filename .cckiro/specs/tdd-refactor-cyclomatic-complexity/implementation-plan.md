# Implementation Plan: TDD Refactor for Cyclomatic Complexity Plugin

## Overview

This plan follows TDD methodology with red-green-refactor cycles. Each cycle produces 1-3 commits.

## Prerequisites

- [ ] Set up test framework (busted)
- [ ] Create test directory structure

## Implementation Tasks

---

### Task 1: Test Infrastructure Setup

**Goal:** Set up testing framework and helpers

#### Steps

1. Create `tests/` directory structure
2. Create `tests/minimal_init.lua` for Neovim tests
3. Create `tests/spec/helpers.lua` with test utilities
4. Verify test runner works

**Commit:** `chore: set up test infrastructure`

---

### Task 2: Complexity Levels Module

**Goal:** Create and test `complexity/levels.lua`

#### TDD Cycle 2.1: get_level function

**Red:**

```lua
-- tests/spec/complexity/levels_spec.lua
describe("levels", function()
  describe("get_level", function()
    it("returns 'low' for complexity <= threshold.low", function()
      local thresholds = { low = 5, medium = 10, high = 15 }
      assert.equals("low", levels.get_level(1, thresholds))
      assert.equals("low", levels.get_level(5, thresholds))
    end)

    it("returns 'medium' for complexity <= threshold.medium", function()
      local thresholds = { low = 5, medium = 10, high = 15 }
      assert.equals("medium", levels.get_level(6, thresholds))
      assert.equals("medium", levels.get_level(10, thresholds))
    end)

    it("returns 'high' for complexity <= threshold.high", function()
      local thresholds = { low = 5, medium = 10, high = 15 }
      assert.equals("high", levels.get_level(11, thresholds))
      assert.equals("high", levels.get_level(15, thresholds))
    end)

    it("returns 'very_high' for complexity > threshold.high", function()
      local thresholds = { low = 5, medium = 10, high = 15 }
      assert.equals("very_high", levels.get_level(16, thresholds))
      assert.equals("very_high", levels.get_level(100, thresholds))
    end)
  end)
end)
```

**Commit:** `test: add levels.get_level tests`

**Green:**

- Implement `complexity/levels.lua` with `get_level` function
- **Commit:** `feat: implement complexity level determination`

**Refactor:**

- Clean up code if needed
- **Commit:** `refactor: improve levels module` (if applicable)

---

### Task 3: Counter Module - Basic Patterns

**Goal:** Create and test `complexity/counter.lua` for basic patterns

#### TDD Cycle 3.1: get_patterns function

**Red:**

```lua
-- tests/spec/complexity/counter_spec.lua
describe("counter", function()
  describe("get_patterns", function()
    it("returns lua patterns", function()
      local patterns = counter.get_patterns("lua")
      assert.is_table(patterns)
      assert.is_true(vim.tbl_contains(patterns, "if_statement"))
      assert.is_true(vim.tbl_contains(patterns, "for_statement"))
    end)

    it("returns empty table for unsupported language", function()
      local patterns = counter.get_patterns("unsupported")
      assert.same({}, patterns)
    end)
  end)
end)
```

**Commit:** `test: add counter.get_patterns tests`

**Green:**

- Implement pattern definitions
- **Commit:** `feat: implement control flow patterns`

#### TDD Cycle 3.2: is_decision_point function

**Red:**

```lua
describe("is_decision_point", function()
  it("returns true for if_statement in lua", function()
    assert.is_true(counter.is_decision_point("if_statement", "lua"))
  end)

  it("returns false for non-decision nodes", function()
    assert.is_false(counter.is_decision_point("identifier", "lua"))
  end)

  it("handles all supported languages", function()
    assert.is_true(counter.is_decision_point("if_statement", "javascript"))
    assert.is_true(counter.is_decision_point("if_statement", "python"))
  end)
end)
```

**Commit:** `test: add counter.is_decision_point tests`

**Green:**

- Implement `is_decision_point`
- **Commit:** `feat: implement decision point detection`

#### TDD Cycle 3.3: is_logical_operator function

**Red:**

```lua
describe("is_logical_operator", function()
  it("returns true for && in javascript", function()
    assert.is_true(counter.is_logical_operator("&&", "javascript"))
  end)

  it("returns true for || in javascript", function()
    assert.is_true(counter.is_logical_operator("||", "javascript"))
  end)

  it("returns true for 'and' in python", function()
    assert.is_true(counter.is_logical_operator("and", "python"))
  end)

  it("returns false for arithmetic operators", function()
    assert.is_false(counter.is_logical_operator("+", "javascript"))
  end)
end)
```

**Commit:** `test: add counter.is_logical_operator tests`

**Green:**

- Implement `is_logical_operator`
- **Commit:** `feat: implement logical operator detection`

---

### Task 4: Counter Module - Complexity Calculation

**Goal:** Implement main complexity counting logic

#### TDD Cycle 4.1: count_complexity for empty function

**Red:**

```lua
describe("count_complexity", function()
  it("returns 0 for empty node_data", function()
    local node_data = { type = "function_definition", children = {} }
    assert.equals(0, counter.count_complexity(node_data, "lua"))
  end)
end)
```

**Commit:** `test: add count_complexity empty function test`

**Green:**

- Implement base case
- **Commit:** `feat: implement base complexity counting`

#### TDD Cycle 4.2: count_complexity for single decision point

**Red:**

```lua
it("returns 1 for single if statement", function()
  local node_data = {
    type = "function_definition",
    children = {
      { type = "if_statement", children = {} }
    }
  }
  assert.equals(1, counter.count_complexity(node_data, "lua"))
end)

it("returns 1 for single for loop", function()
  local node_data = {
    type = "function_definition",
    children = {
      { type = "for_statement", children = {} }
    }
  }
  assert.equals(1, counter.count_complexity(node_data, "lua"))
end)
```

**Commit:** `test: add count_complexity single decision tests`

**Green:**

- Implement single decision point counting
- **Commit:** `feat: implement single decision point counting`

#### TDD Cycle 4.3: count_complexity for nested structures

**Red:**

```lua
it("counts nested structures correctly", function()
  local node_data = {
    type = "function_definition",
    children = {
      {
        type = "if_statement",
        children = {
          { type = "for_statement", children = {} }
        }
      }
    }
  }
  assert.equals(2, counter.count_complexity(node_data, "lua"))
end)

it("counts multiple siblings correctly", function()
  local node_data = {
    type = "function_definition",
    children = {
      { type = "if_statement", children = {} },
      { type = "for_statement", children = {} },
      { type = "while_statement", children = {} }
    }
  }
  assert.equals(3, counter.count_complexity(node_data, "lua"))
end)
```

**Commit:** `test: add count_complexity nested/sibling tests`

**Green:**

- Implement recursive traversal
- **Commit:** `feat: implement nested complexity counting`

#### TDD Cycle 4.4: count_complexity for logical operators

**Red:**

```lua
it("counts logical operators in javascript", function()
  local node_data = {
    type = "function_definition",
    children = {
      {
        type = "if_statement",
        children = {
          { type = "binary_expression", operator = "&&", children = {} }
        }
      }
    }
  }
  assert.equals(2, counter.count_complexity(node_data, "javascript"))
end)
```

**Commit:** `test: add count_complexity logical operator tests`

**Green:**

- Implement logical operator counting
- **Commit:** `feat: implement logical operator counting`

**Refactor:**

- Consolidate traversal logic
- **Commit:** `refactor: improve counter traversal`

---

### Task 5: Complexity Facade Module

**Goal:** Create `complexity/init.lua` as public interface

#### TDD Cycle 5.1: calculate_function_complexity

**Red:**

```lua
-- tests/spec/complexity_spec.lua
describe("complexity", function()
  describe("calculate_function_complexity", function()
    it("returns 1 for empty function", function()
      local node_data = { type = "function_definition", children = {} }
      assert.equals(1, complexity.calculate_function_complexity(node_data, "lua"))
    end)

    it("returns correct complexity for function with control flow", function()
      local node_data = {
        type = "function_definition",
        children = {
          { type = "if_statement", children = {} },
          { type = "for_statement", children = {} }
        }
      }
      assert.equals(3, complexity.calculate_function_complexity(node_data, "lua"))
    end)
  end)
end)
```

**Commit:** `test: add calculate_function_complexity tests`

**Green:**

- Implement facade combining counter + base complexity
- **Commit:** `feat: implement function complexity calculation`

#### TDD Cycle 5.2: calculate_loop_complexity

**Red:**

```lua
describe("calculate_loop_complexity", function()
  it("returns 1 for simple loop", function()
    local node_data = { type = "for_statement", children = {} }
    assert.equals(1, complexity.calculate_loop_complexity(node_data, "lua"))
  end)

  it("returns correct complexity for loop with nested control flow", function()
    local node_data = {
      type = "for_statement",
      children = {
        { type = "if_statement", children = {} }
      }
    }
    assert.equals(2, complexity.calculate_loop_complexity(node_data, "lua"))
  end)
end)
```

**Commit:** `test: add calculate_loop_complexity tests`

**Green:**

- Implement loop complexity calculation
- **Commit:** `feat: implement loop complexity calculation`

---

### Task 6: Language-Specific Tests

**Goal:** Ensure all languages work correctly

#### TDD Cycle 6.1: JavaScript/TypeScript patterns

**Red:**

```lua
describe("javascript patterns", function()
  it("counts switch cases", function()
    local node_data = {
      type = "function_declaration",
      children = {
        { type = "switch_statement", children = {
          { type = "case_clause", children = {} },
          { type = "case_clause", children = {} }
        }}
      }
    }
    assert.equals(3, complexity.calculate_function_complexity(node_data, "javascript"))
  end)

  it("counts try-catch", function()
    local node_data = {
      type = "function_declaration",
      children = {
        { type = "try_statement", children = {
          { type = "catch_clause", children = {} }
        }}
      }
    }
    assert.equals(3, complexity.calculate_function_complexity(node_data, "javascript"))
  end)
end)
```

**Commit:** `test: add JavaScript pattern tests`

**Green:**

- Verify/fix JavaScript patterns
- **Commit:** `fix: correct JavaScript complexity calculation` (if fixes needed)

#### TDD Cycle 6.2: Python patterns

**Red:**

```lua
describe("python patterns", function()
  it("counts elif clauses", function()
    local node_data = {
      type = "function_definition",
      children = {
        { type = "if_statement", children = {
          { type = "elif_clause", children = {} }
        }}
      }
    }
    assert.equals(3, complexity.calculate_function_complexity(node_data, "python"))
  end)

  it("counts boolean operators", function()
    local node_data = {
      type = "function_definition",
      children = {
        { type = "if_statement", children = {
          { type = "boolean_operator", operator = "and", children = {} }
        }}
      }
    }
    assert.equals(3, complexity.calculate_function_complexity(node_data, "python"))
  end)
end)
```

**Commit:** `test: add Python pattern tests`

**Green:**

- Verify/fix Python patterns
- **Commit:** `fix: correct Python complexity calculation` (if fixes needed)

#### TDD Cycle 6.3-6.7: Other languages (C, C++, Java, Go, Rust)

Similar pattern for each language.

---

### Task 7: Parser Integration

**Goal:** Update parser to provide node_data structure

#### Steps

1. Add `node_to_data` function to parser.lua
2. Update `get_function_nodes` to return node_data
3. Update `get_loop_nodes` to return node_data
4. Integration tests with actual Neovim

**Commits:**

- `feat: add node_to_data conversion to parser`
- `refactor: update parser to return structured data`

---

### Task 8: Wire Up New Modules

**Goal:** Connect new calculation modules to existing code

#### Steps

1. Update `complexity.lua` to use new modules
2. Update `display.lua` to use new calculation interface
3. Ensure backward compatibility
4. End-to-end testing

**Commits:**

- `refactor: integrate new calculation modules`
- `test: add integration tests`

---

### Task 9: Cleanup and Documentation

**Goal:** Final cleanup and documentation

#### Steps

1. Remove any deprecated code
2. Update inline documentation
3. Verify all tests pass
4. Final refactoring

**Commits:**

- `refactor: cleanup deprecated code`
- `docs: update code documentation`

---

## Commit Summary

| Task             | Red Commits | Green Commits | Refactor Commits |
| ---------------- | ----------- | ------------- | ---------------- |
| 1. Setup         | -           | 1             | -                |
| 2. Levels        | 1           | 1             | 0-1              |
| 3. Counter Basic | 3           | 3             | 0-1              |
| 4. Counter Calc  | 4           | 4             | 1                |
| 5. Facade        | 2           | 2             | 0-1              |
| 6. Languages     | 5+          | 0-5           | -                |
| 7. Parser        | -           | 2             | -                |
| 8. Wire Up       | -           | 1             | 1                |
| 9. Cleanup       | -           | -             | 2                |

**Total: ~25-35 commits**

## Test Execution

```bash
# Run all tests
busted tests/spec

# Run specific test file
busted tests/spec/complexity/counter_spec.lua

# Run with verbose output
busted tests/spec -v
```

## Success Criteria

- [ ] All tests pass
- [ ] Test coverage > 90% for calculation logic
- [ ] No regressions in existing functionality
- [ ] Each TDD stage properly committed
- [ ] Commit messages follow conventional-commit format
