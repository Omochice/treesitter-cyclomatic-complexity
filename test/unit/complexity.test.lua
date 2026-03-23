local T = MiniTest.new_set()
local expect = MiniTest.expect

local complexity = require("treesitter-cyclomatic-complexity.complexity")
local helpers = dofile("test/helpers.lua")

T["complexity"] = MiniTest.new_set()

-- describe calculate_function_complexity()
T["complexity"]["calculate_function_complexity()"] = MiniTest.new_set()

T["complexity"]["calculate_function_complexity()"]["given empty function"] = MiniTest.new_set()

T["complexity"]["calculate_function_complexity()"]["given empty function"]["should return 1 as base complexity"] = function()
	local node_data = helpers.make_function("lua", {})
	expect.equality(complexity.calculate_function_complexity(node_data, "lua"), 1)
end

T["complexity"]["calculate_function_complexity()"]["given function with single if"] = MiniTest.new_set()

T["complexity"]["calculate_function_complexity()"]["given function with single if"]["should return 2"] = function()
	local node_data = helpers.make_function("lua", { helpers.if_node({}) })
	expect.equality(complexity.calculate_function_complexity(node_data, "lua"), 2)
end

T["complexity"]["calculate_function_complexity()"]["given function with multiple control flows"] = MiniTest.new_set()

T["complexity"]["calculate_function_complexity()"]["given function with multiple control flows"]["should sum all decision points plus base"] = function()
	local node_data = helpers.make_function("lua", {
		helpers.if_node({}),
		helpers.for_node({}),
		helpers.while_node({}),
	})
	expect.equality(complexity.calculate_function_complexity(node_data, "lua"), 4)
end

T["complexity"]["calculate_function_complexity()"]["given nested structures"] = MiniTest.new_set()

T["complexity"]["calculate_function_complexity()"]["given nested structures"]["should count all nested decision points"] = function()
	local node_data = helpers.make_function("lua", {
		helpers.if_node({ helpers.for_node({ helpers.while_node({}) }) }),
	})
	expect.equality(complexity.calculate_function_complexity(node_data, "lua"), 4)
end

T["complexity"]["calculate_function_complexity()"]["given logical operators"] = MiniTest.new_set()

T["complexity"]["calculate_function_complexity()"]["given logical operators"]["should count logical operators as decision points"] = function()
	local node_data = helpers.make_function("javascript", {
		helpers.if_node({ helpers.binary_expr("&&", {}) }),
	})
	expect.equality(complexity.calculate_function_complexity(node_data, "javascript"), 3)
end

T["complexity"]["calculate_function_complexity()"]["given unsupported language"] = MiniTest.new_set()

T["complexity"]["calculate_function_complexity()"]["given unsupported language"]["should return 1 as base complexity only"] = function()
	local node_data = helpers.make_node("function_definition", { helpers.if_node({}) })
	expect.equality(complexity.calculate_function_complexity(node_data, "unsupported"), 1)
end

-- describe calculate_loop_complexity()
T["complexity"]["calculate_loop_complexity()"] = MiniTest.new_set()

T["complexity"]["calculate_loop_complexity()"]["given simple loop"] = MiniTest.new_set()

T["complexity"]["calculate_loop_complexity()"]["given simple loop"]["should return 1 as base complexity"] = function()
	local node_data = helpers.for_node({})
	expect.equality(complexity.calculate_loop_complexity(node_data, "lua"), 1)
end

T["complexity"]["calculate_loop_complexity()"]["given loop with nested if"] = MiniTest.new_set()

T["complexity"]["calculate_loop_complexity()"]["given loop with nested if"]["should return 2"] = function()
	local node_data = helpers.for_node({ helpers.if_node({}) })
	expect.equality(complexity.calculate_loop_complexity(node_data, "lua"), 2)
end

T["complexity"]["calculate_loop_complexity()"]["given loop with multiple control flows"] = MiniTest.new_set()

T["complexity"]["calculate_loop_complexity()"]["given loop with multiple control flows"]["should sum all decision points plus base"] = function()
	local node_data = helpers.for_node({
		helpers.if_node({}),
		helpers.while_node({}),
	})
	expect.equality(complexity.calculate_loop_complexity(node_data, "lua"), 3)
end

T["complexity"]["calculate_loop_complexity()"]["given unsupported language"] = MiniTest.new_set()

T["complexity"]["calculate_loop_complexity()"]["given unsupported language"]["should return 1 as base complexity only"] = function()
	local node_data = helpers.for_node({ helpers.if_node({}) })
	expect.equality(complexity.calculate_loop_complexity(node_data, "unsupported"), 1)
end

-- describe get_complexity_level()
T["complexity"]["get_complexity_level()"] = MiniTest.new_set()

T["complexity"]["get_complexity_level()"]["should delegate to levels module"] = function()
	local thresholds = { low = 5, medium = 10, high = 15 }
	expect.equality(complexity.get_complexity_level(1, thresholds), "low")
	expect.equality(complexity.get_complexity_level(6, thresholds), "medium")
	expect.equality(complexity.get_complexity_level(11, thresholds), "high")
	expect.equality(complexity.get_complexity_level(16, thresholds), "very_high")
end

-- describe calculate_node_complexity()
T["complexity"]["calculate_node_complexity()"] = MiniTest.new_set()

T["complexity"]["calculate_node_complexity()"]["given function type"] = MiniTest.new_set()

T["complexity"]["calculate_node_complexity()"]["given function type"]["should calculate function complexity"] = function()
	local node_info = {
		type = "function",
		node_data = helpers.make_function("lua", { helpers.if_node({}) }),
	}
	expect.equality(complexity.calculate_node_complexity(node_info, "lua"), 2)
end

T["complexity"]["calculate_node_complexity()"]["given loop type"] = MiniTest.new_set()

T["complexity"]["calculate_node_complexity()"]["given loop type"]["should calculate loop complexity"] = function()
	local node_info = {
		type = "loop",
		node_data = helpers.for_node({ helpers.if_node({}) }),
	}
	expect.equality(complexity.calculate_node_complexity(node_info, "lua"), 2)
end

T["complexity"]["calculate_node_complexity()"]["given unknown type"] = MiniTest.new_set()

T["complexity"]["calculate_node_complexity()"]["given unknown type"]["should return 1"] = function()
	local node_info = {
		type = "unknown",
		node_data = helpers.make_node("unknown", {}),
	}
	expect.equality(complexity.calculate_node_complexity(node_info, "lua"), 1)
end

return T
