-- Complexity level determination
-- Pure functions - no Neovim API dependencies

local M = {}

-- Default thresholds for complexity levels
M.default_thresholds = {
  low = 5,
  medium = 10,
  high = 15
}

-- Get complexity level based on value and thresholds
-- @param complexity number The complexity value
-- @param thresholds table { low: number, medium: number, high: number }
-- @return string "low" | "medium" | "high" | "very_high"
M.get_level = function(complexity, thresholds)
  if complexity <= thresholds.low then
    return "low"
  elseif complexity <= thresholds.medium then
    return "medium"
  elseif complexity <= thresholds.high then
    return "high"
  else
    return "very_high"
  end
end

return M
