-- 試用目的の単一ファイル Neovim 設定
-- 起動: nvim -u init.lua
--
-- 導入プラグイン:
--   atiladefreitas/dooing        シンプルな ToDo リスト管理
--   itchyny/calendar.vim         カレンダー表示 (calendar.vim)
--   MattHandzel/taskwarrior.nvim Taskwarrior のタスクを Markdown として編集
--
-- 注: "blocky.nvim" は該当プラグインを特定できなかったため未収録。

-- lazy.nvim を自動ブートストラップ
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "

require("lazy").setup({
	-- ToDo リスト管理
	{
		"atiladefreitas/dooing",
		cmd = { "Dooing" },
		keys = {
			{ "<leader>td", "<cmd>Dooing<cr>", desc = "Toggle Dooing" },
		},
		opts = {},
	},

	-- カレンダー表示 (:Calendar)
	{
		"itchyny/calendar.vim",
		cmd = { "Calendar", "CalendarH", "CalendarVR" },
		keys = {
			{ "<leader>ca", "<cmd>Calendar<cr>", desc = "Open Calendar" },
		},
	},

	-- Taskwarrior 連携 (:Task)
	{
		"MattHandzel/taskwarrior.nvim",
		cmd = { "Task", "TaskFilter", "TaskSort", "TaskGroup", "TaskRefresh", "TaskAdd", "TaskUndo" },
		keys = {
			{ "<leader>tw", "<cmd>Task<cr>", desc = "Open Taskwarrior" },
			{ "<leader>tn", "<cmd>TaskAdd<cr>", desc = "Add Task (quick capture)" },
		},
		config = function()
			require("taskwarrior").setup()
		end,
	},
})

-- 動作確認用の最低限のオプション
vim.opt.number = true
vim.opt.termguicolors = true
