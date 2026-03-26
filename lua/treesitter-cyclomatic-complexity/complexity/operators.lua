-- Shared logical operator definitions
-- Used by both cyclomatic and cognitive complexity counters

local M = {}

M.logical_operators = {
	javascript = { ["&&"] = true, ["||"] = true },
	typescript = { ["&&"] = true, ["||"] = true },
	python = { ["and"] = true, ["or"] = true },
	c = { ["&&"] = true, ["||"] = true },
	cpp = { ["&&"] = true, ["||"] = true },
	java = { ["&&"] = true, ["||"] = true },
	go = { ["&&"] = true, ["||"] = true },
	rust = { ["&&"] = true, ["||"] = true },
}

M.binary_expr_types = {
	binary_expression = true,
	boolean_operator = true,
}

return M
