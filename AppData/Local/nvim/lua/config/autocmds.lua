-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- LazyVim enables spell checking for prose filetypes after the global
-- `set nospell` in init.lua. Japanese Markdown is then marked with distracting
-- red undercurls, so disable spell checking only for Markdown buffers while
-- keeping LazyVim's wrapping and diagnostics for every other filetype.
local markdown_no_spell = vim.api.nvim_create_augroup("markdown_no_spell", { clear = true })

vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  group = markdown_no_spell,
  pattern = { "markdown", "markdown.mdx", "*.md", "*.mdx" },
  callback = function(args)
    local filetype = vim.bo[args.buf].filetype
    if filetype == "markdown" or filetype == "markdown.mdx" then
      vim.opt_local.spell = false
    end
  end,
  desc = "Disable spell-check undercurls in Markdown",
})
