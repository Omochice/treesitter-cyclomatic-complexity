local config = require('treesitter-cyclomatic-complexity.config')
local complexity = require('treesitter-cyclomatic-complexity.complexity')

local M = {}

local namespace = vim.api.nvim_create_namespace('treesitter-cyclomatic-complexity')

local highlight_groups = {
  low = 'CyclomaticComplexityLow',
  medium = 'CyclomaticComplexityMedium', 
  high = 'CyclomaticComplexityHigh',
  very_high = 'CyclomaticComplexityVeryHigh'
}

local function setup_highlight_groups()
  -- Set up default highlight groups if they don't exist
  local highlights = {
    CyclomaticComplexityLow = { fg = '#10B981', bg = 'NONE' },      -- Green
    CyclomaticComplexityMedium = { fg = '#F59E0B', bg = 'NONE' },   -- Yellow
    CyclomaticComplexityHigh = { fg = '#EF4444', bg = 'NONE' },     -- Red
    CyclomaticComplexityVeryHigh = { fg = '#DC2626', bg = 'NONE', bold = true } -- Dark Red, Bold
  }
  
  for group, attrs in pairs(highlights) do
    if vim.fn.hlexists(group) == 0 then
      vim.api.nvim_set_hl(0, group, attrs)
    end
  end
end

M.get_highlight_group = function(complexity_value, thresholds)
  local level = complexity.get_complexity_level(complexity_value, thresholds)
  return highlight_groups[level] or highlight_groups.low
end

M.format_complexity_text = function(complexity_value, format_string)
  return string.format(format_string or "CC: %d", complexity_value)
end

M.show_complexity = function(bufnr, line, complexity_value, opts)
  opts = opts or {}
  local thresholds = config.get('thresholds')
  local display_opts = config.get('display')
  
  local text = M.format_complexity_text(complexity_value, display_opts.format)
  local hl_group = M.get_highlight_group(complexity_value, thresholds)
  
  -- Create extmark with virtual text
  vim.api.nvim_buf_set_extmark(bufnr, namespace, line, -1, {
    virt_text = {{ text, hl_group }},
    virt_text_pos = 'eol',
    hl_mode = 'combine'
  })
end

M.clear_complexity = function(bufnr, line)
  if line then
    -- Clear specific line
    vim.api.nvim_buf_clear_namespace(bufnr, namespace, line, line + 1)
  else
    -- Clear entire buffer
    vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  end
end

M.update_display = function(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  
  local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
  if not lang or not config.get('languages')[lang] then
    return
  end
  
  -- Clear existing displays
  M.clear_complexity(bufnr)
  
  -- Get all complexities for the buffer
  local complexities = complexity.get_all_complexities(bufnr, lang)
  
  -- Display complexity for each node
  for _, result in ipairs(complexities) do
    local line = result.node_info.start_row
    M.show_complexity(bufnr, line, result.complexity)
  end
end

M.toggle_display = function(bufnr)
  local marks = vim.api.nvim_buf_get_extmarks(bufnr, namespace, 0, -1, {})
  
  if #marks > 0 then
    -- Clear if currently displayed
    M.clear_complexity(bufnr)
  else
    -- Show if currently hidden
    M.update_display(bufnr)
  end
end

M.setup = function()
  setup_highlight_groups()
end

return M