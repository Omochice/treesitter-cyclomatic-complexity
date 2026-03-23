-- Tests for complexity/levels.lua
-- Pure unit tests - no Neovim API required

describe("levels", function()
	local levels

	setup(function()
		levels = require("treesitter-cyclomatic-complexity.complexity.levels")
	end)

	describe("get_level", function()
		local thresholds = { low = 5, medium = 10, high = 15 }

		it("returns 'low' for complexity <= threshold.low", function()
			assert.equals("low", levels.get_level(1, thresholds))
			assert.equals("low", levels.get_level(5, thresholds))
		end)

		it("returns 'medium' for complexity > low and <= medium", function()
			assert.equals("medium", levels.get_level(6, thresholds))
			assert.equals("medium", levels.get_level(10, thresholds))
		end)

		it("returns 'high' for complexity > medium and <= high", function()
			assert.equals("high", levels.get_level(11, thresholds))
			assert.equals("high", levels.get_level(15, thresholds))
		end)

		it("returns 'very_high' for complexity > threshold.high", function()
			assert.equals("very_high", levels.get_level(16, thresholds))
			assert.equals("very_high", levels.get_level(100, thresholds))
		end)

		it("handles edge cases at threshold boundaries", function()
			assert.equals("low", levels.get_level(5, thresholds))
			assert.equals("medium", levels.get_level(6, thresholds))
			assert.equals("high", levels.get_level(11, thresholds))
			assert.equals("very_high", levels.get_level(16, thresholds))
		end)

		it("works with custom thresholds", function()
			local custom = { low = 3, medium = 7, high = 12 }
			assert.equals("low", levels.get_level(3, custom))
			assert.equals("medium", levels.get_level(4, custom))
			assert.equals("high", levels.get_level(8, custom))
			assert.equals("very_high", levels.get_level(13, custom))
		end)
	end)

	describe("default_thresholds", function()
		it("has expected default values", function()
			assert.equals(5, levels.default_thresholds.low)
			assert.equals(10, levels.default_thresholds.medium)
			assert.equals(15, levels.default_thresholds.high)
		end)
	end)
end)
