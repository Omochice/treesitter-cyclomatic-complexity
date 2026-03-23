local T = MiniTest.new_set()
local expect = MiniTest.expect

local counter = require("treesitter-cyclomatic-complexity.complexity.counter")
local helpers = dofile("test/helpers.lua")

T["counter"] = MiniTest.new_set()

-- describe get_patterns()
T["counter"]["get_patterns()"] = MiniTest.new_set()

T["counter"]["get_patterns()"]["given lua"] = MiniTest.new_set()

T["counter"]["get_patterns()"]["given lua"]["should include control flow patterns"] = function()
	local patterns = counter.get_patterns("lua")
	expect.equality(type(patterns), "table")
	expect.equality(vim.tbl_contains(patterns, "if_statement"), true)
	expect.equality(vim.tbl_contains(patterns, "for_statement"), true)
	expect.equality(vim.tbl_contains(patterns, "while_statement"), true)
	expect.equality(vim.tbl_contains(patterns, "repeat_statement"), true)
end

T["counter"]["get_patterns()"]["given javascript"] = MiniTest.new_set()

T["counter"]["get_patterns()"]["given javascript"]["should include control flow patterns"] = function()
	local patterns = counter.get_patterns("javascript")
	expect.equality(type(patterns), "table")
	expect.equality(vim.tbl_contains(patterns, "if_statement"), true)
	expect.equality(vim.tbl_contains(patterns, "switch_statement"), true)
	expect.equality(vim.tbl_contains(patterns, "try_statement"), true)
end

T["counter"]["get_patterns()"]["given python"] = MiniTest.new_set()

T["counter"]["get_patterns()"]["given python"]["should include control flow patterns"] = function()
	local patterns = counter.get_patterns("python")
	expect.equality(type(patterns), "table")
	expect.equality(vim.tbl_contains(patterns, "if_statement"), true)
	expect.equality(vim.tbl_contains(patterns, "elif_clause"), true)
	expect.equality(vim.tbl_contains(patterns, "with_statement"), true)
end

T["counter"]["get_patterns()"]["given unsupported language"] = MiniTest.new_set()

T["counter"]["get_patterns()"]["given unsupported language"]["should return empty table"] = function()
	expect.equality(counter.get_patterns("unsupported"), {})
end

-- describe is_decision_point()
T["counter"]["is_decision_point()"] = MiniTest.new_set()

T["counter"]["is_decision_point()"]["given lua"] = MiniTest.new_set()

T["counter"]["is_decision_point()"]["given lua"]["should return true for if_statement"] = function()
	expect.equality(counter.is_decision_point("if_statement", "lua"), true)
end

T["counter"]["is_decision_point()"]["given lua"]["should return true for for_statement"] = function()
	expect.equality(counter.is_decision_point("for_statement", "lua"), true)
end

T["counter"]["is_decision_point()"]["given lua"]["should return true for while_statement"] = function()
	expect.equality(counter.is_decision_point("while_statement", "lua"), true)
end

T["counter"]["is_decision_point()"]["given lua"]["should return false for non-decision nodes"] = function()
	expect.equality(counter.is_decision_point("identifier", "lua"), false)
	expect.equality(counter.is_decision_point("function_definition", "lua"), false)
end

T["counter"]["is_decision_point()"]["given javascript"] = MiniTest.new_set()

T["counter"]["is_decision_point()"]["given javascript"]["should return true for control flow nodes"] = function()
	expect.equality(counter.is_decision_point("if_statement", "javascript"), true)
	expect.equality(counter.is_decision_point("switch_statement", "javascript"), true)
	expect.equality(counter.is_decision_point("case_clause", "javascript"), true)
end

T["counter"]["is_decision_point()"]["given python"] = MiniTest.new_set()

T["counter"]["is_decision_point()"]["given python"]["should return true for control flow nodes"] = function()
	expect.equality(counter.is_decision_point("if_statement", "python"), true)
	expect.equality(counter.is_decision_point("elif_clause", "python"), true)
	expect.equality(counter.is_decision_point("except_clause", "python"), true)
end

T["counter"]["is_decision_point()"]["given unsupported language"] = MiniTest.new_set()

T["counter"]["is_decision_point()"]["given unsupported language"]["should return false"] = function()
	expect.equality(counter.is_decision_point("if_statement", "unsupported"), false)
end

-- describe is_logical_operator()
T["counter"]["is_logical_operator()"] = MiniTest.new_set()

T["counter"]["is_logical_operator()"]["given logical operators"] = MiniTest.new_set()

T["counter"]["is_logical_operator()"]["given logical operators"]["should return true for && in javascript"] = function()
	expect.equality(counter.is_logical_operator("&&", "javascript"), true)
end

T["counter"]["is_logical_operator()"]["given logical operators"]["should return true for || in javascript"] = function()
	expect.equality(counter.is_logical_operator("||", "javascript"), true)
end

T["counter"]["is_logical_operator()"]["given logical operators"]["should return true for && in typescript"] = function()
	expect.equality(counter.is_logical_operator("&&", "typescript"), true)
end

T["counter"]["is_logical_operator()"]["given logical operators"]["should return true for 'and' in python"] = function()
	expect.equality(counter.is_logical_operator("and", "python"), true)
end

T["counter"]["is_logical_operator()"]["given logical operators"]["should return true for 'or' in python"] = function()
	expect.equality(counter.is_logical_operator("or", "python"), true)
end

T["counter"]["is_logical_operator()"]["given logical operators"]["should return true for && in c"] = function()
	expect.equality(counter.is_logical_operator("&&", "c"), true)
end

T["counter"]["is_logical_operator()"]["given non-logical operators"] = MiniTest.new_set()

T["counter"]["is_logical_operator()"]["given non-logical operators"]["should return false for arithmetic operators"] = function()
	expect.equality(counter.is_logical_operator("+", "javascript"), false)
	expect.equality(counter.is_logical_operator("-", "javascript"), false)
	expect.equality(counter.is_logical_operator("*", "python"), false)
end

T["counter"]["is_logical_operator()"]["given non-logical operators"]["should return false for comparison operators"] = function()
	expect.equality(counter.is_logical_operator("==", "javascript"), false)
	expect.equality(counter.is_logical_operator("!=", "javascript"), false)
end

-- describe count_complexity()
T["counter"]["count_complexity()"] = MiniTest.new_set()

T["counter"]["count_complexity()"]["given empty node_data"] = MiniTest.new_set()

T["counter"]["count_complexity()"]["given empty node_data"]["should return 0"] = function()
	local node_data = helpers.make_node("function_definition", {})
	expect.equality(counter.count_complexity(node_data, "lua"), 0)
end

T["counter"]["count_complexity()"]["given single control flow node"] = MiniTest.new_set()

T["counter"]["count_complexity()"]["given single control flow node"]["should return 1 for if statement"] = function()
	local node_data = helpers.make_node("function_definition", { helpers.if_node({}) })
	expect.equality(counter.count_complexity(node_data, "lua"), 1)
end

T["counter"]["count_complexity()"]["given single control flow node"]["should return 1 for for loop"] = function()
	local node_data = helpers.make_node("function_definition", { helpers.for_node({}) })
	expect.equality(counter.count_complexity(node_data, "lua"), 1)
end

T["counter"]["count_complexity()"]["given single control flow node"]["should return 1 for while loop"] = function()
	local node_data = helpers.make_node("function_definition", { helpers.while_node({}) })
	expect.equality(counter.count_complexity(node_data, "lua"), 1)
end

T["counter"]["count_complexity()"]["given multiple sibling nodes"] = MiniTest.new_set()

T["counter"]["count_complexity()"]["given multiple sibling nodes"]["should count each sibling"] = function()
	local node_data = helpers.make_node("function_definition", {
		helpers.if_node({}),
		helpers.for_node({}),
		helpers.while_node({}),
	})
	expect.equality(counter.count_complexity(node_data, "lua"), 3)
end

T["counter"]["count_complexity()"]["given nested structures"] = MiniTest.new_set()

T["counter"]["count_complexity()"]["given nested structures"]["should count nested nodes"] = function()
	local node_data = helpers.make_node("function_definition", {
		helpers.if_node({ helpers.for_node({}) }),
	})
	expect.equality(counter.count_complexity(node_data, "lua"), 2)
end

T["counter"]["count_complexity()"]["given nested structures"]["should count deeply nested nodes"] = function()
	local node_data = helpers.make_node("function_definition", {
		helpers.if_node({ helpers.for_node({ helpers.while_node({}) }) }),
	})
	expect.equality(counter.count_complexity(node_data, "lua"), 3)
end

T["counter"]["count_complexity()"]["given logical operators"] = MiniTest.new_set()

T["counter"]["count_complexity()"]["given logical operators"]["should count && in javascript"] = function()
	local node_data = helpers.make_node("function_declaration", {
		helpers.if_node({ helpers.binary_expr("&&", {}) }),
	})
	expect.equality(counter.count_complexity(node_data, "javascript"), 2)
end

T["counter"]["count_complexity()"]["given logical operators"]["should count multiple operators"] = function()
	local node_data = helpers.make_node("function_declaration", {
		helpers.if_node({
			helpers.binary_expr("&&", {}),
			helpers.binary_expr("||", {}),
		}),
	})
	expect.equality(counter.count_complexity(node_data, "javascript"), 3)
end

T["counter"]["count_complexity()"]["given logical operators"]["should count boolean operators in python"] = function()
	local node_data = helpers.make_node("function_definition", {
		helpers.if_node({ helpers.boolean_op("and", {}) }),
	})
	expect.equality(counter.count_complexity(node_data, "python"), 2)
end

T["counter"]["count_complexity()"]["given logical operators"]["should not count non-logical binary expressions"] = function()
	local node_data = helpers.make_node("function_declaration", {
		helpers.if_node({ helpers.binary_expr("+", {}) }),
	})
	expect.equality(counter.count_complexity(node_data, "javascript"), 1)
end

T["counter"]["count_complexity()"]["given language-specific nodes"] = MiniTest.new_set()

T["counter"]["count_complexity()"]["given language-specific nodes"]["should count switch cases in javascript"] = function()
	local node_data = helpers.make_node("function_declaration", {
		helpers.switch_node({ helpers.case_node({}), helpers.case_node({}) }),
	})
	expect.equality(counter.count_complexity(node_data, "javascript"), 3)
end

T["counter"]["count_complexity()"]["given language-specific nodes"]["should count try-catch in javascript"] = function()
	local node_data = helpers.make_node("function_declaration", {
		helpers.try_node({ helpers.catch_node({}) }),
	})
	expect.equality(counter.count_complexity(node_data, "javascript"), 2)
end

T["counter"]["count_complexity()"]["given language-specific nodes"]["should count elseif in lua"] = function()
	local node_data = helpers.make_node("function_definition", {
		helpers.if_node({ helpers.elseif_node({}) }),
	})
	expect.equality(counter.count_complexity(node_data, "lua"), 2)
end

T["counter"]["count_complexity()"]["given language-specific nodes"]["should count elif in python"] = function()
	local node_data = helpers.make_node("function_definition", {
		helpers.if_node({ helpers.elif_node({}) }),
	})
	expect.equality(counter.count_complexity(node_data, "python"), 2)
end

return T
