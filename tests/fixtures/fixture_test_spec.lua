local helper = require("tests.test_helper")
local complexity = require("treesitter-cyclomatic-complexity.complexity")

describe("fixture complexity validation", function()
  local test_bufnr

  after_each(function()
    if test_bufnr then
      helper.cleanup_buffer(test_bufnr)
      test_bufnr = nil
    end
  end)

  describe("Lua fixture validation", function()
    it("validates expected complexities in Lua fixtures", function()
      local fixture_path = "tests/fixtures/lua_samples.lua"
      local content = vim.fn.readfile(fixture_path)
      local content_str = table.concat(content, "\n")

      test_bufnr = helper.create_test_buffer(content_str, "lua")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local complexities = complexity.get_all_complexities(test_bufnr, "lua")

      -- Should find multiple functions
      local function_count = 0
      for _, result in ipairs(complexities) do
        if result.type == "function" then
          function_count = function_count + 1
        end
      end

      assert(function_count >= 5, "Should find at least 5 functions in Lua fixtures")

      -- Verify some specific complexity values
      local found_simple = false
      local found_complex = false

      for _, result in ipairs(complexities) do
        if result.type == "function" then
          if result.complexity == 1 then
            found_simple = true
          elseif result.complexity >= 5 then
            found_complex = true
          end
        end
      end

      assert(found_simple, "Should find at least one simple function (CC: 1)")
      assert(found_complex, "Should find at least one complex function (CC: >= 5)")
    end)
  end)

  describe("JavaScript fixture validation", function()
    it("validates expected complexities in JavaScript fixtures", function()
      local fixture_path = "tests/fixtures/javascript_samples.js"
      local content = vim.fn.readfile(fixture_path)
      local content_str = table.concat(content, "\n")

      test_bufnr = helper.create_test_buffer(content_str, "javascript")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local complexities = complexity.get_all_complexities(test_bufnr, "javascript")

      -- Should find multiple functions
      local function_count = 0
      for _, result in ipairs(complexities) do
        if result.type == "function" then
          function_count = function_count + 1
        end
      end

      assert(function_count >= 5, "Should find at least 5 functions in JavaScript fixtures")
    end)
  end)

  describe("Python fixture validation", function()
    it("validates expected complexities in Python fixtures", function()
      local fixture_path = "tests/fixtures/python_samples.py"
      local content = vim.fn.readfile(fixture_path)
      local content_str = table.concat(content, "\n")

      test_bufnr = helper.create_test_buffer(content_str, "python")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local complexities = complexity.get_all_complexities(test_bufnr, "python")

      -- Should find multiple functions
      local function_count = 0
      for _, result in ipairs(complexities) do
        if result.type == "function" then
          function_count = function_count + 1
        end
      end

      assert(function_count >= 5, "Should find at least 5 functions in Python fixtures")
    end)
  end)

  describe("C fixture validation", function()
    it("validates expected complexities in C fixtures", function()
      local fixture_path = "tests/fixtures/c_samples.c"
      local content = vim.fn.readfile(fixture_path)
      local content_str = table.concat(content, "\n")

      test_bufnr = helper.create_test_buffer(content_str, "c")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local complexities = complexity.get_all_complexities(test_bufnr, "c")

      -- Should find multiple functions
      local function_count = 0
      for _, result in ipairs(complexities) do
        if result.type == "function" then
          function_count = function_count + 1
        end
      end

      assert(function_count >= 5, "Should find at least 5 functions in C fixtures")
    end)
  end)

  describe("cross-language complexity comparison", function()
    it("compares similar functions across languages", function()
      -- Simple function test across languages
      local simple_lua = "function simple() return 42 end"
      local simple_js = "function simple() { return 42; }"
      local simple_py = "def simple():\n    return 42"

      -- Test Lua
      test_bufnr = helper.create_test_buffer(simple_lua, "lua")
      assert(helper.wait_for_treesitter(test_bufnr), "Lua treesitter parsing failed")
      local lua_complexities = complexity.get_all_complexities(test_bufnr, "lua")
      helper.cleanup_buffer(test_bufnr)

      -- Test JavaScript
      test_bufnr = helper.create_test_buffer(simple_js, "javascript")
      assert(helper.wait_for_treesitter(test_bufnr), "JavaScript treesitter parsing failed")
      local js_complexities = complexity.get_all_complexities(test_bufnr, "javascript")
      helper.cleanup_buffer(test_bufnr)

      -- Test Python
      test_bufnr = helper.create_test_buffer(simple_py, "python")
      assert(helper.wait_for_treesitter(test_bufnr), "Python treesitter parsing failed")
      local py_complexities = complexity.get_all_complexities(test_bufnr, "python")
      helper.cleanup_buffer(test_bufnr)

      test_bufnr = nil

      -- All should have the same complexity for simple functions
      assert(#lua_complexities == 1, "Lua should find 1 function")
      assert(#js_complexities == 1, "JavaScript should find 1 function")
      assert(#py_complexities == 1, "Python should find 1 function")

      helper.assert_complexity(1, lua_complexities[1].complexity, "Lua simple function")
      helper.assert_complexity(1, js_complexities[1].complexity, "JavaScript simple function")
      helper.assert_complexity(1, py_complexities[1].complexity, "Python simple function")
    end)
  end)
end)
