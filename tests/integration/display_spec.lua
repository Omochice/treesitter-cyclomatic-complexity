local helper = require("tests.test_helper")
local display = require("treesitter-cyclomatic-complexity.display")
local config = require("treesitter-cyclomatic-complexity.config")

describe("display integration", function()
  local test_bufnr
  local original_config

  before_each(function()
    -- Setup default configuration
    config.setup()
    display.setup()
  end)

  after_each(function()
    if test_bufnr then
      helper.cleanup_buffer(test_bufnr)
      test_bufnr = nil
    end
    if original_config then
      helper.restore_config(original_config)
      original_config = nil
    end
  end)

  describe("complexity display", function()
    it("shows complexity for simple function", function()
      local content = [[
function simple()
  return 42
end
]]
      test_bufnr = helper.create_test_buffer(content, "lua")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      display.update_display(test_bufnr)

      -- Check that extmarks were created
      local ns_id = vim.api.nvim_create_namespace("treesitter-cyclomatic-complexity")
      local extmarks = vim.api.nvim_buf_get_extmarks(test_bufnr, ns_id, 0, -1, {})

      assert(#extmarks > 0, "Should create at least one extmark")

      -- Check extmark content
      local extmark = extmarks[1]
      local extmark_details = vim.api.nvim_buf_get_extmark_by_id(test_bufnr, ns_id, extmark[1], { details = true })
      assert(extmark_details[3].virt_text ~= nil, "Extmark should have virtual text")

      local virt_text = extmark_details[3].virt_text[1][1]
      assert(string.find(virt_text, "CC:"), "Virtual text should contain complexity indicator")
    end)

    it("clears complexity display", function()
      local content = [[
function test()
  return 1
end
]]
      test_bufnr = helper.create_test_buffer(content, "lua")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      display.update_display(test_bufnr)

      local ns_id = vim.api.nvim_create_namespace("treesitter-cyclomatic-complexity")
      local extmarks = vim.api.nvim_buf_get_extmarks(test_bufnr, ns_id, 0, -1, {})
      assert(#extmarks > 0, "Should have extmarks before clearing")

      display.clear_complexity(test_bufnr)

      extmarks = vim.api.nvim_buf_get_extmarks(test_bufnr, ns_id, 0, -1, {})
      assert(#extmarks == 0, "Should have no extmarks after clearing")
    end)

    it("toggles complexity display", function()
      local content = [[
function test()
  return 1
end
]]
      test_bufnr = helper.create_test_buffer(content, "lua")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local ns_id = vim.api.nvim_create_namespace("treesitter-cyclomatic-complexity")

      -- Initially no extmarks
      local extmarks = vim.api.nvim_buf_get_extmarks(test_bufnr, ns_id, 0, -1, {})
      assert(#extmarks == 0, "Should start with no extmarks")

      -- Toggle on
      display.toggle_display(test_bufnr)
      extmarks = vim.api.nvim_buf_get_extmarks(test_bufnr, ns_id, 0, -1, {})
      assert(#extmarks > 0, "Should have extmarks after toggle on")

      -- Toggle off
      display.toggle_display(test_bufnr)
      extmarks = vim.api.nvim_buf_get_extmarks(test_bufnr, ns_id, 0, -1, {})
      assert(#extmarks == 0, "Should have no extmarks after toggle off")
    end)
  end)

  describe("highlight groups", function()
    it("uses correct highlight group for low complexity", function()
      original_config = helper.mock_config({
        thresholds = { low = 5, medium = 10, high = 15 },
      })

      local hl_group = display.get_highlight_group(3, config.get("thresholds"))
      helper.assert.are.equal("CyclomaticComplexityLow", hl_group)
    end)

    it("uses correct highlight group for medium complexity", function()
      original_config = helper.mock_config({
        thresholds = { low = 5, medium = 10, high = 15 },
      })

      local hl_group = display.get_highlight_group(7, config.get("thresholds"))
      helper.assert.are.equal("CyclomaticComplexityMedium", hl_group)
    end)

    it("uses correct highlight group for high complexity", function()
      original_config = helper.mock_config({
        thresholds = { low = 5, medium = 10, high = 15 },
      })

      local hl_group = display.get_highlight_group(12, config.get("thresholds"))
      helper.assert.are.equal("CyclomaticComplexityHigh", hl_group)
    end)

    it("uses correct highlight group for very high complexity", function()
      original_config = helper.mock_config({
        thresholds = { low = 5, medium = 10, high = 15 },
      })

      local hl_group = display.get_highlight_group(20, config.get("thresholds"))
      helper.assert.are.equal("CyclomaticComplexityVeryHigh", hl_group)
    end)
  end)

  describe("text formatting", function()
    it("formats complexity text with default format", function()
      local text = display.format_complexity_text(5)
      helper.assert.are.equal("CC: 5", text)
    end)

    it("formats complexity text with custom format", function()
      local text = display.format_complexity_text(7, "Complexity: %d")
      helper.assert.are.equal("Complexity: 7", text)
    end)

    it("handles nil format gracefully", function()
      local text = display.format_complexity_text(3, nil)
      helper.assert.are.equal("CC: 3", text)
    end)
  end)

  describe("buffer statistics", function()
    it("calculates basic statistics", function()
      local content = [[
function simple()
  return 1
end

function complex(x)
  if x > 0 then
    for i = 1, x do
      if i % 2 == 0 then
        print(i)
      end
    end
  end
  return x
end

for i = 1, 10 do
  print(i)
end
]]
      test_bufnr = helper.create_test_buffer(content, "lua")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local stats = display.get_stats(test_bufnr)

      assert(stats ~= nil, "Should return statistics")
      assert(stats.total_functions == 2, "Should find 2 functions")
      assert(stats.total_loops >= 1, "Should find at least 1 loop")
      assert(stats.avg_complexity > 0, "Average complexity should be > 0")
      assert(stats.max_complexity > 0, "Max complexity should be > 0")
      assert(type(stats.distribution) == "table", "Distribution should be a table")
    end)

    it("returns nil for unsupported language", function()
      test_bufnr = helper.create_test_buffer("some content", "unsupported")

      local stats = display.get_stats(test_bufnr)
      helper.assert.is_nil(stats)
    end)

    it("returns nil for invalid buffer", function()
      local stats = display.get_stats(99999)
      helper.assert.is_nil(stats)
    end)

    it("calculates distribution correctly", function()
      original_config = helper.mock_config({
        thresholds = { low = 2, medium = 4, high = 6 },
      })

      local content = [[
function low_complexity()
  return 1
end

function medium_complexity(x)
  if x then
    return x
  end
  return 0
end

function high_complexity(x)
  if x then
    if x > 0 then
      for i = 1, x do
        print(i)
      end
    end
  end
  return x
end
]]
      test_bufnr = helper.create_test_buffer(content, "lua")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      local stats = display.get_stats(test_bufnr)

      assert(stats.distribution.low > 0, "Should have low complexity functions")
      assert(stats.distribution.medium > 0, "Should have medium complexity functions")
      assert(stats.distribution.high > 0, "Should have high complexity functions")
    end)
  end)

  describe("multiple language support", function()
    it("displays complexity for JavaScript", function()
      local content = [[
function test() {
  if (condition) {
    for (let i = 0; i < 10; i++) {
      console.log(i);
    }
  }
}
]]
      test_bufnr = helper.create_test_buffer(content, "javascript")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      display.update_display(test_bufnr)

      local ns_id = vim.api.nvim_create_namespace("treesitter-cyclomatic-complexity")
      local extmarks = vim.api.nvim_buf_get_extmarks(test_bufnr, ns_id, 0, -1, {})

      assert(#extmarks > 0, "Should create extmarks for JavaScript")
    end)

    it("displays complexity for Python", function()
      local content = [[
def test():
    if condition:
        for i in range(10):
            print(i)
]]
      test_bufnr = helper.create_test_buffer(content, "python")
      assert(helper.wait_for_treesitter(test_bufnr), "Treesitter parsing failed")

      display.update_display(test_bufnr)

      local ns_id = vim.api.nvim_create_namespace("treesitter-cyclomatic-complexity")
      local extmarks = vim.api.nvim_buf_get_extmarks(test_bufnr, ns_id, 0, -1, {})

      assert(#extmarks > 0, "Should create extmarks for Python")
    end)
  end)

  describe("error handling", function()
    it("handles invalid buffer gracefully", function()
      local invalid_bufnr = 99999

      -- Should not error
      display.update_display(invalid_bufnr)
      display.clear_complexity(invalid_bufnr)
      display.toggle_display(invalid_bufnr)
    end)

    it("handles buffer without treesitter parser", function()
      test_bufnr = helper.create_test_buffer("plain text", "text")

      -- Should not error
      display.update_display(test_bufnr)

      local ns_id = vim.api.nvim_create_namespace("treesitter-cyclomatic-complexity")
      local extmarks = vim.api.nvim_buf_get_extmarks(test_bufnr, ns_id, 0, -1, {})

      assert(#extmarks == 0, "Should not create extmarks for unsupported buffer")
    end)
  end)
end)
