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
		it("should anchor cyclomatic on the limit of 10", function()
			expect.equality(levels.default_thresholds.cyclomatic, { low = 5, medium = 10, high = 15 })
		end)

		it("should anchor cognitive on the limit of 15", function()
			expect.equality(levels.default_thresholds.cognitive, { low = 8, medium = 15, high = 23 })
		end)
	end)

	describe("get_default_thresholds()", function()
		describe("given a known metric", function()
			it("should return that metric's thresholds", function()
				expect.equality(levels.get_default_thresholds("cognitive"), levels.default_thresholds.cognitive)
			end)
		end)

		describe("given an unknown metric", function()
			it("should fall back to cyclomatic", function()
				expect.equality(levels.get_default_thresholds("nonsense"), levels.default_thresholds.cyclomatic)
			end)
		end)
	end)
end)
