local M = {}

M.debounce = function(func, delay)
  local timer = nil
  return function(...)
    local args = { ... }
    if timer then
      timer:stop()
    end
    timer = vim.defer_fn(function()
      func(unpack(args))
    end, delay)
  end
end

M.get_buffer_language = function(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end
  
  local filetype = vim.bo[bufnr].filetype
  return vim.treesitter.language.get_lang(filetype)
end

M.is_buffer_supported = function(bufnr)
  local lang = M.get_buffer_language(bufnr)
  if not lang then
    return false
  end
  
  local parser = require('treesitter-cyclomatic-complexity.parser')
  return parser.is_language_supported(lang)
end

M.log = function(level, message)
  local levels = {
    DEBUG = vim.log.levels.DEBUG,
    INFO = vim.log.levels.INFO,
    WARN = vim.log.levels.WARN,
    ERROR = vim.log.levels.ERROR
  }
  
  if levels[level] then
    vim.notify('[TreesitterCyclomaticComplexity] ' .. message, levels[level])
  end
end

M.safe_call = function(func, ...)
  local ok, result = pcall(func, ...)
  if not ok then
    M.log('ERROR', 'Function call failed: ' .. tostring(result))
    return nil
  end
  return result
end

return M