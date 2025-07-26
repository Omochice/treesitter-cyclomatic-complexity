local config = require("treesitter-cyclomatic-complexity.config")

describe("configuration module", function()
  local original_vim_g

  before_each(function()
    -- Reset config to defaults
    config.options = {}
    original_vim_g = vim.g.treesitter_cyclomatic_complexity
    vim.g.treesitter_cyclomatic_complexity = nil
  end)

  after_each(function()
    vim.g.treesitter_cyclomatic_complexity = original_vim_g
  end)

  describe("default configuration", function()
    it("has correct default values", function()
      local defaults = config.defaults

      helper.assert.is_true(defaults.enabled)
      helper.assert.is_true(defaults.auto_update)
      helper.assert.are.equal("CC: %d", defaults.display.format)
      helper.assert.are.equal("Comment", defaults.display.highlight)
      helper.assert.are.equal("eol", defaults.display.position)
      helper.assert.are.equal(5, defaults.thresholds.low)
      helper.assert.are.equal(10, defaults.thresholds.medium)
      helper.assert.are.equal(15, defaults.thresholds.high)

      -- Check language defaults
      helper.assert.is_true(defaults.languages.lua)
      helper.assert.is_true(defaults.languages.javascript)
      helper.assert.is_true(defaults.languages.python)
    end)
  end)

  describe("setup", function()
    it("uses defaults when no options provided", function()
      config.setup()

      local options = config.get()
      helper.assert.is_true(options.enabled)
      helper.assert.is_true(options.auto_update)
      helper.assert.are.equal("CC: %d", options.display.format)
    end)

    it("merges provided options with defaults", function()
      config.setup({
        enabled = false,
        thresholds = {
          low = 3,
          medium = 7,
        },
      })

      local options = config.get()
      helper.assert.is_false(options.enabled)
      helper.assert.are.equal(3, options.thresholds.low)
      helper.assert.are.equal(7, options.thresholds.medium)
      helper.assert.are.equal(15, options.thresholds.high) -- Should keep default
      helper.assert.are.equal("CC: %d", options.display.format) -- Should keep default
    end)

    it("merges with vim global variable", function()
      vim.g.treesitter_cyclomatic_complexity = {
        thresholds = {
          low = 2,
          medium = 6,
        },
        display = {
          format = "Complexity: %d",
        },
      }

      config.setup({
        enabled = false,
      })

      local options = config.get()
      assert.is_false(options.enabled) -- From setup opts
      assert.are.equal(2, options.thresholds.low) -- From vim.g
      assert.are.equal(6, options.thresholds.medium) -- From vim.g
      assert.are.equal("Complexity: %d", options.display.format) -- From vim.g
    end)

    it("prioritizes setup options over vim global", function()
      vim.g.treesitter_cyclomatic_complexity = {
        enabled = true,
        thresholds = { low = 2 },
      }

      config.setup({
        enabled = false,
        thresholds = { low = 8 },
      })

      local options = config.get()
      assert.is_false(options.enabled) -- setup wins
      assert.are.equal(8, options.thresholds.low) -- setup wins
    end)
  end)

  describe("configuration validation", function()
    it("validates boolean fields", function()
      local test_config = {
        enabled = "not_boolean",
        auto_update = 123,
      }

      local validated = config.validate_config(test_config)
      assert.is_true(validated.enabled) -- Should fallback to default
      assert.is_true(validated.auto_update) -- Should fallback to default
    end)

    it("validates display configuration", function()
      local test_config = {
        display = "not_table",
      }

      local validated = config.validate_config(test_config)
      assert.are.equal("table", type(validated.display))
      assert.are.equal("CC: %d", validated.display.format)
    end)

    it("validates partial display configuration", function()
      local test_config = {
        display = {
          format = "Custom: %d",
          -- missing highlight and position
        },
      }

      local validated = config.validate_config(test_config)
      assert.are.equal("Custom: %d", validated.display.format)
      assert.are.equal("Comment", validated.display.highlight) -- Default
      assert.are.equal("eol", validated.display.position) -- Default
    end)

    it("validates thresholds configuration", function()
      local test_config = {
        thresholds = "not_table",
      }

      local validated = config.validate_config(test_config)
      assert.are.equal("table", type(validated.thresholds))
      assert.are.equal(5, validated.thresholds.low)
    end)

    it("validates partial thresholds configuration", function()
      local test_config = {
        thresholds = {
          low = 3,
          -- missing medium and high
        },
      }

      local validated = config.validate_config(test_config)
      assert.are.equal(3, validated.thresholds.low)
      assert.are.equal(10, validated.thresholds.medium) -- Default
      assert.are.equal(15, validated.thresholds.high) -- Default
    end)

    it("validates languages configuration", function()
      local test_config = {
        languages = "not_table",
      }

      local validated = config.validate_config(test_config)
      assert.are.equal("table", type(validated.languages))
      assert.is_true(validated.languages.lua) -- Default
    end)
  end)

  describe("getter and setter functions", function()
    it("gets specific configuration values", function()
      config.setup({
        enabled = false,
        thresholds = { low = 3 },
      })

      assert.is_false(config.get("enabled"))
      assert.are.equal("table", type(config.get("thresholds")))
      assert.are.equal(3, config.get("thresholds").low)
    end)

    it("gets entire configuration when no key provided", function()
      config.setup()

      local options = config.get()
      assert.are.equal("table", type(options))
      assert.is_not_nil(options.enabled)
      assert.is_not_nil(options.display)
      assert.is_not_nil(options.thresholds)
    end)

    it("sets configuration values", function()
      config.setup()
      config.set("enabled", false)

      assert.is_false(config.get("enabled"))
    end)

    it("updates configuration", function()
      config.setup({
        enabled = true,
        thresholds = { low = 5 },
      })

      config.update({
        enabled = false,
        thresholds = { medium = 12 },
      })

      local options = config.get()
      assert.is_false(options.enabled) -- Updated
      assert.are.equal(5, options.thresholds.low) -- Preserved
      assert.are.equal(12, options.thresholds.medium) -- Updated
      assert.is_true(options.auto_update) -- Preserved default
    end)

    it("validates on update", function()
      config.setup()

      config.update({
        enabled = "not_boolean",
        thresholds = "not_table",
      })

      local options = config.get()
      assert.is_true(options.enabled) -- Should fallback to current value
      assert.are.equal("table", type(options.thresholds)) -- Should preserve current
    end)
  end)

  describe("edge cases", function()
    it("handles nil options gracefully", function()
      config.setup(nil)

      local options = config.get()
      assert.is_not_nil(options)
      assert.is_true(options.enabled) -- Should use defaults
    end)

    it("handles empty options table", function()
      config.setup({})

      local options = config.get()
      assert.is_not_nil(options)
      assert.is_true(options.enabled) -- Should use defaults
    end)

    it("handles getting non-existent key", function()
      config.setup()

      local value = config.get("non_existent_key")
      assert.is_nil(value)
    end)

    it("handles setting when options is nil", function()
      config.options = nil

      -- Should not error
      config.set("enabled", false)

      -- Options should still be nil
      assert.is_nil(config.options)
    end)
  end)
end)
