-- Complexity calculation facade
-- Main interface for complexity calculation

local counter = require("treesitter-cyclomatic-complexity.complexity.counter")
local levels = require("treesitter-cyclomatic-complexity.complexity.levels")

local M = {}

-- Supported languages list
local supported_languages = {
	lua = true,
	javascript = true,
	typescript = true,
	python = true,
	c = true,
	cpp = true,
	java = true,
	go = true,
	rust = true,
}

-- Check if language is supported
-- @param lang string Language identifier
-- @return boolean
local function is_language_supported(lang)
	return supported_languages[lang] == true
end

-- Calculate complexity for function node data
-- @param node_data table Structured node representation
-- @param lang string Language identifier
-- @return number Complexity value (base 1 + decision points)
M.calculate_function_complexity = function(node_data, lang)
	if not node_data or not is_language_supported(lang) then
		return 1 -- Base complexity
	end

	-- Start with base complexity of 1
	local base = 1

	-- Count control flow constructs
	local decision_points = counter.count_complexity(node_data, lang)

	return base + decision_points
end

-- Calculate complexity for loop node data
-- @param node_data table Structured node representation
-- @param lang string Language identifier
-- @return number Complexity value (base 1 + decision points)
M.calculate_loop_complexity = function(node_data, lang)
	if not node_data or not is_language_supported(lang) then
		return 1 -- Base complexity
	end

	-- Start with base complexity of 1
	local base = 1

	-- Count control flow constructs within the loop
	local decision_points = counter.count_complexity(node_data, lang)

	return base + decision_points
end

-- Calculate complexity based on node type
-- @param node_info table { type: string, node_data: table }
-- @param lang string Language identifier
-- @return number Complexity value
M.calculate_node_complexity = function(node_info, lang)
	if node_info.type == "function" then
		return M.calculate_function_complexity(node_info.node_data, lang)
	elseif node_info.type == "loop" then
		return M.calculate_loop_complexity(node_info.node_data, lang)
	end

	return 1
end

-- Get complexity level based on value and thresholds
-- @param complexity number
-- @param thresholds table { low: number, medium: number, high: number }
-- @return string "low" | "medium" | "high" | "very_high"
M.get_complexity_level = function(complexity, thresholds)
	return levels.get_level(complexity, thresholds)
end

-- Backward compatible: calculate complexity from treesitter node
-- @param func_node userdata Treesitter node
-- @param bufnr number Buffer number
-- @param lang string Language identifier
-- @return number Complexity value
M.calculate_function_complexity_from_node = function(func_node, bufnr, lang)
	-- Lazy load parser to avoid circular dependency
	local parser = require("treesitter-cyclomatic-complexity.parser")

	if not func_node or not is_language_supported(lang) then
		return 1
	end

	local node_data = parser.node_to_data(func_node, bufnr)
	return M.calculate_function_complexity(node_data, lang)
end

-- Backward compatible: calculate loop complexity from treesitter node
-- @param loop_node userdata Treesitter node
-- @param bufnr number Buffer number
-- @param lang string Language identifier
-- @return number Complexity value
M.calculate_loop_complexity_from_node = function(loop_node, bufnr, lang)
	-- Lazy load parser to avoid circular dependency
	local parser = require("treesitter-cyclomatic-complexity.parser")

	if not loop_node or not is_language_supported(lang) then
		return 1
	end

	local node_data = parser.node_to_data(loop_node, bufnr)
	return M.calculate_loop_complexity(node_data, lang)
end

-- Backward compatible: calculate node complexity from treesitter node info
-- @param node_info table { type: string, node: userdata }
-- @param bufnr number Buffer number
-- @param lang string Language identifier
-- @return number Complexity value
M.calculate_node_complexity_from_node = function(node_info, bufnr, lang)
	if node_info.type == "function" then
		return M.calculate_function_complexity_from_node(node_info.node, bufnr, lang)
	elseif node_info.type == "loop" then
		return M.calculate_loop_complexity_from_node(node_info.node, bufnr, lang)
	end

	return 1
end

-- Get all complexities for a buffer (backward compatible)
-- @param bufnr number Buffer number
-- @param lang string Language identifier
-- @return table[] Array of { node_info: table, complexity: number, type: string }
M.get_all_complexities = function(bufnr, lang)
	-- Lazy load parser to avoid circular dependency
	local parser = require("treesitter-cyclomatic-complexity.parser")

	local results = {}

	-- Get function complexities
	local function_nodes = parser.get_function_nodes(bufnr, lang)
	for _, node_info in ipairs(function_nodes) do
		local complexity = M.calculate_function_complexity_from_node(node_info.node, bufnr, lang)
		table.insert(results, {
			node_info = node_info,
			complexity = complexity,
			type = "function",
		})
	end

	-- Get loop complexities
	local loop_nodes = parser.get_loop_nodes(bufnr, lang)
	for _, node_info in ipairs(loop_nodes) do
		local complexity = M.calculate_loop_complexity_from_node(node_info.node, bufnr, lang)
		table.insert(results, {
			node_info = node_info,
			complexity = complexity,
			type = "loop",
		})
	end

	return results
end

-- Re-export useful items from submodules
M.default_thresholds = levels.default_thresholds
M.get_patterns = counter.get_patterns
M.is_decision_point = counter.is_decision_point
M.is_logical_operator = counter.is_logical_operator

return M
