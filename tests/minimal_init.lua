-- Minimal init for testing with vusted
local treesitter_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/nvim-treesitter"

-- Install nvim-treesitter if not present
if vim.fn.isdirectory(treesitter_path) == 0 then
  vim.fn.system({
    "git",
    "clone",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    treesitter_path,
  })
end

-- Add paths to runtime
vim.opt.rtp:prepend(treesitter_path)
vim.opt.rtp:prepend(".")

-- Disable some plugins for faster startup
vim.g.loaded_remote_plugins = 1
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Set up treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "javascript", "typescript", "python", "c", "cpp", "java", "go", "rust" },
  sync_install = true,
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
})
