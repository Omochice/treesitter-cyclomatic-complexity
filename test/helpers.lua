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

M.case_node = function(children)
	return M.make_node("case_clause", children)
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
