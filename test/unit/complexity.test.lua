local expect = MiniTest.expect

local complexity = require("treesitter-cyclomatic-complexity.complexity")
local helpers = dofile("test/helpers.lua")

describe("complexity", function()
	describe("calculate_function_complexity()", function()
		describe("given empty function", function()
			it("should return 1 as base complexity", function()
				local node_data = helpers.make_function("lua", {})
				expect.equality(complexity.calculate_function_complexity(node_data, "lua"), 1)
			end)
		end)

		describe("given function with single if", function()
			it("should return 2", function()
				local node_data = helpers.make_function("lua", { helpers.if_node({}) })
				expect.equality(complexity.calculate_function_complexity(node_data, "lua"), 2)
			end)
		end)

		describe("given function with multiple control flows", function()
			it("should sum all decision points plus base", function()
				local node_data = helpers.make_function("lua", {
					helpers.if_node({}),
					helpers.for_node({}),
					helpers.while_node({}),
				})
				expect.equality(complexity.calculate_function_complexity(node_data, "lua"), 4)
			end)
		end)

		describe("given nested structures", function()
			it("should count all nested decision points", function()
				local node_data = helpers.make_function("lua", {
					helpers.if_node({ helpers.for_node({ helpers.while_node({}) }) }),
				})
				expect.equality(complexity.calculate_function_complexity(node_data, "lua"), 4)
			end)
		end)

		describe("given logical operators", function()
			it("should count logical operators as decision points", function()
				local node_data = helpers.make_function("javascript", {
					helpers.if_node({ helpers.binary_expr("&&", {}) }),
				})
				expect.equality(complexity.calculate_function_complexity(node_data, "javascript"), 3)
			end)
		end)

		describe("given unsupported language", function()
			it("should return 1 as base complexity only", function()
				local node_data = helpers.make_node("function_definition", { helpers.if_node({}) })
				expect.equality(complexity.calculate_function_complexity(node_data, "unsupported"), 1)
			end)
		end)
	end)

	describe("calculate_loop_complexity()", function()
		describe("given simple loop", function()
			it("should return 1 as base complexity", function()
				local node_data = helpers.for_node({})
				expect.equality(complexity.calculate_loop_complexity(node_data, "lua"), 1)
			end)
		end)

		describe("given loop with nested if", function()
			it("should return 2", function()
				local node_data = helpers.for_node({ helpers.if_node({}) })
				expect.equality(complexity.calculate_loop_complexity(node_data, "lua"), 2)
			end)
		end)

		describe("given loop with multiple control flows", function()
			it("should sum all decision points plus base", function()
				local node_data = helpers.for_node({
					helpers.if_node({}),
					helpers.while_node({}),
				})
				expect.equality(complexity.calculate_loop_complexity(node_data, "lua"), 3)
			end)
		end)

		describe("given unsupported language", function()
			it("should return 1 as base complexity only", function()
				local node_data = helpers.for_node({ helpers.if_node({}) })
				expect.equality(complexity.calculate_loop_complexity(node_data, "unsupported"), 1)
			end)
		end)
	end)

	describe("get_complexity_level()", function()
		it("should delegate to levels module", function()
			local thresholds = { low = 5, medium = 10, high = 15 }
			expect.equality(complexity.get_complexity_level(1, thresholds), "low")
			expect.equality(complexity.get_complexity_level(6, thresholds), "medium")
			expect.equality(complexity.get_complexity_level(11, thresholds), "high")
			expect.equality(complexity.get_complexity_level(16, thresholds), "very_high")
		end)
	end)

	describe("calculate_node_complexity()", function()
		describe("given function type", function()
			it("should calculate function complexity", function()
				local node_info = {
					type = "function",
					node_data = helpers.make_function("lua", { helpers.if_node({}) }),
				}
				expect.equality(complexity.calculate_node_complexity(node_info, "lua"), 2)
			end)
		end)

		describe("given loop type", function()
			it("should calculate loop complexity", function()
				local node_info = {
					type = "loop",
					node_data = helpers.for_node({ helpers.if_node({}) }),
				}
				expect.equality(complexity.calculate_node_complexity(node_info, "lua"), 2)
			end)
		end)

		describe("given unknown type", function()
			it("should return 1", function()
				local node_info = {
					type = "unknown",
					node_data = helpers.make_node("unknown", {}),
				}
				expect.equality(complexity.calculate_node_complexity(node_info, "lua"), 1)
			end)
		end)
	end)
end)
