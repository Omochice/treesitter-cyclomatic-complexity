local expect = MiniTest.expect

local config = require("treesitter-cyclomatic-complexity.config")

describe("config", function()
	describe("setup()", function()
		describe("given the cyclomatic metric", function()
			it("should default thresholds to the limit of 10", function()
				config.setup({ metric = "cyclomatic" })

				expect.equality(config.get("thresholds"), { low = 5, medium = 10, high = 15 })
			end)
		end)

		describe("given the cognitive metric", function()
			it("should default thresholds to the limit of 15", function()
				config.setup({ metric = "cognitive" })

				expect.equality(config.get("thresholds"), { low = 8, medium = 15, high = 23 })
			end)
		end)

		describe("given an unknown metric", function()
			it("should fall back to the cyclomatic defaults", function()
				config.setup({ metric = "nonsense" })

				expect.equality(config.get("metric"), "cyclomatic")
				expect.equality(config.get("thresholds"), { low = 5, medium = 10, high = 15 })
			end)
		end)

		describe("given explicit thresholds", function()
			it("should keep them whichever metric is selected", function()
				config.setup({ metric = "cognitive", thresholds = { low = 3, medium = 7, high = 12 } })

				expect.equality(config.get("thresholds"), { low = 3, medium = 7, high = 12 })
			end)

			it("should fill the missing ones from the metric's defaults", function()
				config.setup({ metric = "cognitive", thresholds = { low = 3 } })

				expect.equality(config.get("thresholds"), { low = 3, medium = 15, high = 23 })
			end)
		end)
	end)
end)
