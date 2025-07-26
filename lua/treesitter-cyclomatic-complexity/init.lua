local config = require('treesitter-cyclomatic-complexity.config')
local display = require('treesitter-cyclomatic-complexity.display')
local utils = require('treesitter-cyclomatic-complexity.utils')

local M = {}

-- Debounced update function to prevent excessive recalculations
local debounced_update = utils.debounce(function(bufnr)
  M.update_buffer(bufnr)
end, 500)

M.setup = function(opts)
  config.setup(opts)
  display.setup()
  
  if config.get('enabled') then
    M.enable()
  end
end

M.enable = function()
  local augroup = vim.api.nvim_create_augroup('TreesitterCyclomaticComplexity', { clear = true })
  
  -- Immediate update on buffer enter and save
  vim.api.nvim_create_autocmd({'BufEnter', 'BufWritePost'}, {
    group = augroup,
    callback = function(args)
      local bufnr = args.buf
      if utils.is_buffer_supported(bufnr) then
        M.update_buffer(bufnr)
      end
    end
  })
  
  -- Debounced update on text changes (only if auto_update is enabled)
  if config.get('auto_update') then
    vim.api.nvim_create_autocmd({'TextChanged', 'TextChangedI'}, {
      group = augroup,
      callback = function(args)
        local bufnr = args.buf
        if utils.is_buffer_supported(bufnr) then
          debounced_update(bufnr)
        end
      end
    })
  end
  
  -- Clean up on buffer delete
  vim.api.nvim_create_autocmd('BufDelete', {
    group = augroup,
    callback = function(args)
      local bufnr = args.buf
      M.clear_buffer(bufnr)
    end
  })
end

M.disable = function()
  vim.api.nvim_create_augroup('TreesitterCyclomaticComplexity', { clear = true })
  
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    M.clear_buffer(bufnr)
  end
end

M.toggle = function()
  local current_state = config.get('enabled')
  config.options.enabled = not current_state
  
  if config.get('enabled') then
    M.enable()
  else
    M.disable()
  end
end

M.update_buffer = function(bufnr)
  utils.safe_call(function()
    local parser = vim.treesitter.get_parser(bufnr)
    if not parser then
      utils.log('WARN', 'No treesitter parser available for buffer ' .. bufnr)
      return
    end
    
    display.update_display(bufnr)
  end)
end

M.clear_buffer = function(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  
  display.clear_complexity(bufnr)
end

return M