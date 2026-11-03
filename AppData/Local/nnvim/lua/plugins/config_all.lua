return {
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ vim-code-dark                                           │
    -- │ カラースキーム                                          │
    -- ╰─────────────────────────────────────────────────────────╯
    "tomasiser/vim-code-dark",
    lazy = false, -- 起動時に読み込む
    priority = 1000, -- colorschemeは最優先で読み込む
    config = function()
      -- vim.cmd.colorscheme("codedark")
    end,
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ eldritch                                                │
    -- │ カラースキーム                                          │
    -- ╰─────────────────────────────────────────────────────────╯
    "eldritch-theme/eldritch.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      -- vim.cmd.colorscheme("eldritch")
    end,
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │  oil                                                    │
    -- │  ファイラー                                             │
    -- ╰─────────────────────────────────────────────────────────╯
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ toggleterm                                              │
    -- │ ターミナル                                              │
    -- ╰─────────────────────────────────────────────────────────╯
    -- amongst your other plugins
    { "akinsho/toggleterm.nvim", version = "*", config = true },
    -- or
    -- {'akinsho/toggleterm.nvim', version = "*", opts = {--[[ things you want to change go here]]}}
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │  comment-box                                            │
    -- │  コメントボックス(これ)                                 │
    -- ╰─────────────────────────────────────────────────────────╯
    "LudoPinelli/comment-box.nvim",
    config = function()
      vim.keymap.set({ "n", "v" }, "<F2>cc", "<cmd>CBllbox<CR>", { desc = "comment box" })
      vim.keymap.set({ "n", "v" }, "<F2>cd", "<cmd>CBd<CR>", { desc = "comment box remove" })
    end,
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ git-messenger                                           │
    -- │ コミットメッセージ表示                                  │
    -- ╰─────────────────────────────────────────────────────────╯
    "rhysd/git-messenger.vim",
    config = function()
      vim.keymap.set("n", "<F2>g", "<cmd>GitMessenger<CR>", { desc = "git-messenger" })
    end,
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ autoread                                                │
    -- │ 変わったら自動で再読み込み                              │
    -- ╰─────────────────────────────────────────────────────────╯
    "djoshea/vim-autoread",
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ dropbar                                                 │
    -- │ 上に出るやつ                                            │
    -- ╰─────────────────────────────────────────────────────────╯
    "Bekaboo/dropbar.nvim",
    -- optional, but required for fuzzy finder support
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    config = function()
      local dropbar_api = require("dropbar.api")
      vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
      vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
      vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
    end,
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ scrollbar                                               │
    -- │ スクロールバー                                          │
    -- ╰─────────────────────────────────────────────────────────╯
    "petertriho/nvim-scrollbar",
    config = function()
      require("scrollbar").setup()
    end,
  },

  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ Zenmode                                                 │
    -- ╰─────────────────────────────────────────────────────────╯
    "folke/zen-mode.nvim",
    config = function()
      vim.keymap.set("n", "<localleader>z", "<cmd>ZenMode<CR>", { desc = "zenmnode" })
    end,
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ ufo                                                     │
    -- │ foldとunfold                                            │
    -- ╰─────────────────────────────────────────────────────────╯
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    event = "BufReadPost",
    opts = {
      provider_selector = function(bufnr, filetype, buftype)
        -- 基本は treesitter 優先、無ければ indent
        return { "treesitter", "indent" }
      end,
    },
    config = function(_, opts)
      -- fold 基本設定
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      require("ufo").setup(opts)

      -- キーマップ
      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
    end,
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ glance                                                  │
    -- │ 定義をチラ見する                                        │
    -- ╰─────────────────────────────────────────────────────────╯
    "dnlhc/glance.nvim",
    cmd = "Glance",
    config = function()
      vim.keymap.set("n", "<localleader>Gd", "<CMD>Glance definitions<CR>")
      vim.keymap.set("n", "<localleader>Gr", "<CMD>Glance references<CR>")
      vim.keymap.set("n", "<localleader>Gy", "<CMD>Glance type_definitions<CR>")
      vim.keymap.set("n", "<localleader>Gm", "<CMD>Glance implementations<CR>")
    end,
  },

  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ markview                                                │
    -- │ マークダウンを見やすくする                              │
    -- ╰─────────────────────────────────────────────────────────╯
    "OXY2DEV/markview.nvim",
    lazy = false,
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ camelCaseMotion                                         │
    -- │ キャメルケースを認識するようになる                      │
    -- ╰─────────────────────────────────────────────────────────╯
    "Craftidore/camelCaseMotion.nvim",
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ scratch                                                 │
    -- │ scratchバッファを使えるようにする                       │
    -- ╰─────────────────────────────────────────────────────────╯
    "LintaoAmons/scratch.nvim",
    event = "VeryLazy",
    dependencies = {
      { "ibhagwan/fzf-lua" }, --optional: if you want to use fzf-lua to pick scratch file. Recommanded, since it will order the files by modification datetime desc. (require rg)
      { "nvim-telescope/telescope.nvim" }, -- optional: if you want to pick scratch file by telescope
      { "folke/snacks.nvim" }, -- optional: if you want to pick scratch file by snacks picker
      { "stevearc/dressing.nvim" }, -- optional: to have the same UI shown in the GIF
    },
    config = function()
      vim.keymap.set("n", "<M-C-n>", "<cmd>Scratch<cr>")
      vim.keymap.set("n", "<M-C-o>", "<cmd>ScratchOpen<cr>")
      require("scratch").setup({
        subdir = true,
        scratch_file_dir = vim.fn.stdpath("cache") .. "/scratch.nvim", -- where your scratch files will be put
        window_cmd = "rightbelow vsplit", -- 'vsplit' | 'split' | 'edit' | 'tabedit' | 'rightbelow vsplit'
        use_telescope = true,
        -- fzf-lua is recommanded, since it will order the files by modification datetime desc. (require rg)
        -- snacks.nvim is also supported as an alternative picker (require rg)
        file_picker = "fzflua", -- "fzflua" | "telescope" | "snacks" | nil
        filetypes = { "lua", "js", "sh", "ts" }, -- you can simply put filetype here
        filetype_details = { -- or, you can have more control here
          json = {}, -- empty table is fine
          ["project-name.md"] = {
            subdir = "project-name", -- group scratch files under specific sub folder
          },
          ["yaml"] = {},
          go = {
            filename = "main", -- the filename of the scratch file in the new directory
            content = { "package main", "", "func main() {", "  ", "}" },
            cursor = {
              location = { 4, 2 },
              insert_mode = true,
            },
          },
        },
        localKeys = {
          {
            filenameContains = { "sh" },
            LocalKeys = {
              {
                cmd = "<CMD>RunShellCurrentLine<CR>",
                key = "<C-r>",
                modes = { "n", "i", "v" },
              },
            },
          },
        },
        hooks = {
          {
            callback = function()
              vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello", "world" })
            end,
          },
        },
      })
    end,
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ yazi                                                    │
    -- │ yaziを開く                                              │
    -- ╰─────────────────────────────────────────────────────────╯
    ---@type LazySpec
    "mikavilpas/yazi.nvim",
    version = "*", -- use the latest stable version
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        "<localleader>-",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<localleader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        "<c-up>",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
    ---@type YaziConfig | {}
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
      },
    },
    -- 👇 if you use `open_for_directories=true`, this is recommended
    init = function()
      -- mark netrw as loaded so it's not loaded at all.
      --
      -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
      vim.g.loaded_netrwPlugin = 1
    end,
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ snacks                                                  │
    -- │ 色々入っているやつ                                      │
    -- ╰─────────────────────────────────────────────────────────╯
    "snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          pick = function(cmd, opts)
            return LazyVim.pick(cmd, opts)()
          end,
          header = [[
          ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
          ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
          ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
          ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
          ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
          ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
                                                      
            ]],
          -- stylua: ignore
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = " ", key = "S", desc = "Select Session", action = "<cmd>SessionManager load_session<CR>" },
            { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            { icon = " ", key = "y", desc = "Yazi", action = ":Yazi" },
          },
        },
      },
    },
  },

  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ neo-tree                                                │
    -- │ ファイラー                                              │
    -- ╰─────────────────────────────────────────────────────────╯
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },

    opts = {
      window = {
        position = "right",
      },
    },
    lazy = false, -- neo-tree will lazily load itself
  }, -- nvim v0.8.0
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ lazygit                                                 │
    -- ╰─────────────────────────────────────────────────────────╯
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<localleader>g", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ SessionManager                                          │
    -- │ セッションの管理                                        │
    -- ╰─────────────────────────────────────────────────────────╯

    "Shatur/neovim-session-manager",
    event = "User BaseDefered",
    cmd = "SessionManager",
    opts = function()
      local config = require("session_manager.config")
      return {
        autoload_mode = config.AutoloadMode.Disabled,
        autosave_last_session = false,
        autosave_only_in_session = false,
      }
    end,
    config = function(_, opts)
      local session_manager = require("session_manager")
      session_manager.setup(opts)

      -- Auto save session
      -- BUG: This feature will auto-close anything nofile before saving.
      --      This include neotree, aerial, mergetool, among others.
      --      Consider commenting the next block if this is important for you.
      --
      --      This won't be necessary once neovim fixes:
      --      https://github.com/neovim/neovim/issues/12242
      -- vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
      --   callback = function ()
      --     session_manager.save_current_session()
      --   end
      -- })
    end,
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ marker-group                                            │
    -- │ マーキングする                                          │
    -- ╰─────────────────────────────────────────────────────────╯
    "jameswolensky/marker-groups.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required
      "ibhagwan/fzf-lua", -- Optional: fzf-lua picker
      "folke/snacks.nvim", -- Optional: Snacks picker
      "nvim-telescope/telescope.nvim", -- Optional: Telescope picker
      -- mini.pick is part of mini.nvim; this plugin vendors mini.nvim for tests,
      -- but you can also install mini.nvim explicitly to use mini.pick system-wide
      -- "nvim-mini/mini.nvim",
    },
    config = function()
      require("marker-groups").setup({
        -- Default picker is 'vim' (built-in vim.ui)
        -- Accepted values: 'vim' | 'snacks' | 'fzf-lua' | 'mini.pick' | 'telescope'
        picker = "telescope",
      })
    end,
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ telescope-file-browser                                  │
    -- ╰─────────────────────────────────────────────────────────╯
    "nvim-telescope/telescope-file-browser.nvim",
  },
  {
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ project                                                 │
    -- ╰─────────────────────────────────────────────────────────╯
    "ahmedkhalf/project.nvim",
  },
  {
    "hrsh7th/nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            -- You could replace select_next_item() with confirm({ select = true }) to get VS Code autocompletion behavior
            cmp.select_next_item()
          elseif vim.snippet.active({ direction = 1 }) then
            vim.schedule(function()
              vim.snippet.jump(1)
            end)
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif vim.snippet.active({ direction = -1 }) then
            vim.schedule(function()
              vim.snippet.jump(-1)
            end)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        -- Resolve the LazyVim and Snacks globals so lua_ls stops flagging them as undefined
        { path = "lazyvim", words = { "LazyVim" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },
  { -- optional cmp completion source for require statements and module annotations
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end,
  },
  { -- optional blink completion source for require statements and module annotations
    "saghen/blink.cmp",
    dependencies = { "saghen/blink.lib" },
    opts = {
      sources = {
        -- add lazydev to your completion providers
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
        },
      },
    },
  },
  {
    "kawasaki-neovim/project-pane.nvim",
    config = function()
      require("project-pane").setup({
        projects = {
          { name = "nvim config", path = vim.fn.stdpath("config") },
          { name = "codex", path = "~/codex" },
        },
        width = 25,
        side = "right",
        close_on_select = false,
        persist_file = vim.fn.stdpath("data") .. "/project-pane/projects.json",
      })
    end,
  },
  {
    "airkewld/claude.nvim",

    config = function()
      require("claude").setup({
        cli_args = {
          "--dangerously-skip-permissions",
        },
      })
    end,
  },
}
