return {
  "chipsenkbeil/org-roam.nvim",
  tag = "0.2.0",
  dependencies = { "nvim-orgmode/orgmode" },
  opts = {
    directory = vim.fn.stdpath("data") .. "/org_roam_files", -- roam対象Org directory。
    -- bindings = { -- falseで個別bindingを無効化可能。
    --   prefix = "<Leader>n", add_alias = "<prefix>aa", add_origin = "<prefix>oa",
    --   capture = "<prefix>c", complete_at_point = "<prefix>.", find_node = "<prefix>f",
    --   goto_next_node = "<prefix>n", goto_prev_node = "<prefix>p",
    --   insert_node = "<prefix>i", insert_node_immediate = "<prefix>m",
    --   quickfix_backlinks = "<prefix>q", remove_alias = "<prefix>ar",
    --   remove_origin = "<prefix>or", toggle_roam_buffer = "<prefix>l",
    --   toggle_roam_buffer_fixed = "<prefix>b",
    -- },
    -- capture = { include_origin = true },
    -- database = { path = vim.fn.stdpath("data").."/org-roam.nvim/db",
    --   persist = true, update_on_save = true },
    -- extensions = { dailies = { directory = "daily", bindings = {}, templates = {},
    --   ui = { calendar = { hl_date_exists = "WarningMsg" } } } },
    -- org_files = {}, -- roam directory外から追加で読むfile/directory/glob。
    -- immediate = { target = "%<%Y%m%d%H%M%S>-%[slug].org", template = "" },
    -- templates = { d = { description = "default", template = "%?",
    --   target = "%<%Y%m%d%H%M%S>-%[slug].org" } },
    -- ui = {
    --   select = { node_to_items = function(node) return { node.title } end },
    --   node_buffer = { focus_on_toggle = true, highlight_previews = true,
    --     open = "botright vsplit | vertical resize 50", show_keybindings = true,
    --     unique = false },
    -- },
  },
}
