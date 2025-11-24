-- Minimal init.lua for running tests with Neovim
-- Used for integration tests that require Neovim API

local plenary_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/plenary.nvim'
if vim.fn.isdirectory(plenary_path) == 0 then
  vim.fn.system({
    'git', 'clone', '--depth', '1',
    'https://github.com/nvim-lua/plenary.nvim',
    plenary_path
  })
end

local treesitter_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/nvim-treesitter'
if vim.fn.isdirectory(treesitter_path) == 0 then
  vim.fn.system({
    'git', 'clone', '--depth', '1',
    'https://github.com/nvim-treesitter/nvim-treesitter',
    treesitter_path
  })
end

vim.opt.runtimepath:append(plenary_path)
vim.opt.runtimepath:append(treesitter_path)
vim.opt.runtimepath:append('.')

vim.cmd('runtime plugin/plenary.vim')
