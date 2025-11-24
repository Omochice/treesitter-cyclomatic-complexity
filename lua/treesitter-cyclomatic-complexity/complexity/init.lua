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
  rust = true
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
    return 1  -- Base complexity
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
    return 1  -- Base complexity
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

-- Re-export useful items from submodules
M.default_thresholds = levels.default_thresholds
M.get_patterns = counter.get_patterns
M.is_decision_point = counter.is_decision_point
M.is_logical_operator = counter.is_logical_operator

return M
