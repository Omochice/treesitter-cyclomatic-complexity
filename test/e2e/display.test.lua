local expect = MiniTest.expect

local display = require("treesitter-cyclomatic-complexity.display")
local config = require("treesitter-cyclomatic-complexity.config")

local bufnr
local ns = vim.api.nvim_create_namespace("treesitter-cyclomatic-complexity")

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			config.setup({})
			display.setup()
			bufnr = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_set_current_buf(bufnr)
		end,
		post_case = function()
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end,
	},
})

T["display"] = MiniTest.new_set()

-- describe show_complexity()
T["display"]["show_complexity()"] = MiniTest.new_set()

T["display"]["show_complexity()"]["given low complexity value"] = MiniTest.new_set()

T["display"]["show_complexity()"]["given low complexity value"]["should create extmark with correct text and highlight"] = function()
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "function foo()", "end" })
	display.show_complexity(bufnr, 0, 3)

	local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
	expect.equality(#marks, 1)

	local details = marks[1][4]
	expect.equality(details.virt_text[1][1], "CC: 3")
	expect.equality(details.virt_text[1][2], "CyclomaticComplexityLow")
end

T["display"]["show_complexity()"]["given very high complexity value"] = MiniTest.new_set()

T["display"]["show_complexity()"]["given very high complexity value"]["should use CyclomaticComplexityVeryHigh highlight"] = function()
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "function foo()", "end" })
	display.show_complexity(bufnr, 0, 16)

	local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
	local details = marks[1][4]
	expect.equality(details.virt_text[1][1], "CC: 16")
	expect.equality(details.virt_text[1][2], "CyclomaticComplexityVeryHigh")
end

T["display"]["show_complexity()"]["given specific line"] = MiniTest.new_set()

T["display"]["show_complexity()"]["given specific line"]["should place extmark on that line"] = function()
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "line 0", "line 1", "line 2" })
	display.show_complexity(bufnr, 1, 5)

	local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
	expect.equality(#marks, 1)
	expect.equality(marks[1][2], 1)
end

T["display"]["show_complexity()"]["given multiple calls"] = MiniTest.new_set()

T["display"]["show_complexity()"]["given multiple calls"]["should create extmark for each call"] = function()
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "func a", "func b", "func c" })
	display.show_complexity(bufnr, 0, 2)
	display.show_complexity(bufnr, 1, 7)
	display.show_complexity(bufnr, 2, 12)

	local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
	expect.equality(#marks, 3)
end

-- describe clear_complexity()
T["display"]["clear_complexity()"] = MiniTest.new_set()

T["display"]["clear_complexity()"]["given buffer with extmarks"] = MiniTest.new_set()

T["display"]["clear_complexity()"]["given buffer with extmarks"]["should remove all extmarks when called without line"] = function()
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "line 0", "line 1" })
	display.show_complexity(bufnr, 0, 3)
	display.show_complexity(bufnr, 1, 5)

	display.clear_complexity(bufnr)

	local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
	expect.equality(#marks, 0)
end

T["display"]["clear_complexity()"]["given buffer with extmarks"]["should remove only specified line when line is given"] = function()
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "line 0", "line 1" })
	display.show_complexity(bufnr, 0, 3)
	display.show_complexity(bufnr, 1, 5)

	display.clear_complexity(bufnr, 0)

	local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
	expect.equality(#marks, 1)
end

-- describe toggle_display()
T["display"]["toggle_display()"] = MiniTest.new_set()

T["display"]["toggle_display()"]["given buffer with existing extmarks"] = MiniTest.new_set()

T["display"]["toggle_display()"]["given buffer with existing extmarks"]["should clear all extmarks"] = function()
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "line 0" })
	display.show_complexity(bufnr, 0, 3)

	display.toggle_display(bufnr)

	local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
	expect.equality(#marks, 0)
end

-- describe format_complexity_text()
T["display"]["format_complexity_text()"] = MiniTest.new_set()

T["display"]["format_complexity_text()"]["given default format"] = MiniTest.new_set()

T["display"]["format_complexity_text()"]["given default format"]["should format as 'CC: N'"] = function()
	expect.equality(display.format_complexity_text(5), "CC: 5")
end

T["display"]["format_complexity_text()"]["given custom format"] = MiniTest.new_set()

T["display"]["format_complexity_text()"]["given custom format"]["should use provided format string"] = function()
	expect.equality(display.format_complexity_text(5, "Complexity: %d"), "Complexity: 5")
end

-- describe get_highlight_group()
T["display"]["get_highlight_group()"] = MiniTest.new_set()

T["display"]["get_highlight_group()"]["should return correct highlight group for each level"] = function()
	local thresholds = { low = 5, medium = 10, high = 15 }
	expect.equality(display.get_highlight_group(3, thresholds), "CyclomaticComplexityLow")
	expect.equality(display.get_highlight_group(7, thresholds), "CyclomaticComplexityMedium")
	expect.equality(display.get_highlight_group(12, thresholds), "CyclomaticComplexityHigh")
	expect.equality(display.get_highlight_group(20, thresholds), "CyclomaticComplexityVeryHigh")
end

return T
