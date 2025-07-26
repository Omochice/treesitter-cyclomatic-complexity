# Design for nvim-treesitter Cyclomatic Complexity Plugin

## Architecture Overview

The plugin follows a modular architecture with clear separation of concerns:

```
treesitter-cyclomatic-complexity/
├── lua/
│   └── treesitter-cyclomatic-complexity/
│       ├── init.lua              # Main plugin entry point
│       ├── config.lua            # Configuration management
│       ├── parser.lua            # Treesitter node extraction
│       ├── complexity.lua        # Complexity calculation
│       ├── display.lua           # Virtual text display
│       └── utils.lua             # Utility functions
└── plugin/
    └── treesitter-cyclomatic-complexity.vim  # Vim plugin definition
```

## Module Design

### 1. init.lua (Main Entry Point)
**Purpose**: Plugin initialization and coordination
**Key Functions**:
- `setup(opts)`: Initialize plugin with user configuration
- `enable()`: Enable complexity display
- `disable()`: Disable complexity display
- `toggle()`: Toggle complexity display

### 2. config.lua (Configuration Management)
**Purpose**: Handle user configuration and defaults
**Configuration Options**:
```lua
{
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
    -- Language-specific settings
  }
}
```

### 3. parser.lua (Treesitter Node Extraction)
**Purpose**: Extract function and loop nodes using treesitter
**Key Functions**:
- `get_function_nodes(bufnr, lang)`: Extract all function definition nodes
- `get_loop_nodes(bufnr, lang)`: Extract all loop nodes (for, while)
- `get_node_range(node)`: Get line/column range for a node
- `is_supported_language(lang)`: Check if language is supported

**Language Support Strategy**:
- Use treesitter query patterns for each language
- Maintain language-specific query files for function/loop detection
- Fallback to generic patterns when possible

### 4. complexity.lua (Complexity Calculation)
**Purpose**: Calculate cyclomatic complexity for code constructs
**Key Functions**:
- `calculate_function_complexity(node, source)`: Calculate complexity for a function
- `calculate_loop_complexity(node, source)`: Calculate complexity for a loop
- `count_control_flow_nodes(node)`: Count decision points in AST subtree

**Complexity Calculation Algorithm**:
1. Start with base complexity of 1
2. Traverse AST nodes within the function/loop scope
3. Increment complexity for each control flow construct:
   - if/else statements (+1 per condition)
   - for/while loops (+1 each)
   - switch cases (+1 per case)
   - try/catch blocks (+1 per catch)
   - ternary operators (+1 each)
   - logical operators (&&, ||) (+1 each)

### 5. display.lua (Virtual Text Display)
**Purpose**: Handle virtual text rendering and updates
**Key Functions**:
- `show_complexity(bufnr, line, complexity, opts)`: Display complexity value
- `clear_complexity(bufnr)`: Clear all complexity displays
- `update_display(bufnr)`: Refresh complexity display for buffer
- `get_highlight_group(complexity, thresholds)`: Determine highlight color

**Display Strategy**:
- Use `vim.api.nvim_buf_set_extmark()` for virtual text
- Create namespace for plugin extmarks
- Color-code based on complexity thresholds (green/yellow/red)
- Position text at end of function/loop definition line

### 6. utils.lua (Utility Functions)
**Purpose**: Common utility functions
**Key Functions**:
- `get_buffer_language(bufnr)`: Detect buffer language via treesitter
- `debounce(func, delay)`: Debounce function calls for performance
- `log(level, message)`: Plugin logging

## Data Flow

1. **Initialization**: User calls `setup()` with configuration
2. **Buffer Attachment**: Plugin attaches to buffers with supported languages
3. **Parsing**: Extract function/loop nodes using treesitter queries
4. **Calculation**: Calculate complexity for each extracted node
5. **Display**: Show complexity values using virtual text
6. **Updates**: Monitor buffer changes and update display accordingly

## Event Handling

- **BufEnter**: Check if buffer language is supported, attach if needed
- **TextChanged/TextChangedI**: Debounced complexity recalculation
- **BufLeave**: Optional cleanup of extmarks
- **LspAttach**: Integration opportunity for LSP-based complexity

## Performance Considerations

1. **Debouncing**: Limit recalculation frequency during rapid typing
2. **Caching**: Cache parsed nodes and complexity results
3. **Incremental Updates**: Only recalculate changed functions when possible
4. **Language Filtering**: Only process supported languages
5. **Async Processing**: Use vim.schedule() for non-blocking updates

## Error Handling

1. **Treesitter Errors**: Graceful fallback when parsing fails
2. **Language Support**: Clear messaging for unsupported languages
3. **Configuration Errors**: Validate user configuration with defaults
4. **Buffer Errors**: Handle buffer deletion/modification edge cases

## Testing Strategy

1. **Unit Tests**: Test complexity calculation with known code samples
2. **Integration Tests**: Test treesitter integration with various languages
3. **Performance Tests**: Verify acceptable performance on large files
4. **Manual Tests**: Visual verification of display functionality

## Language Query Patterns

Each supported language requires treesitter query patterns:

```lua
-- Example for JavaScript/TypeScript
local js_queries = {
  functions = [[
    (function_declaration) @function
    (method_definition) @function
    (arrow_function) @function
  ]],
  control_flow = [[
    (if_statement) @control
    (for_statement) @control
    (while_statement) @control
    (switch_statement) @control
  ]]
}
```

## Extension Points

1. **Custom Languages**: Easy addition of new language support
2. **Custom Metrics**: Framework for additional code metrics
3. **Display Formats**: Pluggable display formatters
4. **Calculation Methods**: Alternative complexity algorithms