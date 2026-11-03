vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.conceallevel = 2
vim.opt.concealcursor = "nc"

local data_dir = vim.fn.stdpath("data")
local org_files_dir = data_dir .. "/orgfiles"
vim.fn.mkdir(org_files_dir, "p")
vim.fn.mkdir(data_dir .. "/org_roam_files", "p")

local lazypath = data_dir .. "/.lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local result = vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Failed to clone lazy.nvim:\n" .. result)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  defaults = { lazy = false, version = false },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = false, notify = false },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
})
