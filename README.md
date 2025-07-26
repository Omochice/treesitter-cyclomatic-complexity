# nvim-treesitter Cyclomatic Complexity Plugin

A Neovim plugin that displays cyclomatic complexity values next to functions and loops using nvim-treesitter for code parsing.

## Features

- 🔍 **Real-time complexity analysis** using nvim-treesitter
- 🎨 **Color-coded complexity levels** (low/medium/high/very high)
- 🌐 **Multi-language support** (Lua, JavaScript, TypeScript, Python, C, C++, Java, Go, Rust)
- ⚡ **Performance optimized** with debounced updates
- 🛠️ **Highly configurable** display and thresholds
- 📊 **Buffer statistics** and complexity distribution

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'Omochice/treesitter-cyclomatic-complexity',
  requires = 'nvim-treesitter/nvim-treesitter'
}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'Omochice/treesitter-cyclomatic-complexity',
  dependencies = 'nvim-treesitter/nvim-treesitter',
  config = function()
    require('treesitter-cyclomatic-complexity').setup()
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'Omochice/treesitter-cyclomatic-complexity'
```

## Requirements

- Neovim 0.8+
- nvim-treesitter
- Treesitter parsers for your target languages

## Quick Start

```lua
-- Basic setup with defaults
require('treesitter-cyclomatic-complexity').setup()
```

## Configuration

### Default Configuration

```lua
require('treesitter-cyclomatic-complexity').setup({
  enabled = true,
  auto_update = true,
  display = {
    format = "CC: %d",
    highlight = "Comment",
    position = "eol"  -- end of line
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
})
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enabled` | boolean | `true` | Enable/disable the plugin |
| `auto_update` | boolean | `true` | Auto-update on text changes |
| `display.format` | string | `"CC: %d"` | Display format string |
| `display.highlight` | string | `"Comment"` | Highlight group for low complexity |
| `display.position` | string | `"eol"` | Position of virtual text |
| `thresholds.low` | number | `5` | Low complexity threshold |
| `thresholds.medium` | number | `10` | Medium complexity threshold |
| `thresholds.high` | number | `15` | High complexity threshold |
| `languages.*` | boolean | `true` | Enable/disable specific languages |

### Vim Configuration

You can also configure the plugin using vim variables:

```vim
let g:treesitter_cyclomatic_complexity = {
  \\ 'enabled': v:true,
  \\ 'thresholds': {
  \\   'low': 3,
  \\   'medium': 7,
  \\   'high': 12
  \\ }
  \\}
```

## Commands

| Command | Description |
|---------|-------------|
| `:CyclomaticComplexityEnable` | Enable complexity display |
| `:CyclomaticComplexityDisable` | Disable complexity display |
| `:CyclomaticComplexityToggle` | Toggle complexity display |
| `:CyclomaticComplexityUpdate` | Update current buffer |
| `:CyclomaticComplexityClear` | Clear current buffer display |
| `:CyclomaticComplexityRefresh` | Refresh all buffers |

## API

### Lua Functions

```lua
local cc = require('treesitter-cyclomatic-complexity')

-- Basic operations
cc.enable()           -- Enable plugin
cc.disable()          -- Disable plugin
cc.toggle()           -- Toggle plugin state

-- Buffer operations
cc.update_buffer(bufnr)  -- Update specific buffer
cc.clear_buffer(bufnr)   -- Clear specific buffer
cc.refresh()             -- Refresh all buffers

-- Configuration
cc.set_config(config)    -- Update configuration
local config = cc.get_config()  -- Get current configuration

-- Statistics
local display = require('treesitter-cyclomatic-complexity.display')
local stats = display.get_stats(bufnr)
print(vim.inspect(stats))
```

### Statistics Example

```lua
{
  total_functions = 15,
  total_loops = 8,
  avg_complexity = 4.2,
  max_complexity = 12,
  distribution = {
    low = 18,
    medium = 4,
    high = 1,
    very_high = 0
  }
}
```

## Supported Languages

| Language | Functions | Loops | Control Flow |
|----------|-----------|-------|--------------|
| Lua | ✅ | ✅ | if, for, while, repeat |
| JavaScript | ✅ | ✅ | if, for, while, switch, try |
| TypeScript | ✅ | ✅ | if, for, while, switch, try |
| Python | ✅ | ✅ | if, for, while, try, with |
| C | ✅ | ✅ | if, for, while, switch |
| C++ | ✅ | ✅ | if, for, while, switch, try |
| Java | ✅ | ✅ | if, for, while, switch, try |
| Go | ✅ | ✅ | if, for, switch, select |
| Rust | ✅ | ✅ | if, match, loop, for, while |

## How Cyclomatic Complexity is Calculated

Cyclomatic complexity is calculated using the standard formula:

**CC = Number of decision points + 1**

Decision points include:
- `if/else` statements
- Loop constructs (`for`, `while`, etc.)
- `switch/case` statements
- `try/catch` blocks
- Ternary/conditional operators
- Logical operators (`&&`, `||`, `and`, `or`)

### Examples

```lua
-- CC: 1 (base complexity)
function simple()
  return 42
end

-- CC: 3 (1 + if + for)
function moderate(items)
  if #items == 0 then
    return nil
  end
  
  for i, item in ipairs(items) do
    print(item)
  end
end

-- CC: 5 (1 + if + nested if + for + while)
function complex(data)
  if data then
    if data.valid then
      for i = 1, 10 do
        while condition() do
          process()
        end
      end
    end
  end
end
```

## Color Coding

The plugin uses color-coded highlighting based on complexity thresholds:

- 🟢 **Low** (≤ 5): Green - Simple, easy to understand
- 🟡 **Medium** (6-10): Yellow - Moderate complexity
- 🔴 **High** (11-15): Red - Complex, consider refactoring
- 🔴 **Very High** (>15): Dark Red, Bold - Very complex, needs refactoring

## Performance

- **Debounced updates**: 500ms delay prevents excessive recalculation
- **Language filtering**: Only processes supported languages
- **Efficient parsing**: Leverages nvim-treesitter's optimized parsers
- **Minimal overhead**: Virtual text doesn't affect buffer content

## Troubleshooting

### Common Issues

1. **No complexity shown**
   - Ensure nvim-treesitter is installed and configured
   - Check if language parser is available: `:TSInstall <language>`
   - Verify language is enabled in configuration

2. **Performance issues**
   - Disable `auto_update` for large files
   - Reduce update frequency by modifying debounce delay

3. **Incorrect complexity values**
   - Different languages have different AST structures
   - Report issues with code examples for language-specific problems

### Debug Information

```lua
-- Check if language is supported
local parser = require('treesitter-cyclomatic-complexity.parser')
print(vim.inspect(parser.get_supported_languages()))

-- Get buffer statistics
local display = require('treesitter-cyclomatic-complexity.display')
local stats = display.get_stats(0)  -- current buffer
print(vim.inspect(stats))
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

### Adding Language Support

To add support for a new language:

1. Add treesitter queries in `lua/treesitter-cyclomatic-complexity/parser.lua`
2. Add control flow patterns in `lua/treesitter-cyclomatic-complexity/complexity.lua`
3. Test with sample code
4. Update documentation

## License

MIT License - see LICENSE file for details

## Related Projects

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [Complexity analysis tools](https://en.wikipedia.org/wiki/Cyclomatic_complexity)
