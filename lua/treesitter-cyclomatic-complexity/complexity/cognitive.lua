-- Cognitive Complexity counter
-- Implements SonarQube's Cognitive Complexity metric

local M = {}

-- Constructs that receive +1 and +nesting_level
local nesting_incremented = {
	lua = {
		if_statement = true,
		for_statement = true,
		while_statement = true,
		repeat_statement = true,
	},
	javascript = {
		if_statement = true,
		for_statement = true,
		for_in_statement = true,
		for_of_statement = true,
		while_statement = true,
		do_statement = true,
		switch_statement = true,
		conditional_expression = true,
	},
	typescript = {
		if_statement = true,
		for_statement = true,
		for_in_statement = true,
		for_of_statement = true,
		while_statement = true,
		do_statement = true,
		switch_statement = true,
		conditional_expression = true,
	},
	python = {
		if_statement = true,
		for_statement = true,
		while_statement = true,
		conditional_expression = true,
	},
	c = {
		if_statement = true,
		for_statement = true,
		while_statement = true,
		do_statement = true,
		switch_statement = true,
		conditional_expression = true,
	},
	cpp = {
		if_statement = true,
		for_statement = true,
		while_statement = true,
		do_statement = true,
		for_range_loop = true,
		switch_statement = true,
		conditional_expression = true,
	},
	java = {
		if_statement = true,
		for_statement = true,
		enhanced_for_statement = true,
		while_statement = true,
		do_statement = true,
		switch_expression = true,
		ternary_expression = true,
	},
	go = {
		if_statement = true,
		for_statement = true,
		switch_statement = true,
		type_switch_statement = true,
		select_statement = true,
	},
	rust = {
		if_expression = true,
		match_expression = true,
		loop_expression = true,
		for_expression = true,
		while_expression = true,
	},
}

-- Constructs that receive +1 only (no nesting penalty)
-- Nesting for children is inherited from the parent, not further increased
local basic_increment = {
	lua = {
		else_clause = true,
		elseif_statement = true,
	},
	javascript = {
		else_clause = true,
		catch_clause = true,
	},
	typescript = {
		else_clause = true,
		catch_clause = true,
	},
	python = {
		elif_clause = true,
		else_clause = true,
		except_clause = true,
	},
	c = {
		else_clause = true,
	},
	cpp = {
		else_clause = true,
		catch_clause = true,
	},
	java = {
		catch_clause = true,
	},
	go = {},
	rust = {},
}

-- Logical operators per language
local logical_operators = {
	javascript = { ["&&"] = true, ["||"] = true },
	typescript = { ["&&"] = true, ["||"] = true },
	python = { ["and"] = true, ["or"] = true },
	c = { ["&&"] = true, ["||"] = true },
	cpp = { ["&&"] = true, ["||"] = true },
	java = { ["&&"] = true, ["||"] = true },
	go = { ["&&"] = true, ["||"] = true },
	rust = { ["&&"] = true, ["||"] = true },
}

-- Binary expression node types that may contain logical operators
local binary_expr_types = {
	binary_expression = true,
	boolean_operator = true,
}

-- Constructs that increase nesting for children without receiving nesting penalty
-- Needed for constructs whose parent (e.g. try_statement) does not increase nesting
local nesting_increasers = {
	lua = { function_definition = true },
	javascript = { catch_clause = true, arrow_function = true, function_expression = true },
	typescript = { catch_clause = true, arrow_function = true, function_expression = true },
	python = { except_clause = true, lambda = true },
	c = {},
	cpp = { catch_clause = true, lambda_expression = true },
	java = { catch_clause = true, lambda_expression = true },
	go = { func_literal = true },
	rust = { closure_expression = true },
}

-- Count cognitive complexity from a structured node representation
-- @param node_data table { type: string, children: table[], operator?: string }
-- @param lang string Language identifier
-- @return number Cognitive complexity count
-- Collect logical operator sequence from nested binary expressions
-- Returns +1 for each contiguous group of same operators, +1 for each switch
local function count_logical_operators(node, lang_ops)
	if not binary_expr_types[node.type] or not node.operator then
		return 0
	end

	if not lang_ops[node.operator] then
		return 0
	end

	local ops = {}

	-- Flatten the operator sequence left-to-right
	local function flatten(n)
		if not n then
			return
		end
		if binary_expr_types[n.type] and n.operator and lang_ops[n.operator] then
			if n.children then
				for _, child in ipairs(n.children) do
					flatten(child)
				end
			end
			table.insert(ops, n.operator)
		end
	end

	flatten(node)

	if #ops == 0 then
		return 0
	end

	-- Count: +1 for first operator, +1 for each switch to different operator
	local result = 1
	local prev = ops[1]
	for i = 2, #ops do
		if ops[i] ~= prev then
			result = result + 1
			prev = ops[i]
		end
	end

	return result
end

M.count_complexity = function(node_data, lang)
	local count = 0
	local lang_nesting = nesting_incremented[lang] or {}
	local lang_basic = basic_increment[lang] or {}
	local lang_increasers = nesting_increasers[lang] or {}
	local lang_ops = logical_operators[lang] or {}

	local function traverse(node, nesting, inside_logical)
		if not node then
			return
		end

		local next_nesting = nesting

		if lang_nesting[node.type] then
			count = count + 1 + nesting
			next_nesting = nesting + 1
		elseif lang_basic[node.type] then
			count = count + 1
		end

		-- Nesting increasers: constructs that increase nesting for children
		-- without necessarily receiving an increment themselves (e.g. catch, lambda)
		if lang_increasers[node.type] and not lang_nesting[node.type] then
			next_nesting = nesting + 1
		end

		-- Handle logical operators: count at the topmost binary expression
		if binary_expr_types[node.type] and node.operator and lang_ops[node.operator] and not inside_logical then
			count = count + count_logical_operators(node, lang_ops)
			-- Skip children that are part of the logical sequence to avoid double counting
			if node.children then
				for _, child in ipairs(node.children) do
					if binary_expr_types[child.type] and child.operator and lang_ops[child.operator] then
						traverse(child, next_nesting, true)
					else
						traverse(child, next_nesting, false)
					end
				end
			end
			return
		end

		if node.children then
			for _, child in ipairs(node.children) do
				traverse(child, next_nesting, inside_logical)
			end
		end
	end

	if node_data.children then
		for _, child in ipairs(node_data.children) do
			traverse(child, 0, false)
		end
	end

	return count
end

return M
