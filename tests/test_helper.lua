local M = {}

-- Helper function to create a temporary buffer with content
M.create_test_buffer = function(content, filetype)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, '\n'))
  vim.api.nvim_buf_set_option(bufnr, 'filetype', filetype)
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

-- Assertion helpers
M.assert_complexity = function(expected, actual, msg)
  assert(expected == actual, 
    string.format("%s: expected %d, got %d", msg or "Complexity mismatch", expected, actual))
end

M.assert_node_count = function(expected, nodes, msg)
  assert(expected == #nodes,
    string.format("%s: expected %d nodes, got %d", msg or "Node count mismatch", expected, #nodes))
end

-- Mock functions for testing
M.mock_config = function(config)
  local original_config = require('treesitter-cyclomatic-complexity.config')
  local mock = {
    get = function(key)
      if key then
        return config[key]
      end
      return config
    end
  }
  
  package.loaded['treesitter-cyclomatic-complexity.config'] = mock
  return original_config
end

M.restore_config = function(original)
  package.loaded['treesitter-cyclomatic-complexity.config'] = original
end

return M