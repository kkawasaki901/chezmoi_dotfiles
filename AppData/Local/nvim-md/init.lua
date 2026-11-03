vim.g.mapleader = " "
vim.opt.termguicolors = true
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.cmd("syntax enable")
vim.api.nvim_create_autocmd("FileType", { pattern = "markdown", callback = function()
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
  vim.opt_local.conceallevel = 0
end })
local function picker(kind)
  require("fzf-lua")[kind]({ cwd = vim.fn.getcwd(), file_icons = false, git_icons = false,
    cmd = kind == "files" and "rg --files -g *.md -g *.markdown" or nil,
    rg_opts = "--column --line-number --no-heading --color=always --smart-case -g *.md -g *.markdown" })
end
vim.keymap.set("n", "<leader>f", function() picker("files") end)
vim.keymap.set("n", "<leader>g", function() picker("live_grep") end)
require("md_links").setup()
