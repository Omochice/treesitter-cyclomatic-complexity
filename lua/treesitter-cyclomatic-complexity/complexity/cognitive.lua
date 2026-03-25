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
	},
	typescript = {
		if_statement = true,
		for_statement = true,
		for_in_statement = true,
		for_of_statement = true,
		while_statement = true,
		do_statement = true,
		switch_statement = true,
	},
	python = {
		if_statement = true,
		for_statement = true,
		while_statement = true,
	},
	c = {
		if_statement = true,
		for_statement = true,
		while_statement = true,
		do_statement = true,
		switch_statement = true,
	},
	cpp = {
		if_statement = true,
		for_statement = true,
		while_statement = true,
		do_statement = true,
		for_range_loop = true,
		switch_statement = true,
	},
	java = {
		if_statement = true,
		for_statement = true,
		enhanced_for_statement = true,
		while_statement = true,
		do_statement = true,
		switch_expression = true,
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

-- Constructs that receive +1 only (no nesting penalty) but increase nesting for children
local basic_increment = {
	lua = {
		else_clause = true,
		elseif_statement = true,
	},
	python = {
		elif_clause = true,
		else_clause = true,
	},
}

-- Count cognitive complexity from a structured node representation
-- @param node_data table { type: string, children: table[], operator?: string }
-- @param lang string Language identifier
-- @return number Cognitive complexity count
M.count_complexity = function(node_data, lang)
	local count = 0
	local lang_nesting = nesting_incremented[lang] or {}
	local lang_basic = basic_increment[lang] or {}

	local function traverse(node, nesting)
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

		if node.children then
			for _, child in ipairs(node.children) do
				traverse(child, next_nesting)
			end
		end
	end

	if node_data.children then
		for _, child in ipairs(node_data.children) do
			traverse(child, 0)
		end
	end

	return count
end

return M
