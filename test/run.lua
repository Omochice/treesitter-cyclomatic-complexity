local function save_luacov_stats()
	local ok, runner = pcall(require, "luacov.runner")
	if ok then
		runner.save_stats()
	end
end

-- Neovim's `-l` flag calls C-level os_exit() without closing Lua state,
-- so LuaCov's atexit handler never fires.
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = save_luacov_stats,
})

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
save_luacov_stats()
