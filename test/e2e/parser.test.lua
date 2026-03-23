local expect = MiniTest.expect

local parser = require("treesitter-cyclomatic-complexity.parser")

local bufnr

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			bufnr = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_set_current_buf(bufnr)
		end,
		post_case = function()
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end,
	},
})

local function set_buf_content(content, filetype)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
	vim.bo[bufnr].filetype = filetype
	vim.treesitter.get_parser(bufnr, filetype):parse()
end

-- Recursively search for a node type in structured data
local function has_type(node_data, target_type)
	if node_data.type == target_type then
		return true
	end
	for _, child in ipairs(node_data.children) do
		if has_type(child, target_type) then
			return true
		end
	end
	return false
end

T["parser"] = MiniTest.new_set()

-- describe get_function_nodes()
T["parser"]["get_function_nodes()"] = MiniTest.new_set()

T["parser"]["get_function_nodes()"]["given lua buffer with functions"] = MiniTest.new_set()

T["parser"]["get_function_nodes()"]["given lua buffer with functions"]["should extract function nodes"] = function()
	set_buf_content(
		[[
local function foo()
  return 1
end

local function bar()
  return 2
end
]],
		"lua"
	)

	local nodes = parser.get_function_nodes(bufnr, "lua")
	expect.equality(#nodes >= 2, true)
	expect.equality(nodes[1].type, "function")
end

T["parser"]["get_function_nodes()"]["given unsupported language"] = MiniTest.new_set()

T["parser"]["get_function_nodes()"]["given unsupported language"]["should return empty table"] = function()
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "some content" })
	local nodes = parser.get_function_nodes(bufnr, "unsupported")
	expect.equality(nodes, {})
end

-- describe get_loop_nodes()
T["parser"]["get_loop_nodes()"] = MiniTest.new_set()

T["parser"]["get_loop_nodes()"]["given lua buffer with loops"] = MiniTest.new_set()

T["parser"]["get_loop_nodes()"]["given lua buffer with loops"]["should extract loop nodes"] = function()
	set_buf_content(
		[[
for i = 1, 10 do
  print(i)
end

while true do
  break
end
]],
		"lua"
	)

	local nodes = parser.get_loop_nodes(bufnr, "lua")
	expect.equality(#nodes, 2)
	expect.equality(nodes[1].type, "loop")
end

-- describe node_to_data()
T["parser"]["node_to_data()"] = MiniTest.new_set()

T["parser"]["node_to_data()"]["given function with if statement"] = MiniTest.new_set()

T["parser"]["node_to_data()"]["given function with if statement"]["should include if_statement in children tree"] = function()
	set_buf_content(
		[[
local function foo()
  if true then
    return 1
  end
  return 0
end
]],
		"lua"
	)

	local nodes = parser.get_function_nodes(bufnr, "lua")
	expect.equality(#nodes >= 1, true)

	local data = parser.node_to_data(nodes[1].node, bufnr)
	expect.equality(type(data), "table")
	expect.equality(type(data.type), "string")
	expect.equality(type(data.children), "table")
	expect.equality(has_type(data, "if_statement"), true)
end

-- describe get_function_nodes_with_data()
T["parser"]["get_function_nodes_with_data()"] = MiniTest.new_set()

T["parser"]["get_function_nodes_with_data()"]["given lua buffer"] = MiniTest.new_set()

T["parser"]["get_function_nodes_with_data()"]["given lua buffer"]["should return nodes with node_data and metadata"] = function()
	set_buf_content(
		[[
local function foo()
  return 1
end
]],
		"lua"
	)

	local results = parser.get_function_nodes_with_data(bufnr, "lua")
	expect.equality(#results >= 1, true)
	expect.equality(type(results[1].node_data), "table")
	expect.equality(results[1].type, "function")
	expect.equality(type(results[1].start_row), "number")
end

-- describe get_loop_nodes_with_data()
T["parser"]["get_loop_nodes_with_data()"] = MiniTest.new_set()

T["parser"]["get_loop_nodes_with_data()"]["given lua buffer"] = MiniTest.new_set()

T["parser"]["get_loop_nodes_with_data()"]["given lua buffer"]["should return loop nodes with node_data and metadata"] = function()
	set_buf_content(
		[[
for i = 1, 10 do
  print(i)
end
]],
		"lua"
	)

	local results = parser.get_loop_nodes_with_data(bufnr, "lua")
	expect.equality(#results >= 1, true)
	expect.equality(type(results[1].node_data), "table")
	expect.equality(results[1].type, "loop")
end

return T
