local helper = require("tests.test_helper")
local complexity = require("treesitter-cyclomatic-complexity.complexity")

describe("complexity calculation", function()
  local test_bufnr

  after_each(function()
    if test_bufnr then
      helper.cleanup_buffer(test_bufnr)
      test_bufnr = nil
    end
  end)

  describe("Lua complexity", function()
    it("calculates simple function complexity", function()
      local content = [[
function simple()
  return 42
end
]]
      test_bufnr = helper.create_test_buffer(content, "lua")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local complexities = complexity.get_all_complexities(test_bufnr, "lua")
      helper.assert_node_count(1, complexities, "Should find 1 function")
      helper.assert_complexity(1, complexities[1].complexity, "Simple function should have complexity 1")
    end)

    it("calculates function with if statement", function()
      local content = [[
function with_if(x)
  if x > 0 then
    return x
  end
  return 0
end
]]
      test_bufnr = helper.create_test_buffer(content, "lua")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local complexities = complexity.get_all_complexities(test_bufnr, "lua")
      helper.assert_node_count(1, complexities, "Should find 1 function")
      helper.assert_complexity(2, complexities[1].complexity, "Function with if should have complexity 2")
    end)

    it("calculates function with loops", function()
      local content = [[
function with_loops(items)
  for i, item in ipairs(items) do
    while item.valid do
      item = process(item)
    end
  end
end
]]
      test_bufnr = helper.create_test_buffer(content, "lua")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local complexities = complexity.get_all_complexities(test_bufnr, "lua")
      helper.assert_node_count(3, complexities, "Should find 1 function + 2 loops")

      -- Find function complexity
      local func_complexity = nil
      for _, result in ipairs(complexities) do
        if result.type == "function" then
          func_complexity = result.complexity
          break
        end
      end

      assert(func_complexity ~= nil, "Should find function complexity")
      helper.assert_complexity(3, func_complexity, "Function with for+while should have complexity 3")
    end)

    it("calculates complex function", function()
      local content = [[
function complex_function(data)
  if data then
    if data.valid then
      for i = 1, 10 do
        if i % 2 == 0 then
          while condition() do
            if another_check() then
              break
            end
          end
        end
      end
    end
  end
end
]]
      test_bufnr = helper.create_test_buffer(content, "lua")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local complexities = complexity.get_all_complexities(test_bufnr, "lua")

      -- Find function complexity
      local func_complexity = nil
      for _, result in ipairs(complexities) do
        if result.type == "function" then
          func_complexity = result.complexity
          break
        end
      end

      assert(func_complexity ~= nil, "Should find function complexity")
      -- Expected: 1 (base) + 3 (if statements) + 1 (for) + 1 (while) = 6
      helper.assert_complexity(6, func_complexity, "Complex function should have complexity 6")
    end)
  end)

  describe("JavaScript complexity", function()
    it("calculates arrow function complexity", function()
      local content = [[
const simple = () => {
  return 42;
};
]]
      test_bufnr = helper.create_test_buffer(content, "javascript")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local complexities = complexity.get_all_complexities(test_bufnr, "javascript")
      helper.assert_node_count(1, complexities, "Should find 1 function")
      helper.assert_complexity(1, complexities[1].complexity, "Simple arrow function should have complexity 1")
    end)

    it("calculates function with switch statement", function()
      local content = [[
function withSwitch(value) {
  switch (value) {
    case 1:
      return 'one';
    case 2:
      return 'two';
    default:
      return 'unknown';
  }
}
]]
      test_bufnr = helper.create_test_buffer(content, "javascript")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local complexities = complexity.get_all_complexities(test_bufnr, "javascript")
      helper.assert_node_count(1, complexities, "Should find 1 function")
      -- Expected: 1 (base) + 1 (switch) + 2 (cases) = 4
      helper.assert_complexity(4, complexities[1].complexity, "Function with switch should have complexity 4")
    end)

    it("calculates function with try-catch", function()
      local content = [[
function withTryCatch() {
  try {
    riskyOperation();
  } catch (error) {
    handleError(error);
  }
}
]]
      test_bufnr = helper.create_test_buffer(content, "javascript")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local complexities = complexity.get_all_complexities(test_bufnr, "javascript")
      helper.assert_node_count(1, complexities, "Should find 1 function")
      -- Expected: 1 (base) + 1 (try) + 1 (catch) = 3
      helper.assert_complexity(3, complexities[1].complexity, "Function with try-catch should have complexity 3")
    end)
  end)

  describe("Python complexity", function()
    it("calculates function with list comprehension", function()
      local content = [[
def process_items(items):
    if not items:
        return []
    
    result = [item for item in items if item.valid]
    return result
]]
      test_bufnr = helper.create_test_buffer(content, "python")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local complexities = complexity.get_all_complexities(test_bufnr, "python")
      helper.assert_node_count(1, complexities, "Should find 1 function")
      -- Expected: 1 (base) + 1 (if) = 2
      helper.assert_complexity(2, complexities[1].complexity, "Function with if should have complexity 2")
    end)

    it("calculates async function", function()
      local content = [[
async def async_function():
    try:
        result = await some_operation()
        if result:
            return result
    except Exception as e:
        return None
]]
      test_bufnr = helper.create_test_buffer(content, "python")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local complexities = complexity.get_all_complexities(test_bufnr, "python")
      helper.assert_node_count(1, complexities, "Should find 1 function")
      -- Expected: 1 (base) + 1 (try) + 1 (if) + 1 (except) = 4
      helper.assert_complexity(
        4,
        complexities[1].complexity,
        "Async function with try-except-if should have complexity 4"
      )
    end)
  end)

  describe("complexity level classification", function()
    it("classifies complexity levels correctly", function()
      local thresholds = { low = 5, medium = 10, high = 15 }

      helper.assert.are.equal("low", complexity.get_complexity_level(1, thresholds))
      helper.assert.are.equal("low", complexity.get_complexity_level(5, thresholds))
      helper.assert.are.equal("medium", complexity.get_complexity_level(6, thresholds))
      helper.assert.are.equal("medium", complexity.get_complexity_level(10, thresholds))
      helper.assert.are.equal("high", complexity.get_complexity_level(11, thresholds))
      helper.assert.are.equal("high", complexity.get_complexity_level(15, thresholds))
      helper.assert.are.equal("very_high", complexity.get_complexity_level(16, thresholds))
      helper.assert.are.equal("very_high", complexity.get_complexity_level(25, thresholds))
    end)
  end)

  describe("edge cases", function()
    it("handles empty functions", function()
      local content = [[
function empty() 
end
]]
      test_bufnr = helper.create_test_buffer(content, "lua")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local complexities = complexity.get_all_complexities(test_bufnr, "lua")
      helper.assert_node_count(1, complexities, "Should find 1 function")
      helper.assert_complexity(1, complexities[1].complexity, "Empty function should have complexity 1")
    end)

    it("handles unsupported language", function()
      test_bufnr = helper.create_test_buffer("some content", "unsupported")

      local complexities = complexity.get_all_complexities(test_bufnr, "unsupported")
      helper.assert_node_count(0, complexities, "Unsupported language should return no complexities")
    end)

    it("handles invalid buffer", function()
      local invalid_bufnr = 99999
      local complexities = complexity.get_all_complexities(invalid_bufnr, "lua")
      helper.assert_node_count(0, complexities, "Invalid buffer should return no complexities")
    end)
  end)
end)
