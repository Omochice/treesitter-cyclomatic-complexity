local helper = require('tests.test_helper')
local parser = require('treesitter-cyclomatic-complexity.parser')

describe("parser module", function()
  local test_bufnr
  
  after_each(function()
    if test_bufnr then
      helper.cleanup_buffer(test_bufnr)
      test_bufnr = nil
    end
  end)

  describe("language support", function()
    it("returns supported languages", function()
      local languages = parser.get_supported_languages()
      assert(type(languages) == 'table', "Should return a table")
      assert(#languages > 0, "Should return at least one language")
      
      -- Check for expected languages
      local expected = { 'lua', 'javascript', 'python', 'c', 'cpp', 'java', 'go', 'rust', 'typescript' }
      for _, lang in ipairs(expected) do
        local found = false
        for _, supported in ipairs(languages) do
          if supported == lang then
            found = true
            break
          end
        end
        assert(found, "Should support " .. lang)
      end
    end)

    it("correctly identifies supported languages", function()
      assert.is_true(parser.is_language_supported('lua'))
      assert.is_true(parser.is_language_supported('javascript'))
      assert.is_true(parser.is_language_supported('python'))
      assert.is_false(parser.is_language_supported('unsupported'))
      assert.is_false(parser.is_language_supported(nil))
    end)
  end)

  describe("Lua parsing", function()
    it("extracts simple function nodes", function()
      local content = [[
function simple()
  return 42
end

local function local_func()
  print("hello")
end
]]
      test_bufnr = helper.create_test_buffer(content, 'lua')
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")
      
      local function_nodes = parser.get_function_nodes(test_bufnr, 'lua')
      helper.assert_node_count(2, function_nodes, "Should find 2 functions")
      
      -- Check node properties
      for _, node_info in ipairs(function_nodes) do
        assert(node_info.node ~= nil, "Node should not be nil")
        assert(node_info.start_row ~= nil, "Start row should be set")
        assert(node_info.end_row ~= nil, "End row should be set")
        assert(node_info.type == 'function', "Type should be 'function'")
      end
    end)

    it("extracts loop nodes", function()
      local content = [[
for i = 1, 10 do
  print(i)
end

while condition do
  process()
end

repeat
  action()
until done
]]
      test_bufnr = helper.create_test_buffer(content, 'lua')
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")
      
      local loop_nodes = parser.get_loop_nodes(test_bufnr, 'lua')
      helper.assert_node_count(3, loop_nodes, "Should find 3 loops")
      
      -- Check that all are loop type
      for _, node_info in ipairs(loop_nodes) do
        assert(node_info.type == 'loop', "Type should be 'loop'")
      end
    end)

    it("gets node text correctly", function()
      local content = [[
function test_function()
  return "hello world"
end
]]
      test_bufnr = helper.create_test_buffer(content, 'lua')
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")
      
      local function_nodes = parser.get_function_nodes(test_bufnr, 'lua')
      helper.assert_node_count(1, function_nodes, "Should find 1 function")
      
      local node_text = parser.get_node_text(function_nodes[1].node, test_bufnr)
      assert(type(node_text) == 'string', "Node text should be a string")
      assert(string.find(node_text, 'test_function'), "Node text should contain function name")
    end)

    it("gets node range correctly", function()
      local content = [[
function test()
  local x = 1
  return x
end
]]
      test_bufnr = helper.create_test_buffer(content, 'lua')
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")
      
      local function_nodes = parser.get_function_nodes(test_bufnr, 'lua')
      helper.assert_node_count(1, function_nodes, "Should find 1 function")
      
      local range = parser.get_node_range(function_nodes[1].node)
      assert(type(range) == 'table', "Range should be a table")
      assert(range.start_row ~= nil, "Start row should be set")
      assert(range.start_col ~= nil, "Start col should be set")
      assert(range.end_row ~= nil, "End row should be set")
      assert(range.end_col ~= nil, "End col should be set")
      assert(range.start_row <= range.end_row, "Start row should be <= end row")
    end)
  end)

  describe("JavaScript parsing", function()
    it("extracts different function types", function()
      local content = [[
function regularFunction() {
  return 1;
}

const arrowFunction = () => {
  return 2;
};

const functionExpression = function() {
  return 3;
};

class MyClass {
  methodFunction() {
    return 4;
  }
}
]]
      test_bufnr = helper.create_test_buffer(content, 'javascript')
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")
      
      local function_nodes = parser.get_function_nodes(test_bufnr, 'javascript')
      helper.assert_node_count(4, function_nodes, "Should find 4 functions")
    end)

    it("extracts different loop types", function()
      local content = [[
for (let i = 0; i < 10; i++) {
  console.log(i);
}

for (const item of items) {
  process(item);
}

for (const key in object) {
  console.log(key);
}

while (condition) {
  action();
}

do {
  action();
} while (condition);
]]
      test_bufnr = helper.create_test_buffer(content, 'javascript')
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")
      
      local loop_nodes = parser.get_loop_nodes(test_bufnr, 'javascript')
      helper.assert_node_count(5, loop_nodes, "Should find 5 loops")
    end)
  end)

  describe("Python parsing", function()
    it("extracts function and async function", function()
      local content = [[
def regular_function():
    return 1

async def async_function():
    return await something()
]]
      test_bufnr = helper.create_test_buffer(content, 'python')
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")
      
      local function_nodes = parser.get_function_nodes(test_bufnr, 'python')
      helper.assert_node_count(2, function_nodes, "Should find 2 functions")
    end)

    it("extracts loop nodes", function()
      local content = [[
for item in items:
    process(item)

while condition:
    action()
]]
      test_bufnr = helper.create_test_buffer(content, 'python')
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")
      
      local loop_nodes = parser.get_loop_nodes(test_bufnr, 'python')
      helper.assert_node_count(2, loop_nodes, "Should find 2 loops")
    end)
  end)

  describe("C/C++ parsing", function()
    it("extracts C functions", function()
      local content = [[
int main() {
    return 0;
}

void helper_function(int x) {
    printf("%d", x);
}
]]
      test_bufnr = helper.create_test_buffer(content, 'c')
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")
      
      local function_nodes = parser.get_function_nodes(test_bufnr, 'c')
      helper.assert_node_count(2, function_nodes, "Should find 2 functions")
    end)

    it("extracts C loops", function()
      local content = [[
for (int i = 0; i < 10; i++) {
    printf("%d", i);
}

while (condition) {
    action();
}

do {
    action();
} while (condition);
]]
      test_bufnr = helper.create_test_buffer(content, 'c')
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")
      
      local loop_nodes = parser.get_loop_nodes(test_bufnr, 'c')
      helper.assert_node_count(3, loop_nodes, "Should find 3 loops")
    end)
  end)

  describe("control flow extraction", function()
    it("extracts control flow nodes from Lua", function()
      local content = [[
function test()
  if condition then
    for i = 1, 10 do
      while another_condition do
        break
      end
    end
  end
end
]]
      test_bufnr = helper.create_test_buffer(content, 'lua')
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")
      
      local function_nodes = parser.get_function_nodes(test_bufnr, 'lua')
      helper.assert_node_count(1, function_nodes, "Should find 1 function")
      
      local control_nodes = parser.get_control_flow_nodes(function_nodes[1].node, test_bufnr, 'lua')
      assert(#control_nodes >= 3, "Should find at least 3 control flow nodes (if, for, while)")
    end)
  end)

  describe("error handling", function()
    it("handles unsupported language gracefully", function()
      test_bufnr = helper.create_test_buffer("some content", 'unsupported')
      
      local function_nodes = parser.get_function_nodes(test_bufnr, 'unsupported')
      helper.assert_node_count(0, function_nodes, "Unsupported language should return empty array")
      
      local loop_nodes = parser.get_loop_nodes(test_bufnr, 'unsupported')
      helper.assert_node_count(0, loop_nodes, "Unsupported language should return empty array")
    end)

    it("handles invalid buffer gracefully", function()
      local invalid_bufnr = 99999
      
      local function_nodes = parser.get_function_nodes(invalid_bufnr, 'lua')
      helper.assert_node_count(0, function_nodes, "Invalid buffer should return empty array")
      
      local loop_nodes = parser.get_loop_nodes(invalid_bufnr, 'lua')
      helper.assert_node_count(0, loop_nodes, "Invalid buffer should return empty array")
    end)

    it("handles buffer without treesitter parser", function()
      test_bufnr = helper.create_test_buffer("some content", 'text')
      
      local function_nodes = parser.get_function_nodes(test_bufnr, 'text')
      helper.assert_node_count(0, function_nodes, "Buffer without parser should return empty array")
    end)
  end)
end)