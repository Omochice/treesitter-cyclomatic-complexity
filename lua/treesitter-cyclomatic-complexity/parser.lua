local M = {}

local queries = {
	lua = {
		functions = [[
      (function_declaration name: (identifier) @name) @function
      (function_definition) @function
    ]],
		loops = [[
      (for_statement) @loop
      (while_statement) @loop
      (repeat_statement) @loop
    ]],
	},
	-- `for ... of` has no node of its own: the grammar parses it as
	-- `for_in_statement`, the same node `for ... in` produces.
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
      (while_statement) @loop
      (do_statement) @loop
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
      (while_statement) @loop
      (do_statement) @loop
    ]],
	},
	python = {
		-- `async def` produces a `function_definition` carrying an `async` token,
		-- not a node type of its own.
		functions = [[
      (function_definition name: (identifier) @name) @function
    ]],
		loops = [[
      (for_statement) @loop
      (while_statement) @loop
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

	-- The queries also capture @name so that named and anonymous functions can
	-- share one pattern; only @function marks the node complexity applies to.
	return vim.iter(query:iter_captures(root, bufnr))
		:filter(function(id)
			return query.captures[id] == "function"
		end)
		:map(function(_, node)
			local start_row, start_col, end_row, end_col = node:range()
			return {
				node = node,
				start_row = start_row,
				start_col = start_col,
				end_row = end_row,
				end_col = end_col,
				type = "function",
			}
		end)
		:totable()
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

M.get_node_text = function(node, bufnr)
	return vim.treesitter.get_node_text(node, bufnr)
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

return M
