local expect = MiniTest.expect

local levels = require("treesitter-cyclomatic-complexity.complexity.levels")

local thresholds = { low = 5, medium = 10, high = 15 }

describe("levels", function()
	describe("get_level()", function()
		describe("with default thresholds", function()
			it("should return 'low' when complexity is at or below low threshold", function()
				expect.equality(levels.get_level(1, thresholds), "low")
				expect.equality(levels.get_level(5, thresholds), "low")
			end)

			it("should return 'medium' when complexity is between low and medium thresholds", function()
				expect.equality(levels.get_level(6, thresholds), "medium")
				expect.equality(levels.get_level(10, thresholds), "medium")
			end)

			it("should return 'high' when complexity is between medium and high thresholds", function()
				expect.equality(levels.get_level(11, thresholds), "high")
				expect.equality(levels.get_level(15, thresholds), "high")
			end)

			it("should return 'very_high' when complexity exceeds high threshold", function()
				expect.equality(levels.get_level(16, thresholds), "very_high")
				expect.equality(levels.get_level(100, thresholds), "very_high")
			end)

			it("should classify boundary values correctly", function()
				expect.equality(levels.get_level(5, thresholds), "low")
				expect.equality(levels.get_level(6, thresholds), "medium")
				expect.equality(levels.get_level(11, thresholds), "high")
				expect.equality(levels.get_level(16, thresholds), "very_high")
			end)
		end)

		describe("with custom thresholds", function()
			it("should classify using provided thresholds", function()
				local custom = { low = 3, medium = 7, high = 12 }
				expect.equality(levels.get_level(3, custom), "low")
				expect.equality(levels.get_level(4, custom), "medium")
				expect.equality(levels.get_level(8, custom), "high")
				expect.equality(levels.get_level(13, custom), "very_high")
			end)
		end)
	end)

	describe("default_thresholds", function()
		it("should have expected default values", function()
			expect.equality(levels.default_thresholds.low, 5)
			expect.equality(levels.default_thresholds.medium, 10)
			expect.equality(levels.default_thresholds.high, 15)
		end)
	end)
end)
