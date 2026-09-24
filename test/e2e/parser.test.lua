local expect = MiniTest.expect

local parser = require("treesitter-cyclomatic-complexity.parser")

local bufnr

local function set_buf_content(content, filetype)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
	vim.bo[bufnr].filetype = filetype
	vim.treesitter.get_parser(bufnr, filetype):parse()
end

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

describe("parser", function()
	before_each(function()
		bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_set_current_buf(bufnr)
	end)

	after_each(function()
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end)

	describe("get_function_nodes()", function()
		describe("given lua buffer with functions", function()
			it("should extract function nodes", function()
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
			end)
		end)

		describe("given lua buffer with a single named function", function()
			it("should return one node per function, not one per capture", function()
				set_buf_content(
					[[
local function foo()
  return 1
end
]],
					"lua"
				)

				local nodes = parser.get_function_nodes(bufnr, "lua")
				expect.equality(#nodes, 1)
			end)

			it("should return the node spanning the whole function, not its name", function()
				set_buf_content(
					[[
local function foo()
  return 1
end
]],
					"lua"
				)

				local nodes = parser.get_function_nodes(bufnr, "lua")
				for _, node_info in ipairs(nodes) do
					expect.equality(node_info.start_row, 0)
					expect.equality(node_info.end_row, 2)
				end
			end)
		end)

		describe("given unsupported language", function()
			it("should return empty table", function()
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "some content" })
				local nodes = parser.get_function_nodes(bufnr, "unsupported")
				expect.equality(nodes, {})
			end)
		end)
	end)

	describe("every supported language", function()
		-- A node type the grammar does not define makes `query.parse` raise, and
		-- every entry point parses its query before it can return anything, so an
		-- empty buffer is enough to expose a stale name.
		for _, lang in ipairs(parser.get_supported_languages()) do
			describe("given empty " .. lang .. " buffer", function()
				it("should query without raising", function()
					local lang_parser = vim.treesitter.get_parser(bufnr, lang)
					-- Without this the whole group degrades into a nil index error,
					-- which reads as a plugin bug rather than a missing grammar.
					expect.equality(lang_parser ~= nil, true)

					local root = lang_parser:parse()[1]:root()

					expect.no_error(function()
						parser.get_function_nodes(bufnr, lang)
					end)
					expect.no_error(function()
						parser.get_loop_nodes(bufnr, lang)
					end)
					expect.no_error(function()
						parser.get_control_flow_nodes(root, bufnr, lang)
					end)
				end)
			end)
		end
	end)

	describe("get_loop_nodes()", function()
		describe("given typescript buffer with a for-of loop", function()
			it("should extract the loop node", function()
				set_buf_content(
					[[
for (const n of names) {
  console.log(n);
}
]],
					"typescript"
				)

				local nodes = parser.get_loop_nodes(bufnr, "typescript")
				expect.equality(#nodes, 1)
				expect.equality(nodes[1].type, "loop")
			end)
		end)

		describe("given lua buffer with loops", function()
			it("should extract loop nodes", function()
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
			end)
		end)
	end)

	describe("node_to_data()", function()
		describe("given function with if statement", function()
			it("should include if_statement in children tree", function()
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
			end)
		end)
	end)

	describe("get_function_nodes_with_data()", function()
		describe("given lua buffer", function()
			it("should return nodes with node_data and metadata", function()
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
			end)
		end)
	end)

	describe("get_loop_nodes_with_data()", function()
		describe("given lua buffer", function()
			it("should return loop nodes with node_data and metadata", function()
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
			end)
		end)
	end)
end)
