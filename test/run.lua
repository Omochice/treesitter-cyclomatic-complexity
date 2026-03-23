require("mini.test").setup({
	collect = {
		find_files = function()
			local files = {}
			for _, dir in ipairs({ "test/unit", "test/e2e" }) do
				for _, file in ipairs(vim.fn.glob(dir .. "/*.test.lua", true, true)) do
					table.insert(files, file)
				end
			end
			return files
		end,
	},
})

MiniTest.run()
