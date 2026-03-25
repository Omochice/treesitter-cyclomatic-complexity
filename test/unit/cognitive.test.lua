local expect = MiniTest.expect

local cognitive = require("treesitter-cyclomatic-complexity.complexity.cognitive")
local helpers = dofile("test/helpers.lua")

describe("cognitive", function()
	describe("count_complexity()", function()
		describe("given empty function node", function()
			it("should return 0", function()
				local node_data = helpers.make_function("lua", {})
				expect.equality(cognitive.count_complexity(node_data, "lua"), 0)
			end)
		end)

		describe("given single if at nesting 0", function()
			it("should return 1", function()
				local node_data = helpers.make_function("lua", { helpers.if_node({}) })
				expect.equality(cognitive.count_complexity(node_data, "lua"), 1)
			end)
		end)

		describe("given single for at nesting 0", function()
			it("should return 1", function()
				local node_data = helpers.make_function("lua", { helpers.for_node({}) })
				expect.equality(cognitive.count_complexity(node_data, "lua"), 1)
			end)
		end)

		describe("given single while at nesting 0", function()
			it("should return 1", function()
				local node_data = helpers.make_function("lua", { helpers.while_node({}) })
				expect.equality(cognitive.count_complexity(node_data, "lua"), 1)
			end)
		end)

		describe("given if nested inside for", function()
			it("should return 3 (for:+1+0, if:+1+1)", function()
				local node_data = helpers.make_function("lua", {
					helpers.for_node({ helpers.if_node({}) }),
				})
				expect.equality(cognitive.count_complexity(node_data, "lua"), 3)
			end)
		end)

		describe("given deeply nested structures", function()
			it("should return 6 (for:+1+0, if:+1+1, while:+1+2)", function()
				local node_data = helpers.make_function("lua", {
					helpers.for_node({ helpers.if_node({ helpers.while_node({}) }) }),
				})
				expect.equality(cognitive.count_complexity(node_data, "lua"), 6)
			end)
		end)

		describe("given else clause", function()
			it("should return 2 (if:+1+0, else:+1 no nesting penalty)", function()
				local node_data = helpers.make_function("lua", {
					helpers.if_node({ helpers.else_node({}) }),
				})
				expect.equality(cognitive.count_complexity(node_data, "lua"), 2)
			end)
		end)

		describe("given elseif clause in lua", function()
			it("should return 2 (if:+1+0, elseif:+1 no nesting penalty)", function()
				local node_data = helpers.make_function("lua", {
					helpers.if_node({ helpers.elseif_node({}) }),
				})
				expect.equality(cognitive.count_complexity(node_data, "lua"), 2)
			end)
		end)

		describe("given elif clause in python", function()
			it("should return 2 (if:+1+0, elif:+1 no nesting penalty)", function()
				local node_data = helpers.make_function("python", {
					helpers.if_node({ helpers.elif_node({}) }),
				})
				expect.equality(cognitive.count_complexity(node_data, "python"), 2)
			end)
		end)

		describe("given if nested inside else", function()
			it("should return 4 (if:+1+0, else:+1, inner if:+1+1)", function()
				local node_data = helpers.make_function("lua", {
					helpers.if_node({ helpers.else_node({ helpers.if_node({}) }) }),
				})
				expect.equality(cognitive.count_complexity(node_data, "lua"), 4)
			end)
		end)
		describe("given switch with multiple cases in javascript", function()
			it("should return 1 (switch:+1+0, cases:+0)", function()
				local node_data = helpers.make_function("javascript", {
					helpers.switch_node({
						helpers.case_node({}),
						helpers.case_node({}),
						helpers.case_node({}),
					}),
				})
				expect.equality(cognitive.count_complexity(node_data, "javascript"), 1)
			end)
		end)

		describe("given switch nested inside if in javascript", function()
			it("should return 3 (if:+1+0, switch:+1+1)", function()
				local node_data = helpers.make_function("javascript", {
					helpers.if_node({ helpers.switch_node({ helpers.case_node({}) }) }),
				})
				expect.equality(cognitive.count_complexity(node_data, "javascript"), 3)
			end)
		end)
	end)
end)
