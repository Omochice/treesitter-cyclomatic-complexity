local expect = MiniTest.expect

local display = require("treesitter-cyclomatic-complexity.display")
local config = require("treesitter-cyclomatic-complexity.config")

local bufnr
local ns = vim.api.nvim_create_namespace("treesitter-cyclomatic-complexity")

describe("display", function()
	before_each(function()
		config.setup({})
		display.setup()
		bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_set_current_buf(bufnr)
	end)

	after_each(function()
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end)

	describe("show_complexity()", function()
		describe("given low complexity value", function()
			it("should create extmark with correct text and highlight", function()
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "function foo()", "end" })
				display.show_complexity(bufnr, 0, 3)

				local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
				expect.equality(#marks, 1)

				local details = marks[1][4]
				expect.equality(details.virt_text[1][1], "CC: 3")
				expect.equality(details.virt_text[1][2], "CyclomaticComplexityLow")
			end)
		end)

		describe("given very high complexity value", function()
			it("should use CyclomaticComplexityVeryHigh highlight", function()
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "function foo()", "end" })
				display.show_complexity(bufnr, 0, 16)

				local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
				local details = marks[1][4]
				expect.equality(details.virt_text[1][1], "CC: 16")
				expect.equality(details.virt_text[1][2], "CyclomaticComplexityVeryHigh")
			end)
		end)

		describe("given specific line", function()
			it("should place extmark on that line", function()
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "line 0", "line 1", "line 2" })
				display.show_complexity(bufnr, 1, 5)

				local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
				expect.equality(#marks, 1)
				expect.equality(marks[1][2], 1)
			end)
		end)

		describe("given multiple calls", function()
			it("should create extmark for each call", function()
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "func a", "func b", "func c" })
				display.show_complexity(bufnr, 0, 2)
				display.show_complexity(bufnr, 1, 7)
				display.show_complexity(bufnr, 2, 12)

				local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
				expect.equality(#marks, 3)
			end)
		end)
	end)

	describe("clear_complexity()", function()
		describe("given buffer with extmarks", function()
			it("should remove all extmarks when called without line", function()
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "line 0", "line 1" })
				display.show_complexity(bufnr, 0, 3)
				display.show_complexity(bufnr, 1, 5)

				display.clear_complexity(bufnr)

				local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
				expect.equality(#marks, 0)
			end)

			it("should remove only specified line when line is given", function()
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "line 0", "line 1" })
				display.show_complexity(bufnr, 0, 3)
				display.show_complexity(bufnr, 1, 5)

				display.clear_complexity(bufnr, 0)

				local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
				expect.equality(#marks, 1)
			end)
		end)
	end)

	describe("toggle_display()", function()
		describe("given buffer with existing extmarks", function()
			it("should clear all extmarks", function()
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "line 0" })
				display.show_complexity(bufnr, 0, 3)

				display.toggle_display(bufnr)

				local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
				expect.equality(#marks, 0)
			end)
		end)
	end)

	describe("format_complexity_text()", function()
		describe("given default format", function()
			it("should format as 'CC: N'", function()
				expect.equality(display.format_complexity_text(5), "CC: 5")
			end)
		end)

		describe("given custom format", function()
			it("should use provided format string", function()
				expect.equality(display.format_complexity_text(5, "Complexity: %d"), "Complexity: 5")
			end)
		end)
	end)

	describe("get_highlight_group()", function()
		it("should return correct highlight group for each level", function()
			local thresholds = { low = 5, medium = 10, high = 15 }
			expect.equality(display.get_highlight_group(3, thresholds), "CyclomaticComplexityLow")
			expect.equality(display.get_highlight_group(7, thresholds), "CyclomaticComplexityMedium")
			expect.equality(display.get_highlight_group(12, thresholds), "CyclomaticComplexityHigh")
			expect.equality(display.get_highlight_group(20, thresholds), "CyclomaticComplexityVeryHigh")
		end)
	end)
end)
