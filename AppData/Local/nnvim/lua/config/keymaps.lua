-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- lua/config/keymaps.lua

-- ╭─────────────────────────────────────────────────────────╮
-- │ セッション                                              │
-- ╰─────────────────────────────────────────────────────────╯
vim.keymap.set("n", "<F3>l", "<cmd>SessionManager load_session<CR>")
vim.keymap.set("n", "<F3>s", "<cmd>SessionManager save_current_session<CR>")

vim.keymap.set("n", "<localleader>qq", function()
  vim.cmd(":SessionManager save_current_session")
  vim.cmd(":qa!")
end, { desc = "close all" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ configフォルダー開く                                    │
-- ╰─────────────────────────────────────────────────────────╯
vim.keymap.set("n", "<F1>", "<nop>")

vim.keymap.set("n", "<F1>d", function()
  Snacks.explorer({
    cwd = vim.fn.stdpath("data"),
  })
end, { desc = "Snacks Explorer @ data" })

vim.keymap.set("n", "<F1>c", function()
  Snacks.explorer({
    cwd = vim.fn.stdpath("config"),
  })
end, { desc = "Snacks Explorer @ config" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ snack explolor開く                                      │
-- ╰─────────────────────────────────────────────────────────╯
local function focus_snacks_explorer(opts)
  opts = opts or {}

  -- 既に開いている Snacks explorer を探す
  local pickers = Snacks.picker.get({ source = "explorer" })

  for _, picker in ipairs(pickers or {}) do
    if picker and not picker.closed then
      picker:focus("list", { show = true })
      return
    end
  end

  -- なければ新しく開く
  Snacks.explorer(vim.tbl_deep_extend("force", {
    focus = "list",
    enter = true,
  }, opts))
end

vim.keymap.set("n", "<leader>e", function()
  focus_snacks_explorer()
end, { desc = "Focus Snacks Explorer" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ dashboard                                               │
-- ╰─────────────────────────────────────────────────────────╯
vim.keymap.set("n", "<localleader>;", function()
  Snacks.dashboard()
end, { desc = "Open Snacks Dashboard" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ project-pane                                            │
-- ╰─────────────────────────────────────────────────────────╯
vim.keymap.set("n", "<localleader>pp", function()
  require("project-pane").toggle()
end, { desc = "Toggle project pane" })

vim.keymap.set("n", "<localleader>pa", function()
  require("project-pane").add_project()
end, { desc = "Add project pane" })
-- ╭─────────────────────────────────────────────────────────╮
-- │ neotree config                                          │
-- ╰─────────────────────────────────────────────────────────╯
-- vim.keymap.set("n", "<leader>e", "<cmd>Neotree reveal
-- focus<cr>", {
-- desc = "Explorer Neo-tree",
-- })
-- vim.keymap.set("n", "<F1>d", function()
-- vim.cmd("Neotree reveal dir=" ..
-- vim.fn.fnameescape(vim.fn.stdpath("data")))
-- end, { desc = "Neotree @ data" })
--
-- vim.keymap.set("n", "<F1>c", function()
-- vim.cmd("Neotree reveal dir=" ..
-- vim.fn.fnameescape(vim.fn.stdpath("config")))
-- end, { desc = "Neotree @ config" })
-- vim.keymap.set("n", "<localleader>e", ":Neotree left <CR>", { desc = "neotree" })
--
--vim.keymap.set("n", "<localleader>e", "<cmd>Neotree reveal right focus<cr>", {
--desc = "Open/Focus Neo-tree",
--})
--
--vim.keymap.set("n", "<localleader>E", "<cmd>Neotree close<cr>", {
--desc = "Close Neo-tree",
--})
