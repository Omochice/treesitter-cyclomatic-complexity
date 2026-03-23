-- Tests for complexity/counter.lua
-- Pure unit tests - no Neovim API required

describe("counter", function()
	local counter
	local helpers

	setup(function()
		counter = require("treesitter-cyclomatic-complexity.complexity.counter")
		helpers = require("spec.helpers")
	end)

	describe("get_patterns", function()
		it("returns lua patterns", function()
			local patterns = counter.get_patterns("lua")
			assert.is_table(patterns)
			assert.is_true(vim.tbl_contains(patterns, "if_statement"))
			assert.is_true(vim.tbl_contains(patterns, "for_statement"))
			assert.is_true(vim.tbl_contains(patterns, "while_statement"))
			assert.is_true(vim.tbl_contains(patterns, "repeat_statement"))
		end)

		it("returns javascript patterns", function()
			local patterns = counter.get_patterns("javascript")
			assert.is_table(patterns)
			assert.is_true(vim.tbl_contains(patterns, "if_statement"))
			assert.is_true(vim.tbl_contains(patterns, "switch_statement"))
			assert.is_true(vim.tbl_contains(patterns, "try_statement"))
		end)

		it("returns python patterns", function()
			local patterns = counter.get_patterns("python")
			assert.is_table(patterns)
			assert.is_true(vim.tbl_contains(patterns, "if_statement"))
			assert.is_true(vim.tbl_contains(patterns, "elif_clause"))
			assert.is_true(vim.tbl_contains(patterns, "with_statement"))
		end)

		it("returns empty table for unsupported language", function()
			local patterns = counter.get_patterns("unsupported")
			assert.same({}, patterns)
		end)
	end)

	describe("is_decision_point", function()
		it("returns true for if_statement in lua", function()
			assert.is_true(counter.is_decision_point("if_statement", "lua"))
		end)

		it("returns true for for_statement in lua", function()
			assert.is_true(counter.is_decision_point("for_statement", "lua"))
		end)

		it("returns true for while_statement in lua", function()
			assert.is_true(counter.is_decision_point("while_statement", "lua"))
		end)

		it("returns false for non-decision nodes", function()
			assert.is_false(counter.is_decision_point("identifier", "lua"))
			assert.is_false(counter.is_decision_point("function_definition", "lua"))
		end)

		it("handles javascript patterns", function()
			assert.is_true(counter.is_decision_point("if_statement", "javascript"))
			assert.is_true(counter.is_decision_point("switch_statement", "javascript"))
			assert.is_true(counter.is_decision_point("case_clause", "javascript"))
		end)

		it("handles python patterns", function()
			assert.is_true(counter.is_decision_point("if_statement", "python"))
			assert.is_true(counter.is_decision_point("elif_clause", "python"))
			assert.is_true(counter.is_decision_point("except_clause", "python"))
		end)

		it("returns false for unsupported language", function()
			assert.is_false(counter.is_decision_point("if_statement", "unsupported"))
		end)
	end)

	describe("is_logical_operator", function()
		it("returns true for && in javascript", function()
			assert.is_true(counter.is_logical_operator("&&", "javascript"))
		end)

		it("returns true for || in javascript", function()
			assert.is_true(counter.is_logical_operator("||", "javascript"))
		end)

		it("returns true for && in typescript", function()
			assert.is_true(counter.is_logical_operator("&&", "typescript"))
		end)

		it("returns true for 'and' in python", function()
			assert.is_true(counter.is_logical_operator("and", "python"))
		end)

		it("returns true for 'or' in python", function()
			assert.is_true(counter.is_logical_operator("or", "python"))
		end)

		it("returns true for && in c", function()
			assert.is_true(counter.is_logical_operator("&&", "c"))
		end)

		it("returns false for arithmetic operators", function()
			assert.is_false(counter.is_logical_operator("+", "javascript"))
			assert.is_false(counter.is_logical_operator("-", "javascript"))
			assert.is_false(counter.is_logical_operator("*", "python"))
		end)

		it("returns false for comparison operators", function()
			assert.is_false(counter.is_logical_operator("==", "javascript"))
			assert.is_false(counter.is_logical_operator("!=", "javascript"))
		end)
	end)

	describe("count_complexity", function()
		it("returns 0 for empty node_data", function()
			local node_data = helpers.make_node("function_definition", {})
			assert.equals(0, counter.count_complexity(node_data, "lua"))
		end)

		it("returns 1 for single if statement", function()
			local node_data = helpers.make_node("function_definition", {
				helpers.if_node({}),
			})
			assert.equals(1, counter.count_complexity(node_data, "lua"))
		end)

		it("returns 1 for single for loop", function()
			local node_data = helpers.make_node("function_definition", {
				helpers.for_node({}),
			})
			assert.equals(1, counter.count_complexity(node_data, "lua"))
		end)

		it("returns 1 for single while loop", function()
			local node_data = helpers.make_node("function_definition", {
				helpers.while_node({}),
			})
			assert.equals(1, counter.count_complexity(node_data, "lua"))
		end)

		it("counts multiple siblings correctly", function()
			local node_data = helpers.make_node("function_definition", {
				helpers.if_node({}),
				helpers.for_node({}),
				helpers.while_node({}),
			})
			assert.equals(3, counter.count_complexity(node_data, "lua"))
		end)

		it("counts nested structures correctly", function()
			local node_data = helpers.make_node("function_definition", {
				helpers.if_node({
					helpers.for_node({}),
				}),
			})
			assert.equals(2, counter.count_complexity(node_data, "lua"))
		end)

		it("counts deeply nested structures correctly", function()
			local node_data = helpers.make_node("function_definition", {
				helpers.if_node({
					helpers.for_node({
						helpers.while_node({}),
					}),
				}),
			})
			assert.equals(3, counter.count_complexity(node_data, "lua"))
		end)

		it("counts logical operators in javascript", function()
			local node_data = helpers.make_node("function_declaration", {
				helpers.if_node({
					helpers.binary_expr("&&", {}),
				}),
			})
			assert.equals(2, counter.count_complexity(node_data, "javascript"))
		end)

		it("counts multiple logical operators", function()
			local node_data = helpers.make_node("function_declaration", {
				helpers.if_node({
					helpers.binary_expr("&&", {}),
					helpers.binary_expr("||", {}),
				}),
			})
			assert.equals(3, counter.count_complexity(node_data, "javascript"))
		end)

		it("counts boolean operators in python", function()
			local node_data = helpers.make_node("function_definition", {
				helpers.if_node({
					helpers.boolean_op("and", {}),
				}),
			})
			assert.equals(2, counter.count_complexity(node_data, "python"))
		end)

		it("does not count non-logical binary expressions", function()
			local node_data = helpers.make_node("function_declaration", {
				helpers.if_node({
					helpers.binary_expr("+", {}),
				}),
			})
			assert.equals(1, counter.count_complexity(node_data, "javascript"))
		end)

		it("counts switch cases in javascript", function()
			local node_data = helpers.make_node("function_declaration", {
				helpers.switch_node({
					helpers.case_node({}),
					helpers.case_node({}),
				}),
			})
			assert.equals(3, counter.count_complexity(node_data, "javascript"))
		end)

		it("counts try-catch in javascript", function()
			local node_data = helpers.make_node("function_declaration", {
				helpers.try_node({
					helpers.catch_node({}),
				}),
			})
			assert.equals(2, counter.count_complexity(node_data, "javascript"))
		end)

		it("counts elseif in lua", function()
			local node_data = helpers.make_node("function_definition", {
				helpers.if_node({
					helpers.elseif_node({}),
				}),
			})
			assert.equals(2, counter.count_complexity(node_data, "lua"))
		end)

		it("counts elif in python", function()
			local node_data = helpers.make_node("function_definition", {
				helpers.if_node({
					helpers.elif_node({}),
				}),
			})
			assert.equals(2, counter.count_complexity(node_data, "python"))
		end)
	end)
end)
