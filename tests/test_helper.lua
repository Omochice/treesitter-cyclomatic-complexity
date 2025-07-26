local M = {}

-- Helper function to create a temporary buffer with content
M.create_test_buffer = function(content, filetype)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
  vim.api.nvim_buf_set_option(bufnr, "filetype", filetype)
  return bufnr
end

-- Helper function to clean up test buffer
M.cleanup_buffer = function(bufnr)
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

-- Helper to wait for treesitter parsing
M.wait_for_treesitter = function(bufnr)
  local max_wait = 1000 -- 1 second
  local wait_time = 0
  local interval = 10

  while wait_time < max_wait do
    local parser = vim.treesitter.get_parser(bufnr)
    if parser then
      local tree = parser:parse()[1]
      if tree then
        return true
      end
    end
    vim.wait(interval)
    wait_time = wait_time + interval
  end

  return false
end

-- Assertion helpers for vusted
M.assert_complexity = function(expected, actual, msg)
  local message = msg or "Complexity mismatch"
  if expected ~= actual then
    error(string.format("%s: expected %d, got %d", message, expected, actual))
  end
end

M.assert_node_count = function(expected, nodes, msg)
  local message = msg or "Node count mismatch"
  local actual = #nodes
  if expected ~= actual then
    error(string.format("%s: expected %d nodes, got %d", message, expected, actual))
  end
end

-- Vusted-compatible assertions
M.assert = {
  are = {
    equal = function(expected, actual, msg)
      if expected ~= actual then
        error(msg or string.format("Expected %s, got %s", tostring(expected), tostring(actual)))
      end
    end,
  },
  is_true = function(value, msg)
    if not value then
      error(msg or "Expected true, got " .. tostring(value))
    end
  end,
  is_false = function(value, msg)
    if value then
      error(msg or "Expected false, got " .. tostring(value))
    end
  end,
  is_nil = function(value, msg)
    if value ~= nil then
      error(msg or "Expected nil, got " .. tostring(value))
    end
  end,
  is_not_nil = function(value, msg)
    if value == nil then
      error(msg or "Expected non-nil value")
    end
  end,
}

-- Mock functions for testing
M.mock_config = function(config)
  local original_config = require("treesitter-cyclomatic-complexity.config")
  local mock = {
    get = function(key)
      if key then
        return config[key]
      end
      return config
    end,
  }

  package.loaded["treesitter-cyclomatic-complexity.config"] = mock
  return original_config
end

M.restore_config = function(original)
  package.loaded["treesitter-cyclomatic-complexity.config"] = original
end

return M
