local M = {}

local queries = {
  lua = {
    functions = [[
      (function_declaration name: (identifier) @name) @function
      (local_function name: (identifier) @name) @function
      (function_definition) @function
    ]],
    loops = [[
      (for_statement) @loop
      (while_statement) @loop
      (repeat_statement) @loop
    ]],
    control_flow = [[
      (if_statement) @control
      (for_statement) @control
      (while_statement) @control
      (repeat_statement) @control
    ]]
  },
  javascript = {
    functions = [[
      (function_declaration name: (identifier) @name) @function
      (method_definition name: (property_identifier) @name) @function
      (arrow_function) @function
      (function_expression) @function
    ]],
    loops = [[
      (for_statement) @loop
      (for_in_statement) @loop
      (for_of_statement) @loop
      (while_statement) @loop
      (do_statement) @loop
    ]],
    control_flow = [[
      (if_statement) @control
      (for_statement) @control
      (for_in_statement) @control
      (for_of_statement) @control
      (while_statement) @control
      (do_statement) @control
      (switch_statement) @control
      (try_statement) @control
      (conditional_expression) @control
    ]]
  },
  python = {
    functions = [[
      (function_definition name: (identifier) @name) @function
      (async_function_definition name: (identifier) @name) @function
    ]],
    loops = [[
      (for_statement) @loop
      (while_statement) @loop
    ]],
    control_flow = [[
      (if_statement) @control
      (for_statement) @control
      (while_statement) @control
      (try_statement) @control
      (with_statement) @control
      (conditional_expression) @control
    ]]
  }
}

M.get_supported_languages = function()
  return vim.tbl_keys(queries)
end

M.is_language_supported = function(lang)
  return queries[lang] ~= nil
end

M.get_function_nodes = function(bufnr, lang)
  if not M.is_language_supported(lang) then
    return {}
  end
  
  local parser = vim.treesitter.get_parser(bufnr, lang)
  if not parser then
    return {}
  end
  
  local tree = parser:parse()[1]
  if not tree then
    return {}
  end
  
  local root = tree:root()
  local query = vim.treesitter.query.parse(lang, queries[lang].functions)
  local nodes = {}
  
  for _, node in query:iter_captures(root, bufnr) do
    local start_row, start_col, end_row, end_col = node:range()
    table.insert(nodes, {
      node = node,
      start_row = start_row,
      start_col = start_col,
      end_row = end_row,
      end_col = end_col,
      type = 'function'
    })
  end
  
  return nodes
end

M.get_loop_nodes = function(bufnr, lang)
  if not M.is_language_supported(lang) then
    return {}
  end
  
  local parser = vim.treesitter.get_parser(bufnr, lang)
  if not parser then
    return {}
  end
  
  local tree = parser:parse()[1]
  if not tree then
    return {}
  end
  
  local root = tree:root()
  local query = vim.treesitter.query.parse(lang, queries[lang].loops)
  local nodes = {}
  
  for _, node in query:iter_captures(root, bufnr) do
    local start_row, start_col, end_row, end_col = node:range()
    table.insert(nodes, {
      node = node,
      start_row = start_row,
      start_col = start_col,
      end_row = end_row,
      end_col = end_col,
      type = 'loop'
    })
  end
  
  return nodes
end

M.get_control_flow_nodes = function(node, bufnr, lang)
  if not M.is_language_supported(lang) then
    return {}
  end
  
  local query = vim.treesitter.query.parse(lang, queries[lang].control_flow)
  local control_nodes = {}
  
  for _, control_node in query:iter_captures(node, bufnr) do
    table.insert(control_nodes, control_node)
  end
  
  return control_nodes
end

M.get_node_text = function(node, bufnr)
  return vim.treesitter.get_node_text(node, bufnr)
end

M.get_node_range = function(node)
  local start_row, start_col, end_row, end_col = node:range()
  return {
    start_row = start_row,
    start_col = start_col,
    end_row = end_row,
    end_col = end_col
  }
end

return M