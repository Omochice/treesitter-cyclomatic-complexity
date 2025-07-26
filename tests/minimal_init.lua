-- Minimal init for testing
local plenary_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/plenary.nvim"
local treesitter_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/nvim-treesitter"

if vim.fn.isdirectory(plenary_path) == 0 then
  vim.fn.system({
    "git",
    "clone",
    "https://github.com/nvim-lua/plenary.nvim",
    plenary_path,
  })
end

if vim.fn.isdirectory(treesitter_path) == 0 then
  vim.fn.system({
    "git", 
    "clone",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    treesitter_path,
  })
end

vim.opt.rtp:prepend(plenary_path)
vim.opt.rtp:prepend(treesitter_path)
vim.opt.rtp:prepend(".")

require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "javascript", "python", "c" },
  sync_install = true,
})