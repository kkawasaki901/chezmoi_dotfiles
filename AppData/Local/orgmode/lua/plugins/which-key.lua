return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- preset = "classic", -- false|"classic"|"modern"|"helix"。
    -- delay = 200,         -- popup待ち時間。contextを受け取る関数も可。
    -- filter = function(mapping) return true end, -- 表示対象判定。
    -- spec = {}, notify = true, triggers = { { "<auto>", mode = "nxso" } },
    -- defer = function(ctx) return ctx.mode == "V" or ctx.mode == "<C-V>" end,
    -- plugins = { marks = true, registers = true,
    --   spelling = { enabled = true, suggestions = 20 },
    --   presets = { operators = true, motions = true, text_objects = true,
    --     windows = true, nav = true, z = true, g = true } },
    -- win = { no_overlap = true, width = nil, height = nil, col = nil, row = nil,
    --   border = nil, padding = { 1, 2 }, title = true, title_pos = "center",
    --   zindex = 1000, bo = {}, wo = {} },
    -- layout = { width = { min = 20 }, spacing = 3 },
    -- keys = { scroll_down = "<c-d>", scroll_up = "<c-u>" },
    -- sort = { "local", "order", "group", "alphanum", "mod" },
    -- expand = 0, -- mapping数がこの値以下のgroupを展開。判定関数も可。
    -- replace = { key = {}, desc = {} }, -- label置換関数/Lua pattern。
    -- icons = { breadcrumb = "»", separator = "➜", group = "+", ellipsis = "…",
    --   mappings = true, rules = {}, colors = true, keys = {} },
    -- show_help = true, show_keys = true,
    -- disable = { ft = {}, bt = {} }, debug = false,
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add({
      { "<leader>o", group = "Orgmode" },
      { "<leader>oa", "<cmd>Org agenda<cr>", desc = "Agenda Prompt" },
      { "<leader>oc", "<cmd>Org capture<cr>", desc = "Capture Prompt" },
      { "<leader>oe", "<cmd>Org export<cr>", desc = "Export Prompt" },
      { "<leader>ot", group = "Telescope Orgmode" },
      { "<leader>oth", "<cmd>Telescope orgmode search_headings<cr>", desc = "Search Headings" },
      { "<leader>otr", "<cmd>Telescope orgmode refile_headings<cr>", desc = "Refile Headings" },
      { "<leader>otl", "<cmd>Telescope orgmode insert_link<cr>", desc = "Insert Link" },
      { "<leader>otf", "<cmd>Telescope orgmode orgfiles<cr>", desc = "Search Org Files" },
      { "<leader>on", group = "Org Roam" },
      { "<leader>onc", "<cmd>OrgRoamCapture<cr>", desc = "Roam Capture" },
      { "<leader>onf", "<cmd>OrgRoamNodeFind<cr>", desc = "Find/Create Roam Node" },
    })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "org",
      callback = function(args)
        wk.add({
          { "<leader>o", group = "Orgmode", buffer = args.buf },
          { "<leader>ot", desc = "Toggle Todo State", buffer = args.buf },
          { "<leader>op", desc = "Set Priority", buffer = args.buf },
          { "<leader>oA", desc = "Archive Subtree", buffer = args.buf },
          { "<leader>or", desc = "Refile Subtree", buffer = args.buf },
          { "<leader>oi", group = "Insert", buffer = args.buf },
          { "<leader>oid", desc = "Insert Deadline", buffer = args.buf },
          { "<leader>ois", desc = "Insert Scheduled", buffer = args.buf },
          { "<leader>oit", desc = "Insert Timestamp (Active)", buffer = args.buf },
          { "<leader>oiT", desc = "Insert Timestamp (Inactive)", buffer = args.buf },
          { "<leader>oI", desc = "Insert Link (Standard)", buffer = args.buf },
          { "<leader>oo", desc = "Open Link under Cursor", buffer = args.buf },
          { "<leader>o,", desc = "Set Tags / Metadata", buffer = args.buf },
          { "<leader>oP", desc = "Set Property", buffer = args.buf },
          { "g?", desc = "Org Help Menu", buffer = args.buf },
          { "<leader>oni", "<cmd>OrgRoamNodeInsert<cr>", desc = "Insert Roam Node", buffer = args.buf },
          { "<leader>onm", "<cmd>OrgRoamNodeInsertImmediate<cr>", desc = "Insert Roam Node Immediate", buffer = args.buf },
          { "<leader>onn", "<cmd>OrgRoamGoToNextNode<cr>", desc = "Go to Next Node", buffer = args.buf },
          { "<leader>onp", "<cmd>OrgRoamGoToPrevNode<cr>", desc = "Go to Prev Node", buffer = args.buf },
          { "<leader>na", "<cmd>OrgRoamAddAlias<cr>", desc = "Add Node Alias", buffer = args.buf },
          { "<leader>no", "<cmd>OrgRoamAddOrigin<cr>", desc = "Add Node Origin", buffer = args.buf },
        })
      end,
    })
  end,
}
