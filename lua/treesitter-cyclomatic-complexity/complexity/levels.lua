-- Complexity level determination
-- Pure functions - no Neovim API dependencies

local M = {}

-- Default thresholds per metric, anchored on the limit each metric publishes:
-- 10 for cyclomatic, recorded in NIST SP 500-235 2.5, and 15 for cognitive,
-- which is the default of SonarSource's RSPEC-3776. The bands around each limit
-- keep the same proportions, so a level means the same thing whichever metric
-- is selected.
M.default_thresholds = {
	cyclomatic = {
		low = 5,
		medium = 10,
		high = 15,
	},
	cognitive = {
		low = 8,
		medium = 15,
		high = 23,
	},
}

-- Get the default thresholds for a metric
-- @param metric string|nil "cyclomatic" | "cognitive"
-- @return table { low: number, medium: number, high: number }
M.get_default_thresholds = function(metric)
	return M.default_thresholds[metric] or M.default_thresholds.cyclomatic
end

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
