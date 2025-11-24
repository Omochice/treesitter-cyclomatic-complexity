-- Tests for complexity/init.lua (facade module)
-- Pure unit tests - no Neovim API required

describe("complexity", function()
  local complexity
  local helpers

  setup(function()
    complexity = require("treesitter-cyclomatic-complexity.complexity")
    helpers = require("spec.helpers")
  end)

  describe("calculate_function_complexity", function()
    it("returns 1 for empty function (base complexity)", function()
      local node_data = helpers.make_function("lua", {})
      assert.equals(1, complexity.calculate_function_complexity(node_data, "lua"))
    end)

    it("returns 2 for function with single if", function()
      local node_data = helpers.make_function("lua", {
        helpers.if_node({})
      })
      assert.equals(2, complexity.calculate_function_complexity(node_data, "lua"))
    end)

    it("returns correct complexity for multiple control flows", function()
      local node_data = helpers.make_function("lua", {
        helpers.if_node({}),
        helpers.for_node({}),
        helpers.while_node({})
      })
      assert.equals(4, complexity.calculate_function_complexity(node_data, "lua"))
    end)

    it("returns correct complexity for nested structures", function()
      local node_data = helpers.make_function("lua", {
        helpers.if_node({
          helpers.for_node({
            helpers.while_node({})
          })
        })
      })
      assert.equals(4, complexity.calculate_function_complexity(node_data, "lua"))
    end)

    it("counts logical operators", function()
      local node_data = helpers.make_function("javascript", {
        helpers.if_node({
          helpers.binary_expr("&&", {})
        })
      })
      assert.equals(3, complexity.calculate_function_complexity(node_data, "javascript"))
    end)

    it("returns 1 for unsupported language", function()
      local node_data = helpers.make_node("function_definition", {
        helpers.if_node({})
      })
      assert.equals(1, complexity.calculate_function_complexity(node_data, "unsupported"))
    end)
  end)

  describe("calculate_loop_complexity", function()
    it("returns 1 for simple loop (base complexity)", function()
      local node_data = helpers.for_node({})
      assert.equals(1, complexity.calculate_loop_complexity(node_data, "lua"))
    end)

    it("returns 2 for loop with single nested if", function()
      local node_data = helpers.for_node({
        helpers.if_node({})
      })
      assert.equals(2, complexity.calculate_loop_complexity(node_data, "lua"))
    end)

    it("returns correct complexity for loop with multiple control flows", function()
      local node_data = helpers.for_node({
        helpers.if_node({}),
        helpers.while_node({})
      })
      assert.equals(3, complexity.calculate_loop_complexity(node_data, "lua"))
    end)

    it("returns 1 for unsupported language", function()
      local node_data = helpers.for_node({
        helpers.if_node({})
      })
      assert.equals(1, complexity.calculate_loop_complexity(node_data, "unsupported"))
    end)
  end)

  describe("get_complexity_level", function()
    it("delegates to levels module", function()
      local thresholds = { low = 5, medium = 10, high = 15 }
      assert.equals("low", complexity.get_complexity_level(1, thresholds))
      assert.equals("medium", complexity.get_complexity_level(6, thresholds))
      assert.equals("high", complexity.get_complexity_level(11, thresholds))
      assert.equals("very_high", complexity.get_complexity_level(16, thresholds))
    end)
  end)

  describe("calculate_node_complexity", function()
    it("calculates function complexity when type is function", function()
      local node_info = {
        type = "function",
        node_data = helpers.make_function("lua", {
          helpers.if_node({})
        })
      }
      assert.equals(2, complexity.calculate_node_complexity(node_info, "lua"))
    end)

    it("calculates loop complexity when type is loop", function()
      local node_info = {
        type = "loop",
        node_data = helpers.for_node({
          helpers.if_node({})
        })
      }
      assert.equals(2, complexity.calculate_node_complexity(node_info, "lua"))
    end)

    it("returns 1 for unknown type", function()
      local node_info = {
        type = "unknown",
        node_data = helpers.make_node("unknown", {})
      }
      assert.equals(1, complexity.calculate_node_complexity(node_info, "lua"))
    end)
  end)
end)
