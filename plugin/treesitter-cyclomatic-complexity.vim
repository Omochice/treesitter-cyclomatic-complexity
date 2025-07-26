if exists('g:loaded_treesitter_cyclomatic_complexity')
  finish
endif
let g:loaded_treesitter_cyclomatic_complexity = 1

command! CyclomaticComplexityEnable lua require('treesitter-cyclomatic-complexity').enable()
command! CyclomaticComplexityDisable lua require('treesitter-cyclomatic-complexity').disable()
command! CyclomaticComplexityToggle lua require('treesitter-cyclomatic-complexity').toggle()