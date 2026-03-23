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
    ]],
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
    ]],
	},
	typescript = {
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
    ]],
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
    ]],
	},
	c = {
		functions = [[
      (function_definition declarator: (function_declarator declarator: (identifier) @name)) @function
      (function_declarator declarator: (identifier) @name) @function
    ]],
		loops = [[
      (for_statement) @loop
      (while_statement) @loop
      (do_statement) @loop
    ]],
		control_flow = [[
      (if_statement) @control
      (for_statement) @control
      (while_statement) @control
      (do_statement) @control
      (switch_statement) @control
      (conditional_expression) @control
    ]],
	},
	cpp = {
		functions = [[
      (function_definition declarator: (function_declarator declarator: (identifier) @name)) @function
      (function_declarator declarator: (identifier) @name) @function
    ]],
		loops = [[
      (for_statement) @loop
      (while_statement) @loop
      (do_statement) @loop
      (for_range_loop) @loop
    ]],
		control_flow = [[
      (if_statement) @control
      (for_statement) @control
      (while_statement) @control
      (do_statement) @control
      (for_range_loop) @control
      (switch_statement) @control
      (try_statement) @control
      (conditional_expression) @control
    ]],
	},
	java = {
		functions = [[
      (method_declaration name: (identifier) @name) @function
      (constructor_declaration name: (identifier) @name) @function
    ]],
		loops = [[
      (for_statement) @loop
      (enhanced_for_statement) @loop
      (while_statement) @loop
      (do_statement) @loop
    ]],
		control_flow = [[
      (if_statement) @control
      (for_statement) @control
      (enhanced_for_statement) @control
      (while_statement) @control
      (do_statement) @control
      (switch_expression) @control
      (try_statement) @control
      (ternary_expression) @control
    ]],
	},
	go = {
		functions = [[
      (function_declaration name: (identifier) @name) @function
      (method_declaration name: (field_identifier) @name) @function
    ]],
		loops = [[
      (for_statement) @loop
      (range_clause) @loop
    ]],
		control_flow = [[
      (if_statement) @control
      (for_statement) @control
      (switch_statement) @control
      (type_switch_statement) @control
      (select_statement) @control
    ]],
	},
	rust = {
		functions = [[
      (function_item name: (identifier) @name) @function
    ]],
		loops = [[
      (loop_expression) @loop
      (for_expression) @loop
      (while_expression) @loop
    ]],
		control_flow = [[
      (if_expression) @control
      (match_expression) @control
      (loop_expression) @control
      (for_expression) @control
      (while_expression) @control
    ]],
	},
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
			type = "function",
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
			type = "loop",
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
		end_col = end_col,
	}
end

-- Convert treesitter node to structured data for pure calculation functions
-- @param node userdata Treesitter node
-- @param bufnr number Buffer number
-- @return table { type: string, children: table[], operator?: string }
M.node_to_data = function(node, bufnr)
	if not node then
		return nil
	end

	local node_type = node:type()
	local result = {
		type = node_type,
		children = {},
	}

	-- Extract operator for binary expressions
	if node_type == "binary_expression" or node_type == "boolean_operator" then
		-- Find operator child
		for i = 0, node:child_count() - 1 do
			local child = node:child(i)
			if child then
				local child_type = child:type()
				-- Common operator types in treesitter
				if child_type:match("^[%+%-%*%/%%&|<>=!]+$") or child_type == "and" or child_type == "or" then
					result.operator = vim.treesitter.get_node_text(child, bufnr)
					break
				end
			end
		end
	end

	-- Recursively convert children
	for i = 0, node:child_count() - 1 do
		local child = node:child(i)
		if child then
			local child_data = M.node_to_data(child, bufnr)
			if child_data then
				table.insert(result.children, child_data)
			end
		end
	end

	return result
end

-- Get function nodes with structured data for calculation
-- @param bufnr number
-- @param lang string
-- @return table[] Array of { node_data: table, start_row: number, type: string }
M.get_function_nodes_with_data = function(bufnr, lang)
	local nodes = M.get_function_nodes(bufnr, lang)
	local results = {}

	for _, node_info in ipairs(nodes) do
		local node_data = M.node_to_data(node_info.node, bufnr)
		table.insert(results, {
			node = node_info.node, -- Keep original for backward compatibility
			node_data = node_data,
			start_row = node_info.start_row,
			start_col = node_info.start_col,
			end_row = node_info.end_row,
			end_col = node_info.end_col,
			type = "function",
		})
	end

	return results
end

-- Get loop nodes with structured data for calculation
-- @param bufnr number
-- @param lang string
-- @return table[] Array of { node_data: table, start_row: number, type: string }
M.get_loop_nodes_with_data = function(bufnr, lang)
	local nodes = M.get_loop_nodes(bufnr, lang)
	local results = {}

	for _, node_info in ipairs(nodes) do
		local node_data = M.node_to_data(node_info.node, bufnr)
		table.insert(results, {
			node = node_info.node, -- Keep original for backward compatibility
			node_data = node_data,
			start_row = node_info.start_row,
			start_col = node_info.start_col,
			end_row = node_info.end_row,
			end_col = node_info.end_col,
			type = "loop",
		})
	end

	return results
end

return M
