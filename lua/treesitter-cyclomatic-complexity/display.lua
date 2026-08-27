local config = require("treesitter-cyclomatic-complexity.config")
local complexity = require("treesitter-cyclomatic-complexity.complexity")

local M = {}

local namespace = vim.api.nvim_create_namespace("treesitter-cyclomatic-complexity")

local highlight_groups = {
	low = "CyclomaticComplexityLow",
	medium = "CyclomaticComplexityMedium",
	high = "CyclomaticComplexityHigh",
	very_high = "CyclomaticComplexityVeryHigh",
}

-- Linking rather than hardcoding colors keeps the virtual text in tune with
-- whatever colorscheme is active, and inherits the `ctermfg` these groups carry,
-- so the levels stay distinguishable without 'termguicolors'.
-- The severity a level maps to follows McCabe's limit of 10, which NIST SP
-- 500-235 2.5 records along with the 15 some projects use instead: anything
-- within that limit stays informational, and warning starts once it is passed.
-- DiagnosticHint is avoided on purpose. Most colorschemes leave it at Neovim's
-- #D3D3D3, which is close enough to Normal to read as uncolored text.
-- `default = true` is what makes these survive `:colorscheme`: `hi clear` drops
-- attribute-based definitions but restores default links, so nothing has to
-- reapply them. It also leaves definitions made by the user or by a colorscheme
-- untouched, which `vim.fn.hlexists` cannot do: it keeps reporting a group as
-- existing after `hi clear` has emptied it.
local default_highlights = {
	CyclomaticComplexityLow = { link = "Comment", default = true },
	CyclomaticComplexityMedium = { link = "DiagnosticInfo", default = true },
	CyclomaticComplexityHigh = { link = "DiagnosticWarn", default = true },
	CyclomaticComplexityVeryHigh = { link = "DiagnosticError", default = true },
}

local function setup_highlight_groups()
	for group, attrs in pairs(default_highlights) do
		vim.api.nvim_set_hl(0, group, attrs)
	end
end

M.get_highlight_group = function(complexity_value, thresholds)
	local level = complexity.get_complexity_level(complexity_value, thresholds)
	return highlight_groups[level] or highlight_groups.low
end

M.format_complexity_text = function(complexity_value, format_string)
	return string.format(format_string or "CC: %d", complexity_value)
end

M.show_complexity = function(bufnr, line, complexity_value, opts)
	opts = opts or {}
	local thresholds = config.get("thresholds")
	local display_opts = config.get("display")

	local text = M.format_complexity_text(complexity_value, display_opts.format)
	local hl_group = M.get_highlight_group(complexity_value, thresholds)

	-- Create extmark with virtual text
	vim.api.nvim_buf_set_extmark(bufnr, namespace, line, -1, {
		virt_text = { { text, hl_group } },
		virt_text_pos = "eol",
		hl_mode = "combine",
	})
end

M.clear_complexity = function(bufnr, line)
	if line then
		-- Clear specific line
		vim.api.nvim_buf_clear_namespace(bufnr, namespace, line, line + 1)
	else
		-- Clear entire buffer
		vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
	end
end

M.update_display = function(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
	if not lang or not config.get("languages")[lang] then
		return
	end

	-- Clear existing displays
	M.clear_complexity(bufnr)

	-- Get all complexities for the buffer
	local complexities = complexity.get_all_complexities(bufnr, lang)

	-- Display complexity for each node
	for _, result in ipairs(complexities) do
		local line = result.node_info.start_row
		M.show_complexity(bufnr, line, result.complexity)
	end
end

M.toggle_display = function(bufnr)
	local marks = vim.api.nvim_buf_get_extmarks(bufnr, namespace, 0, -1, {})

	if #marks > 0 then
		-- Clear if currently displayed
		M.clear_complexity(bufnr)
	else
		-- Show if currently hidden
		M.update_display(bufnr)
	end
end

M.get_stats = function(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return nil
	end

	local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
	if not lang or not config.get("languages")[lang] then
		return nil
	end

	local complexities = complexity.get_all_complexities(bufnr, lang)
	local stats = {
		total_functions = 0,
		total_loops = 0,
		avg_complexity = 0,
		max_complexity = 0,
		distribution = { low = 0, medium = 0, high = 0, very_high = 0 },
	}

	local total_complexity = 0
	local thresholds = config.get("thresholds")

	for _, result in ipairs(complexities) do
		total_complexity = total_complexity + result.complexity

		if result.type == "function" then
			stats.total_functions = stats.total_functions + 1
		elseif result.type == "loop" then
			stats.total_loops = stats.total_loops + 1
		end

		if result.complexity > stats.max_complexity then
			stats.max_complexity = result.complexity
		end

		local level = complexity.get_complexity_level(result.complexity, thresholds)
		stats.distribution[level] = stats.distribution[level] + 1
	end

	if #complexities > 0 then
		stats.avg_complexity = total_complexity / #complexities
	end

	return stats
end

M.setup = function()
	setup_highlight_groups()
end

return M
