-- Lazy.nvim plugin specs for:
-- sidebar.nvim, goto-preview, edgy.nvim, neogit, vim-table-mode, glow.nvim,
-- nvim-scrollbar, LuaSnip, friendly-snippets, lspkind.nvim, vim-visual-multi,
-- nvim-rip-substitute, projectlaunch.nvim, substitute.nvim, helpview.nvim,
-- vim-bookmarks, leap.nvim, SmoothCursor.nvim, hlchunk.nvim,
-- nvim-treesitter-context, dropbar.nvim, nvim-ufo, grug-far.nvim,
-- glance.nvim, namu.nvim, nvim-colorizer.lua, treesj, gitgraph.nvim,
-- lasterisk.nvim, no-neck-pain.nvim, nvim-bqf, winresize.nvim,
-- table-format.nvim, overseer.nvim, fyler.nvim, flit.nvim, vim-tmux-navigator.
--
-- Usage:
-- 1. Put this file at: ~/.config/nvim/lua/plugins/many-plugins.lua
-- 2. Run :Lazy sync
-- 3. Uncomment the key examples you want and replace <leader>... as needed.
--
-- Note:
-- - petertriho/nvim-scrollbar was listed twice, so it appears once below.
-- - Most keymaps are intentionally commented out.
-- - Some Vimscript plugins have their own default mappings. See each comment.

return {
  -- Generic sidebar.
  -- Commands:
  --   :SidebarNvimToggle          toggle sidebar
  --   :SidebarNvimOpen            open sidebar
  --   :SidebarNvimClose           close sidebar
  --   :SidebarNvimFocus           focus sidebar window
  --   :SidebarNvimResize 40       resize to width 40
  {
    "folke/which-key.nvim",

    opts = function(_, opts)
      opts.spec = opts.spec or {}

      vim.list_extend(opts.spec, {
        { "<F1>P", group = "Preview" },
        { "<F1>u", group = "Edgy" },
        { "<F1>b", group = "Bookmarks" },
        { "<F1>l", group = "Leap" },
        { "<F2>;", group = "DropBar" },
        { "<F1>z", group = "Fold" },
        { "<F3>g", group = "Glance" },
        { "<F4>s", group = "Nanu" },
        { "<F4>j", group = "Treesitter J" },
        { "<F4>o", group = "OverSea" },
        { "<F5>o", group = "Tmux" },
      })
    end,
  },
  {
    "sidebar-nvim/sidebar.nvim",
    cmd = {
      "SidebarNvimToggle",
      "SidebarNvimOpen",
      "SidebarNvimClose",
      "SidebarNvimUpdate",
      "SidebarNvimResize",
      "SidebarNvimFocus",
    },
    opts = {
      disable_default_keybindings = 1,
      open = false,
      side = "left",
      initial_width = 35,
      sections = { "datetime", "git", "diagnostics", "todos", "buffers", "files", "symbols" },
    },
    keys = {
      { "<F1>u", "<cmd>SidebarNvimToggle<cr>", desc = "Toggle sidebar" },
    },
  },

  -- Floating preview for LSP definitions/references.
  -- Lua API:
  --   require("goto-preview").goto_preview_definition()
  --   require("goto-preview").goto_preview_type_definition()
  --   require("goto-preview").goto_preview_implementation()
  --   require("goto-preview").goto_preview_declaration()
  --   require("goto-preview").goto_preview_references()
  --   require("goto-preview").close_all_win()
  {
    "rmagatti/goto-preview",
    event = "LspAttach",
    opts = {
      width = 120,
      height = 25,
      default_mappings = false,
      post_open_hook = nil,
    },
    keys = {
      {
        "<F1>pd",
        function()
          require("goto-preview").goto_preview_definition()
        end,
        desc = "Preview definition",
      },
      {
        "<F1>pt",
        function()
          require("goto-preview").goto_preview_type_definition()
        end,
        desc = "Preview type definition",
      },
      {
        "<F1>pi",
        function()
          require("goto-preview").goto_preview_implementation()
        end,
        desc = "Preview implementation",
      },
      {
        "<F1>pr",
        function()
          require("goto-preview").goto_preview_references()
        end,
        desc = "Preview references",
      },
      {
        "<F1>pc",
        function()
          require("goto-preview").close_all_win()
        end,
        desc = "Close previews",
      },
    },
  },

  -- Edgebar layout manager for side/bottom utility windows.
  -- Lua API:
  --   require("edgy").toggle("left")
  --   require("edgy").open("bottom")
  --   require("edgy").close()
  --   require("edgy").select()
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    opts = {
      left = {
        { title = "Sidebar", ft = "SidebarNvim" },
      },
      bottom = {
        { title = "Quickfix", ft = "qf" },
        { title = "Overseer", ft = "OverseerList" },
      },
      right = {},
    },
    keys = {
      {
        "<F1>ue",
        function()
          require("edgy").toggle()
        end,
        desc = "Toggle edgy",
      },
      {
        "<F1>uE",
        function()
          require("edgy").select()
        end,
        desc = "Select edgy window",
      },
    },
  },

  -- Magit-like Git UI.
  -- Commands:
  --   :Neogit                  open status
  --   :Neogit cwd=%:p:h        open repository of current file
  --   :Neogit commit           open commit popup
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      integrations = {
        diffview = true,
        telescope = true,
      },
    },
    keys = {
      { "<leader>gx", "<cmd>Neogit<cr>", desc = "Neogit" },
    },
  },

  -- Markdown-like table editing.
  -- Commands:
  --   :TableModeToggle         toggle table mode
  --   :TableModeEnable         enable table mode
  --   :TableModeDisable        disable table mode
  --   :Tableize                convert selected text to a table
  {
    "dhruvasagar/vim-table-mode",
    cmd = { "TableModeToggle", "TableModeEnable", "TableModeDisable", "Tableize" },
    init = function()
      vim.g.table_mode_disable_mappings = 1
    end,
    keys = {
      { "<F1>t", "<cmd>TableModeToggle<cr>", desc = "Toggle table mode" },
    },
  },

  -- Markdown preview using the external glow CLI.
  -- Commands:
  --   :Glow                    preview current markdown file
  --   :Glow path/to/file.md    preview a specific file
  --   :Glow!                   preview current buffer content
  {
    "ellisonleao/glow.nvim",
    cmd = "Glow",
    opts = {
      border = "rounded",
      width_ratio = 0.8,
      height_ratio = 0.8,
    },
    keys = {
      { "<F1>G", "<cmd>Glow<cr>", desc = "Glow markdown preview" },
    },
  },

  -- Scrollbar with optional search/diagnostic/git marks.
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "kevinhwang91/nvim-hlslens",
      "lewis6991/gitsigns.nvim",
    },
    opts = {
      show = true,
      handlers = {
        cursor = true,
        diagnostic = true,
        gitsigns = true,
        handle = true,
        search = true,
      },
    },
  },

  -- Snippet engine.
  -- Lua API:
  --   require("luasnip").expand()
  --   require("luasnip").jump(1)
  --   require("luasnip").jump(-1)
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    -- Optional. Needs a working C compiler and make.
    -- build = "make install_jsregexp",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip").config.setup({
        history = true,
        updateevents = "TextChanged,TextChangedI",
      })
    end,
    keys = {
      {
        "<tab>",
        function()
          require("luasnip").expand_or_jump()
        end,
        mode = { "i", "s" },
        desc = "Snippet expand/jump",
      },
      {
        "<s-tab>",
        function()
          require("luasnip").jump(-1)
        end,
        mode = { "i", "s" },
        desc = "Snippet jump back",
      },
    },
  },

  -- Community snippets loaded by LuaSnip.
  {
    "rafamadriz/friendly-snippets",
    lazy = true,
  },

  -- Completion item kind icons. Use from nvim-cmp config:
  --   formatting = { format = require("lspkind").cmp_format({ mode = "symbol_text" }) }
  {
    "onsails/lspkind.nvim",
    lazy = true,
  },

  -- Multiple cursors. This Vimscript plugin ships default mappings.
  -- Typical defaults include:
  --   <C-n>     select next occurrence
  --   <C-Up>    add cursor above
  --   <C-Down>  add cursor below
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
  },

  -- Search and replace popup powered by ripgrep.
  -- Commands:
  --   :RipSubstitute
  --   :RipSubstitute prefilled_text
  {
    "chrisgrieser/nvim-rip-substitute",
    cmd = "RipSubstitute",
    opts = {},
    keys = {
      {
        "<F1>s",
        function()
          require("rip-substitute").sub()
        end,
        mode = { "n", "x" },
        desc = "Rip substitute",
      },
    },
  },

  -- Run project-local commands from .projectlaunch.json.
  -- Open with:
  --   :lua require("projectlaunch").toggle_main_menu()
  -- In the menu:
  --   <CR> run command, q close, c custom command, e edit custom command
  {
    "sheodox/projectlaunch.nvim",
    cmd = "ProjectLaunch",
    opts = {
      split = "botright",
    },
    config = function(_, opts)
      require("projectlaunch").setup(opts)
      vim.api.nvim_create_user_command("ProjectLaunch", function()
        require("projectlaunch").toggle_main_menu()
      end, {})
    end,
    keys = {
      {
        "<F1>r",
        function()
          require("projectlaunch").toggle_main_menu()
        end,
        desc = "Project launch",
      },
    },
  },

  -- Substitute operator and exchange text.
  -- Lua API:
  --   require("substitute").operator()
  --   require("substitute").line()
  --   require("substitute").eol()
  --   require("substitute.exchange").operator()
  {
    "gbprod/substitute.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<F1>ss",
        function()
          require("substitute").operator()
        end,
        desc = "Substitute operator",
      },
      {
        "<F1>sl",
        function()
          require("substitute").line()
        end,
        desc = "Substitute line",
      },
      {
        "<F1>S",
        function()
          require("substitute").eol()
        end,
        desc = "Substitute to EOL",
      },
      {
        "<F1>s",
        function()
          require("substitute").visual()
        end,
        mode = "x",
        desc = "Substitute visual",
      },
    },
  },

  -- Pretty renderer for help files.
  -- Commands:
  --   :Helpview                 toggle current buffer preview
  --   :Helpview Toggle          toggle preview
  --   :Helpview Enable          enable preview
  --   :Helpview Disable         disable preview
  --{
  --"OXY2DEV/helpview.nvim",
  --ft = "help",
  --cmd = "Helpview",
  --opts = {},
  --},

  -- Persistent Vim bookmarks.
  -- Commands:
  --   :BookmarkToggle           toggle bookmark at current line
  --   :BookmarkAnnotate         add/edit annotation
  --   :BookmarkShowAll          show all bookmarks
  --   :BookmarkClear            clear current bookmark
  --   :BookmarkClearAll         clear all bookmarks
  {
    "mattesgroeger/vim-bookmarks",
    cmd = {
      "BookmarkToggle",
      "BookmarkAnnotate",
      "BookmarkShowAll",
      "BookmarkClear",
      "BookmarkClearAll",
      "BookmarkNext",
      "BookmarkPrev",
    },
    init = function()
      vim.g.bookmark_no_default_key_mappings = 1
      vim.g.bookmark_save_per_working_dir = 1
    end,
    keys = {
      { "<F1>bm", "<cmd>BookmarkToggle<cr>", desc = "Toggle bookmark" },
      { "<F1>ba", "<cmd>BookmarkAnnotate<cr>", desc = "Annotate bookmark" },
      { "<F1>bl", "<cmd>BookmarkShowAll<cr>", desc = "List bookmarks" },
    },
  },

  -- Fast jump/navigation. No default mappings are created below.
  -- Lua API:
  --   require("leap").leap({ target_windows = { vim.api.nvim_get_current_win() } })
  {
    url = "https://codeberg.org/andyg/leap.nvim.git",
    name = "leap.nvim",
    event = "VeryLazy",
    config = function()
      -- Uncomment if you want Leap's default mappings: s, S, gs.
      -- require("leap").create_default_mappings()
    end,
    keys = {
      {
        "<F1>ls",
        function()
          require("leap").leap({ target_windows = { vim.api.nvim_get_current_win() } })
        end,
        desc = "Leap in window",
      },
      {
        "<F1>lS",
        function()
          require("leap").leap()
        end,
        desc = "Leap across windows",
      },
    },
  },

  -- Animated cursor.
  -- Commands:
  --   :SmoothCursorToggle       toggle smooth cursor
  --   :SmoothCursorStart        start
  --   :SmoothCursorStop         stop
  --   :SmoothCursorStatus       show status
  {
    "gen740/SmoothCursor.nvim",
    event = "VeryLazy",
    main = "smoothcursor",
    opts = {
      autostart = true,
      fancy = {
        enable = true,
      },
    },
    keys = {
      { "<F2>s", "<cmd>SmoothCursorToggle<cr>", desc = "Toggle smooth cursor" },
    },
  },

  -- Indent/chunk highlighting.
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "hlchunk",
    opts = {
      chunk = { enable = true },
      indent = { enable = true },
      line_num = { enable = true },
      blank = { enable = true },
    },
  },

  -- Sticky Treesitter context at top of window.
  -- Commands:
  --   :TSContextToggle          toggle context
  --   :TSContextEnable          enable context
  --   :TSContextDisable         disable context
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      enable = true,
      max_lines = 3,
      trim_scope = "outer",
      mode = "cursor",
    },
  },

  -- Winbar breadcrumbs.
  -- Lua API:
  --   require("dropbar.api").pick()
  --   require("dropbar.api").goto_context_start()
  --   require("dropbar.api").select_next_context()
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      bar = {
        enable = true,
      },
    },
    keys = {
      {
        "<F2>;;",
        function()
          require("dropbar.api").pick()
        end,
        desc = "Dropbar pick",
      },
      {
        "<F2>;[",
        function()
          require("dropbar.api").goto_context_start()
        end,
        desc = "Context start",
      },
      {
        "<F2>;]",
        function()
          require("dropbar.api").select_next_context()
        end,
        desc = "Next context",
      },
    },
  },

  -- Better folds. Use zR/zM after enabling foldexpr below.
  {
    "kevinhwang91/nvim-ufo",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "kevinhwang91/promise-async" },
    init = function()
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
    },
    keys = {
      {
        "<F1>zo",
        function()
          require("ufo").openAllFolds()
        end,
        desc = "Open all folds",
      },
      {
        "<F1>zc",
        function()
          require("ufo").closeAllFolds()
        end,
        desc = "Close all folds",
      },
    },
  },

  -- Project-wide find/replace UI.
  -- Commands:
  --   :GrugFar                 open search/replace
  --   :GrugFarWithin           search/replace within visual selection range
  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    opts = {},
    keys = {
      { "<F1>g", "<cmd>GrugFar<cr>", desc = "Search and replace" },
      { "<F1>g", "<cmd>GrugFarWithin<cr>", mode = "x", desc = "Search and replace selection" },
    },
  },

  -- LSP location preview.
  -- Commands:
  --   :Glance definitions
  --   :Glance references
  --   :Glance type_definitions
  --   :Glance implementations
  --   :Glance resume
  {
    "dnlhc/glance.nvim",
    cmd = "Glance",
    opts = {
      border = { enable = true },
    },
    keys = {
      { "<F3>gd", "<cmd>Glance definitions<cr>", desc = "Glance definitions" },
      { "<F3>gr", "<cmd>Glance references<cr>", desc = "Glance references" },
      { "<F3>gy", "<cmd>Glance type_definitions<cr>", desc = "Glance type definitions" },
      { "<F3>gi", "<cmd>Glance implementations<cr>", desc = "Glance implementations" },
    },
  },

  -- Symbol/workspace navigator.
  -- Commands:
  --   :Namu symbols [function|class|method]
  --   :Namu workspace
  --   :Namu watchtower
  --   :Namu diagnostics [buffers|workspace]
  --   :Namu call in|out|both
  --   :Namu ctags [watchtower]
  {
    "bassamsdata/namu.nvim",
    cmd = "Namu",
    opts = {},
    keys = {
      { "<F4>ss", "<cmd>Namu symbols<cr>", desc = "Namu symbols" },
      { "<F4>sw", "<cmd>Namu workspace<cr>", desc = "Namu workspace symbols" },
    },
  },

  -- Highlight color codes like #ff00aa, rgb(...), hsl(...).
  -- Commands:
  --   :ColorizerAttachToBuffer
  --   :ColorizerDetachFromBuffer
  --   :ColorizerToggle
  {
    "norcalli/nvim-colorizer.lua",
    cmd = { "ColorizerAttachToBuffer", "ColorizerDetachFromBuffer", "ColorizerToggle" },
    opts = {},
    -- keys = {
    --   { "<leader>uc", "<cmd>ColorizerToggle<cr>", desc = "Toggle colorizer" },
    -- },
  },

  -- Treesitter split/join.
  -- Commands:
  --   :TSJToggle               split if one-line, join if multi-line
  --   :TSJSplit                split node under cursor
  --   :TSJJoin                 join node under cursor
  {
    "wansmer/treesj",
    cmd = { "TSJToggle", "TSJSplit", "TSJJoin" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      use_default_keymaps = false,
    },
    keys = {
      { "<F4>jt", "<cmd>TSJToggle<cr>", desc = "Toggle split/join" },
      { "<F4>jj", "<cmd>TSJJoin<cr>", desc = "Join node" },
      { "<F4>js", "<cmd>TSJSplit<cr>", desc = "Split node" },
    },
  },

  -- Git commit graph buffer.
  -- Lua API:
  --   require("gitgraph").draw({}, { all = true, max_count = 5000 })
  {
    "isakbm/gitgraph.nvim",
    cmd = "GitGraph",
    dependencies = { "sindrets/diffview.nvim" },
    opts = {},
    config = function(_, opts)
      require("gitgraph").setup(opts)
      vim.api.nvim_create_user_command("GitGraph", function()
        require("gitgraph").draw({}, { all = true, max_count = 5000 })
      end, {})
    end,
    keys = {
      { "<F4>g", "<cmd>GitGraph<cr>", desc = "Git graph" },
    },
  },
  {
    "dstein64/nvim-scrollview",
    event = "VeryLazy",
    opts = {
      excluded_filetypes = {
        "neo-tree",
        "snacks_dashboard",
        "lazy",
        "mason",
      },
    },
  },

  -- Improved * search from visual selection.
  -- Lua API:
  --   require("lasterisk").search()
  --   require("lasterisk").search({ is_whole = false })
  {
    "rapan931/lasterisk.nvim",
    event = "VeryLazy",
    keys = {
      {
        "*",
        function()
          require("lasterisk").search()
        end,
        mode = { "n", "x" },
        desc = "Search selected/current word",
      },
      {
        "g*",
        function()
          require("lasterisk").search({ is_whole = false })
        end,
        mode = { "n", "x" },
        desc = "Search partial selected/current word",
      },
    },
  },

  -- Center current buffer with side padding.
  -- Commands:
  --   :NoNeckPain
  --   :NoNeckPainResize 120
  --   :NoNeckPainWidthUp
  --   :NoNeckPainWidthDown
  --   :NoNeckPainScratchPad
  {
    "shortcuts/no-neck-pain.nvim",
    cmd = {
      "NoNeckPain",
      "NoNeckPainResize",
      "NoNeckPainToggleLeftSide",
      "NoNeckPainToggleRightSide",
      "NoNeckPainWidthUp",
      "NoNeckPainWidthDown",
      "NoNeckPainScratchPad",
    },
    main = "no-neck-pain",
    opts = {
      width = 120,
    },
    keys = {
      { "<F4>n", "<cmd>NoNeckPain<cr>", desc = "Toggle no-neck-pain" },
    },
  },

  -- Better quickfix window preview and filtering.
  -- Open quickfix normally, then use:
  --   p                 toggle preview
  --   zn/zN             create quickfix signs / clear signs
  --   zf                filter entries
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
      preview = {
        win_height = 12,
        win_vheight = 12,
        delay_syntax = 80,
        border = "rounded",
      },
      func_map = {
        split = "<C-s>",
        vsplit = "<C-v>",
      },
    },
  },

  -- Programmatic window resizing.
  -- Lua API:
  --   require("winresize").resize(0, 5, "left")
  --   require("winresize").resize(0, 5, "right")
  --   require("winresize").resize(0, 3, "up")
  --   require("winresize").resize(0, 3, "down")
  --{
  --"pogyomo/winresize.nvim",
  --event = "VeryLazy",
  ---- keys = {
  ----   { "<leader>w=", function() require("winresize").resize(0, 5, "right") end, desc = "Resize window wider" },
  ----   { "<leader>w-", function() require("winresize").resize(0, 5, "left") end, desc = "Resize window narrower" },
  ---- },
  --},

  -- Format markdown tables at cursor.
  -- Commands:
  --   :TableFormat
  {
    "tadashi-aikawa/table-format.nvim",
    cmd = "TableFormat",
    opts = {},
    keys = {
      { "<F4>t", "<cmd>TableFormat<cr>", desc = "Format table" },
    },
  },

  -- Task runner.
  -- Commands:
  --   :OverseerRun             select and run a task
  --   :OverseerToggle          toggle task list
  --   :OverseerOpen            open task list
  --   :OverseerClose           close task list
  --   :OverseerQuickAction     actions for current task
  {
    "stevearc/overseer.nvim",
    cmd = {
      "OverseerRun",
      "OverseerToggle",
      "OverseerOpen",
      "OverseerClose",
      "OverseerQuickAction",
      "OverseerTaskAction",
      "OverseerBuild",
      "OverseerLoadBundle",
      "OverseerSaveBundle",
      "OverseerDeleteBundle",
    },
    opts = {},
    keys = {
      { "<F4>or", "<cmd>OverseerRun<cr>", desc = "Run task" },
      { "<F4>oo", "<cmd>OverseerToggle<cr>", desc = "Toggle task list" },
    },
  },

  -- File manager.
  -- Commands:
  --   :Fyler
  --   :Fyler root_path=<path>
  --   :Fyler kind=<buffer_kind>
  {
    "FylerOrg/fyler.nvim",
    cmd = "Fyler",
    opts = {},
    keys = {
      { "<localleader>e", "<cmd>Fyler<cr>", desc = "Fyler" },
    },
  },

  -- Enhanced f/F/t/T motions using Leap.
  -- Upstream notes this plugin is deprecated; Leap's built-in leap-ft can replace it.
  -- setup() creates f/F/t/T mappings by design, so this spec is disabled until you decide.
  {
    "ggandor/flit.nvim",
    enabled = true,
    dependencies = {
      {
        url = "https://codeberg.org/andyg/leap.nvim.git",
        name = "leap.nvim",
      },
      "tpope/vim-repeat",
    },
    opts = {
      keys = { f = "f", F = "F", t = "t", T = "T" },
      labeled_modes = "v",
      clever_repeat = true,
      multiline = true,
    },
    -- To enable:
    -- enabled = true,
  },

  -- Seamless movement between Neovim and tmux panes.
  -- Commands:
  --   :TmuxNavigateLeft
  --   :TmuxNavigateDown
  --   :TmuxNavigateUp
  --   :TmuxNavigateRight
  --   :TmuxNavigatePrevious
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    keys = {
      { "<F5>th", "<cmd>TmuxNavigateLeft<cr>", desc = "Tmux left" },
      { "<F5>tj", "<cmd>TmuxNavigateDown<cr>", desc = "Tmux down" },
      { "<F5>tk", "<cmd>TmuxNavigateUp<cr>", desc = "Tmux up" },
      { "<F5>tl", "<cmd>TmuxNavigateRight<cr>", desc = "Tmux right" },
    },
  },
}
