local config = require('treesitter-cyclomatic-complexity.config')

local M = {}

M.setup = function(opts)
  config.setup(opts)
  
  if config.get('enabled') then
    M.enable()
  end
end

M.enable = function()
  vim.api.nvim_create_autocmd({'BufEnter', 'BufWritePost'}, {
    group = vim.api.nvim_create_augroup('TreesitterCyclomaticComplexity', { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
      
      if lang and config.get('languages')[lang] then
        M.update_buffer(bufnr)
      end
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
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return
  end
  
  M.clear_buffer(bufnr)
end

M.clear_buffer = function(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  
  local ns_id = vim.api.nvim_create_namespace('treesitter-cyclomatic-complexity')
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
end

return M