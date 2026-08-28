-- Test helpers for cyclomatic complexity tests

local M = {}

-- Create a simple node_data structure for testing
-- @param node_type string The type of the node
-- @param children table[] Optional child nodes
-- @param operator string|nil Optional operator for binary expressions
-- @return table node_data structure
M.make_node = function(node_type, children, operator)
	return {
		type = node_type,
		children = children or {},
		operator = operator,
	}
end

-- Create a function node with children
-- @param lang string Language identifier
-- @param children table[] Child nodes
-- @return table node_data structure
M.make_function = function(lang, children)
	local func_types = {
		lua = "function_definition",
		javascript = "function_declaration",
		typescript = "function_declaration",
		python = "function_definition",
		c = "function_definition",
		cpp = "function_definition",
		java = "method_declaration",
		go = "function_declaration",
		rust = "function_item",
	}

	return M.make_node(func_types[lang] or "function_definition", children)
end

-- Create common control flow nodes
M.if_node = function(children)
	return M.make_node("if_statement", children)
end

M.for_node = function(children)
	return M.make_node("for_statement", children)
end

M.while_node = function(children)
	return M.make_node("while_statement", children)
end

M.switch_node = function(children)
	return M.make_node("switch_statement", children)
end

-- Node types whose name differs between grammars are keyed by language, the
-- same way make_function is, so a test cannot assert a name the language it
-- names never produces.
local case_types = {
	javascript = "switch_case",
	typescript = "switch_case",
	java = "switch_label",
	go = "expression_case",
}

M.case_node = function(lang, children)
	return M.make_node(case_types[lang] or "case_statement", children)
end

M.try_node = function(children)
	return M.make_node("try_statement", children)
end

M.catch_node = function(children)
	return M.make_node("catch_clause", children)
end

M.binary_expr = function(operator, children)
	return M.make_node("binary_expression", children, operator)
end

M.boolean_op = function(operator, children)
	return M.make_node("boolean_operator", children, operator)
end

M.lambda_node = function(children)
	return M.make_node("arrow_function", children)
end

M.nested_function_node = function(children)
	return M.make_node("function_expression", children)
end

local ternary_types = {
	javascript = "ternary_expression",
	typescript = "ternary_expression",
	java = "ternary_expression",
}

M.ternary_node = function(lang, children)
	return M.make_node(ternary_types[lang] or "conditional_expression", children)
end

local else_types = {
	lua = "else_statement",
}

M.else_node = function(lang, children)
	return M.make_node(else_types[lang] or "else_clause", children)
end

-- Python specific
M.elif_node = function(children)
	return M.make_node("elif_clause", children)
end

-- Lua specific
M.elseif_node = function(children)
	return M.make_node("elseif_statement", children)
end

M.repeat_node = function(children)
	return M.make_node("repeat_statement", children)
end

return M
