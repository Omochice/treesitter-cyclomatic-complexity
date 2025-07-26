local M = {}

M.defaults = {
  enabled = true,
  auto_update = true,
  display = {
    format = "CC: %d",
    highlight = "Comment",
    position = "eol"
  },
  thresholds = {
    low = 5,
    medium = 10,
    high = 15
  },
  languages = {
    lua = true,
    javascript = true,
    typescript = true,
    python = true,
    c = true,
    cpp = true,
    java = true,
    go = true,
    rust = true
  }
}

M.options = {}

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

M.get = function(key)
  if key then
    return M.options[key]
  end
  return M.options
end

return M