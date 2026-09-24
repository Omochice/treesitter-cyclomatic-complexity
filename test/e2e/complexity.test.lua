local expect = MiniTest.expect

local complexity = require("treesitter-cyclomatic-complexity.complexity")
local counter = require("treesitter-cyclomatic-complexity.complexity.counter")
local config = require("treesitter-cyclomatic-complexity.config")
local parser = require("treesitter-cyclomatic-complexity.parser")

local bufnr

-- Counting runs on node types produced by a real grammar, which the fabricated
-- node data in test/helpers.lua cannot expose to a name the grammar dropped.
local function function_complexity(lines, lang)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.bo[bufnr].filetype = lang

	local nodes = parser.get_function_nodes(bufnr, lang)
	expect.equality(#nodes, 1)

	return complexity.calculate_function_complexity_from_node(nodes[1].node, bufnr, lang)
end

describe("complexity", function()
	before_each(function()
		bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_set_current_buf(bufnr)
	end)

	after_each(function()
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end)

	describe("cyclomatic metric", function()
		before_each(function()
			config.setup({ metric = "cyclomatic" })
		end)

		describe("given typescript function with a ternary expression", function()
			it("should count the ternary as a decision point", function()
				local value = function_complexity({
					"function pick(flag: boolean): number {",
					"  return flag ? 1 : 2;",
					"}",
				}, "typescript")

				expect.equality(value, 2)
			end)
		end)

		describe("given typescript function with a switch case", function()
			it("should count the case as a decision point", function()
				local value = function_complexity({
					"function pick(x: number): number {",
					"  switch (x) {",
					"    case 1:",
					"      return 1;",
					"  }",
					"  return 0;",
					"}",
				}, "typescript")

				expect.equality(value, 3)
			end)

			it("should not count an added default as a decision point", function()
				local value = function_complexity({
					"function pick(x: number): number {",
					"  switch (x) {",
					"    case 1:",
					"      return 1;",
					"    default:",
					"      return 0;",
					"  }",
					"}",
				}, "typescript")

				expect.equality(value, 3)
			end)
		end)

		describe("given go function with a switch statement", function()
			it("should count the switch as a decision point", function()
				local value = function_complexity({
					"package main",
					"",
					"func pick(x int) int {",
					"\tswitch x {",
					"\tcase 1:",
					"\t\treturn 1",
					"\t}",
					"\treturn 0",
					"}",
				}, "go")

				expect.equality(value, 3)
			end)
		end)
	end)

	describe("cognitive metric", function()
		before_each(function()
			config.setup({ metric = "cognitive" })
		end)

		describe("given typescript function with a ternary expression", function()
			it("should increment for the ternary", function()
				local value = function_complexity({
					"function pick(flag: boolean): number {",
					"  return flag ? 1 : 2;",
					"}",
				}, "typescript")

				expect.equality(value, 1)
			end)
		end)

		describe("given go function with a switch statement", function()
			it("should increment for the switch", function()
				local value = function_complexity({
					"package main",
					"",
					"func pick(x int) int {",
					"\tswitch x {",
					"\tcase 1:",
					"\t\treturn 1",
					"\t}",
					"\treturn 0",
					"}",
				}, "go")

				expect.equality(value, 1)
			end)
		end)

		describe("given lua function with an else branch", function()
			it("should increment for the else", function()
				local value = function_complexity({
					"local function pick(flag)",
					"  if flag then",
					"    return 1",
					"  else",
					"    return 2",
					"  end",
					"end",
				}, "lua")

				expect.equality(value, 2)
			end)
		end)
	end)

	describe("get_patterns()", function()
		-- A pattern the grammar does not define never matches, so the construct is
		-- dropped from the count without any error to point at it.
		for _, lang in ipairs(parser.get_supported_languages()) do
			describe("given " .. lang, function()
				it("should name only node types the grammar defines", function()
					for _, pattern in ipairs(counter.get_patterns(lang)) do
						expect.no_error(function()
							vim.treesitter.query.parse(lang, "(" .. pattern .. ") @pattern")
						end)
					end
				end)
			end)
		end
	end)
end)
