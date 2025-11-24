-- Complexity counting logic
-- Pure functions - no Neovim API dependencies

local M = {}

-- Control flow patterns for each supported language
local control_flow_patterns = {
  lua = {
    "if_statement",
    "elseif_statement",
    "for_statement",
    "while_statement",
    "repeat_statement"
  },
  javascript = {
    "if_statement",
    "for_statement",
    "for_in_statement",
    "for_of_statement",
    "while_statement",
    "do_statement",
    "switch_statement",
    "case_clause",
    "try_statement",
    "catch_clause",
    "conditional_expression"
  },
  typescript = {
    "if_statement",
    "for_statement",
    "for_in_statement",
    "for_of_statement",
    "while_statement",
    "do_statement",
    "switch_statement",
    "case_clause",
    "try_statement",
    "catch_clause",
    "conditional_expression"
  },
  python = {
    "if_statement",
    "elif_clause",
    "for_statement",
    "while_statement",
    "try_statement",
    "except_clause",
    "with_statement",
    "conditional_expression"
  },
  c = {
    "if_statement",
    "for_statement",
    "while_statement",
    "do_statement",
    "switch_statement",
    "case_statement",
    "conditional_expression"
  },
  cpp = {
    "if_statement",
    "for_statement",
    "while_statement",
    "do_statement",
    "for_range_loop",
    "switch_statement",
    "case_statement",
    "try_statement",
    "catch_clause",
    "conditional_expression"
  },
  java = {
    "if_statement",
    "for_statement",
    "enhanced_for_statement",
    "while_statement",
    "do_statement",
    "switch_expression",
    "switch_label",
    "try_statement",
    "catch_clause",
    "ternary_expression"
  },
  go = {
    "if_statement",
    "for_statement",
    "switch_statement",
    "type_switch_statement",
    "select_statement",
    "expression_case",
    "type_case"
  },
  rust = {
    "if_expression",
    "match_expression",
    "match_arm",
    "loop_expression",
    "for_expression",
    "while_expression"
  }
}

-- Logical operators for each language
local logical_operators = {
  javascript = { ["&&"] = true, ["||"] = true },
  typescript = { ["&&"] = true, ["||"] = true },
  python = { ["and"] = true, ["or"] = true },
  c = { ["&&"] = true, ["||"] = true },
  cpp = { ["&&"] = true, ["||"] = true },
  java = { ["&&"] = true, ["||"] = true },
  go = { ["&&"] = true, ["||"] = true },
  rust = { ["&&"] = true, ["||"] = true }
}

-- Get control flow patterns for a language
-- @param lang string Language identifier
-- @return table List of pattern names
M.get_patterns = function(lang)
  return control_flow_patterns[lang] or {}
end

-- Check if node type is a decision point
-- @param node_type string
-- @param lang string
-- @return boolean
M.is_decision_point = function(node_type, lang)
  local patterns = control_flow_patterns[lang]
  if not patterns then
    return false
  end

  for _, pattern in ipairs(patterns) do
    if node_type == pattern then
      return true
    end
  end

  return false
end

-- Check if operator is logical (&&, ||, and, or)
-- @param operator string
-- @param lang string
-- @return boolean
M.is_logical_operator = function(operator, lang)
  local lang_operators = logical_operators[lang]
  if not lang_operators then
    return false
  end

  return lang_operators[operator] == true
end

-- Count complexity from a structured node representation
-- @param node_data table { type: string, children: table[], operator?: string }
-- @param lang string Language identifier
-- @return number Complexity count (decision points only, not including base)
M.count_complexity = function(node_data, lang)
  local count = 0

  local function traverse(node)
    if not node then
      return
    end

    local node_type = node.type

    -- Check if this node is a decision point
    if M.is_decision_point(node_type, lang) then
      count = count + 1
    end

    -- Check for logical operators in binary expressions
    if node_type == "binary_expression" and node.operator then
      if M.is_logical_operator(node.operator, lang) then
        count = count + 1
      end
    end

    -- Check for boolean operators (Python)
    if node_type == "boolean_operator" and node.operator then
      if M.is_logical_operator(node.operator, lang) then
        count = count + 1
      end
    end

    -- Recursively traverse children
    if node.children then
      for _, child in ipairs(node.children) do
        traverse(child)
      end
    end
  end

  -- Start traversal from root's children (not counting the root itself)
  if node_data.children then
    for _, child in ipairs(node_data.children) do
      traverse(child)
    end
  end

  return count
end

return M
