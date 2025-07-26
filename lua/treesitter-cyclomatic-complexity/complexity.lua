local parser = require('treesitter-cyclomatic-complexity.parser')

local M = {}

local control_flow_patterns = {
  lua = {
    'if_statement',
    'elseif_statement',
    'for_statement',
    'while_statement',
    'repeat_statement'
  },
  javascript = {
    'if_statement',
    'for_statement',
    'for_in_statement',
    'for_of_statement',
    'while_statement',
    'do_statement',
    'switch_statement',
    'case_clause',
    'try_statement',
    'catch_clause',
    'conditional_expression',
    'binary_expression'  -- for && and ||
  },
  python = {
    'if_statement',
    'elif_clause',
    'for_statement',
    'while_statement',
    'try_statement',
    'except_clause',
    'with_statement',
    'conditional_expression',
    'boolean_operator'  -- for and/or
  }
}

local function is_logical_operator(node, lang)
  if lang == 'javascript' then
    if node:type() == 'binary_expression' then
      local operator = node:child(1)
      if operator then
        local op_text = vim.treesitter.get_node_text(operator, 0)
        return op_text == '&&' or op_text == '||'
      end
    end
  elseif lang == 'python' then
    if node:type() == 'boolean_operator' then
      return true
    end
  end
  return false
end

local function count_control_flow_nodes(root_node, bufnr, lang)
  local count = 0
  local patterns = control_flow_patterns[lang] or {}
  
  local function traverse(node)
    local node_type = node:type()
    
    -- Count standard control flow nodes
    for _, pattern in ipairs(patterns) do
      if node_type == pattern then
        if pattern == 'case_clause' then
          -- Each case adds 1 to complexity
          count = count + 1
        elseif pattern == 'binary_expression' or pattern == 'boolean_operator' then
          -- Only count logical operators
          if is_logical_operator(node, lang) then
            count = count + 1
          end
        else
          count = count + 1
        end
        break
      end
    end
    
    -- Recursively traverse child nodes
    for child in node:iter_children() do
      traverse(child)
    end
  end
  
  traverse(root_node)
  return count
end

M.calculate_function_complexity = function(func_node, bufnr, lang)
  if not func_node or not parser.is_language_supported(lang) then
    return 1  -- Base complexity
  end
  
  -- Start with base complexity of 1
  local complexity = 1
  
  -- Count control flow constructs within the function
  local control_flow_count = count_control_flow_nodes(func_node, bufnr, lang)
  complexity = complexity + control_flow_count
  
  return complexity
end

M.calculate_loop_complexity = function(loop_node, bufnr, lang)
  if not loop_node or not parser.is_language_supported(lang) then
    return 1  -- Base complexity for loop
  end
  
  -- Start with base complexity of 1 for the loop itself
  local complexity = 1
  
  -- Count additional control flow constructs within the loop
  local control_flow_count = count_control_flow_nodes(loop_node, bufnr, lang)
  complexity = complexity + control_flow_count
  
  return complexity
end

M.calculate_node_complexity = function(node_info, bufnr, lang)
  if node_info.type == 'function' then
    return M.calculate_function_complexity(node_info.node, bufnr, lang)
  elseif node_info.type == 'loop' then
    return M.calculate_loop_complexity(node_info.node, bufnr, lang)
  end
  
  return 1
end

M.get_complexity_level = function(complexity, thresholds)
  if complexity <= thresholds.low then
    return 'low'
  elseif complexity <= thresholds.medium then
    return 'medium'
  elseif complexity <= thresholds.high then
    return 'high'
  else
    return 'very_high'
  end
end

M.get_all_complexities = function(bufnr, lang)
  local results = {}
  
  -- Get function complexities
  local function_nodes = parser.get_function_nodes(bufnr, lang)
  for _, node_info in ipairs(function_nodes) do
    local complexity = M.calculate_node_complexity(node_info, bufnr, lang)
    table.insert(results, {
      node_info = node_info,
      complexity = complexity,
      type = 'function'
    })
  end
  
  -- Get loop complexities
  local loop_nodes = parser.get_loop_nodes(bufnr, lang)
  for _, node_info in ipairs(loop_nodes) do
    local complexity = M.calculate_node_complexity(node_info, bufnr, lang)
    table.insert(results, {
      node_info = node_info,
      complexity = complexity,
      type = 'loop'
    })
  end
  
  return results
end

return M