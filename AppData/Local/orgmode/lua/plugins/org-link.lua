return {
  "seflue/org-link.nvim",
  dependencies = { "nvim-orgmode/orgmode" },
  opts = {
    -- path = { max_up = 2 }, -- 相対linkとして許容する"../"の最大数。
    -- picker = "auto",      -- "auto"|"yazi"|"snacks"|"uiinput"。
    -- pickers = {
    --   yazi = { cwd = nil, float = { width = 0.9, height = 0.85, border = "rounded" } },
    --   snacks = { cwd = nil, dirs = nil, ft = nil, hidden = false,
    --     ignored = false, args = nil },
    -- },
    -- keymaps = { -- 各値はfalse、またはmode/lhs/desc/ftを持つtable。
    --   insert = {}, insert_imode = {}, insert_visual = {}, yank_position = {},
    --   promote = {}, promote_visual = {}, follow_split = {}, follow_vsplit = {},
    --   follow_pick = {}, follow_options = {},
    -- },
    -- follow = {
    --   window_picker = { chars = "fjdksla;cmrueiwoqp", filter = nil },
    --   debug = false, -- org-roam id解決失敗をDEBUG通知する。
    --   handlers = {}, -- handler名 -> 関数、または{open,in_window}。
    --   by_type = {},  -- 拡張子/directory -> handler名配列。
    -- },
  },
}
