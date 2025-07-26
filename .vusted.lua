-- Vusted configuration for treesitter-cyclomatic-complexity

return {
  -- Test directory
  testdir = "tests",

  -- Output format
  output = "gtest",

  -- Verbose output
  verbose = false,

  -- Coverage settings
  coverage = false,

  -- Custom environment setup
  init = function()
    -- Add current directory to runtime path
    vim.opt.rtp:prepend(".")

    -- Set up basic vim options for testing
    vim.g.loaded_remote_plugins = 1
    vim.opt.swapfile = false
    vim.opt.backup = false
    vim.opt.writebackup = false

    -- Disable some built-in plugins for faster startup
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.g.loaded_tarPlugin = 1
    vim.g.loaded_zipPlugin = 1
    vim.g.loaded_gzip = 1
    vim.g.loaded_vimballPlugin = 1
    vim.g.loaded_2html_plugin = 1
    vim.g.loaded_getscriptPlugin = 1
    vim.g.loaded_logipat = 1
    vim.g.loaded_rrhelper = 1
    vim.g.loaded_spellfile_plugin = 1
    vim.g.loaded_matchit = 1
  end,

  -- Test patterns
  patterns = {
    "tests/**/*_spec.lua",
    "tests/*_spec.lua",
  },

  -- Excluded patterns
  exclude = {
    "tests/minimal_init.lua",
    "tests/test_helper.lua",
    "tests/README.md",
  },
}
