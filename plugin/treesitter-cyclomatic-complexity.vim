if exists('g:loaded_treesitter_cyclomatic_complexity')
  finish
endif
let g:loaded_treesitter_cyclomatic_complexity = 1

command! CyclomaticComplexityEnable lua require('treesitter-cyclomatic-complexity').enable()
command! CyclomaticComplexityDisable lua require('treesitter-cyclomatic-complexity').disable()
command! CyclomaticComplexityToggle lua require('treesitter-cyclomatic-complexity').toggle()
command! CyclomaticComplexityUpdate lua require('treesitter-cyclomatic-complexity').update_buffer(vim.api.nvim_get_current_buf())
command! CyclomaticComplexityClear lua require('treesitter-cyclomatic-complexity').clear_buffer(vim.api.nvim_get_current_buf())
command! CyclomaticComplexityRefresh lua require('treesitter-cyclomatic-complexity').refresh()

" User configuration variables
if !exists('g:treesitter_cyclomatic_complexity')
  let g:treesitter_cyclomatic_complexity = {}
endif