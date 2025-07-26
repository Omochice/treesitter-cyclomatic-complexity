local M = {}

M.defaults = {
  enabled = true,
  auto_update = true,
  display = {
    format = "CC: %d",
    highlight = "Comment",
    position = "eol",
  },
  thresholds = {
    low = 5,
    medium = 10,
    high = 15,
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
    rust = true,
  },
}

M.options = {}

M.setup = function(opts)
  -- Merge with vim global variable if it exists
  local vim_config = vim.g.treesitter_cyclomatic_complexity or {}

  -- Priority: opts > vim_config > defaults
  local merged_config = vim.tbl_deep_extend("force", M.defaults, vim_config, opts or {})

  -- Validate configuration
  M.options = M.validate_config(merged_config)
end

M.validate_config = function(config)
  -- Ensure required fields exist and have valid values
  if type(config.enabled) ~= "boolean" then
    config.enabled = M.defaults.enabled
  end

  if type(config.auto_update) ~= "boolean" then
    config.auto_update = M.defaults.auto_update
  end

  if type(config.display) ~= "table" then
    config.display = M.defaults.display
  else
    config.display.format = config.display.format or M.defaults.display.format
    config.display.highlight = config.display.highlight or M.defaults.display.highlight
    config.display.position = config.display.position or M.defaults.display.position
  end

  if type(config.thresholds) ~= "table" then
    config.thresholds = M.defaults.thresholds
  else
    config.thresholds.low = config.thresholds.low or M.defaults.thresholds.low
    config.thresholds.medium = config.thresholds.medium or M.defaults.thresholds.medium
    config.thresholds.high = config.thresholds.high or M.defaults.thresholds.high
  end

  if type(config.languages) ~= "table" then
    config.languages = M.defaults.languages
  end

  return config
end

M.get = function(key)
  if key then
    return M.options[key]
  end
  return M.options
end

M.set = function(key, value)
  if key and M.options then
    M.options[key] = value
  end
end

M.update = function(new_config)
  local merged = vim.tbl_deep_extend("force", M.options, new_config or {})
  M.options = M.validate_config(merged)
end

return M
