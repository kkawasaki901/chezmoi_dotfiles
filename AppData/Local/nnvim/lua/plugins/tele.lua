-- Telescope本体と各拡張は別の設定で導入済みであることを前提とする。
-- このファイルではインストール指定を追加せず、既存specへ設定だけをマージする。

local function file_browser_action(name)
  return function(prompt_bufnr)
    require("telescope._extensions.file_browser.actions")[name](prompt_bufnr)
  end
end

return {
  {
    "nvim-telescope/telescope.nvim",
    optional = true,

    opts = function(_, opts)
      local actions = require("telescope.actions")

      return vim.tbl_deep_extend("force", opts, {
        defaults = {
          prompt_prefix = "   ",
          selection_caret = " ",
          path_display = { "truncate" },
          mappings = {
            i = {
              ["<Esc>"] = actions.close,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<C-/>"] = actions.which_key,
            },
            n = {
              q = actions.close,
              j = actions.move_selection_next,
              k = actions.move_selection_previous,
              ["?"] = actions.which_key,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            no_ignore = false,
          },
          live_grep = {
            additional_args = function()
              return { "--hidden", "--glob", "!.git/" }
            end,
          },
          buffers = {
            sort_mru = true,
            ignore_current_buffer = true,
          },
        },
        extensions = {
          file_browser = {
            theme = "ivy",
            hijack_netrw = true,
            hidden = true,
            grouped = true,
            respect_gitignore = false,
            use_fd = true,
            git_status = true,
            mappings = {
              i = {
                ["<C-n>"] = file_browser_action("create"),
                ["<C-r>"] = file_browser_action("rename"),
                ["<C-d>"] = file_browser_action("remove"),
                ["<C-h>"] = file_browser_action("toggle_hidden"),
                ["<C-p>"] = file_browser_action("goto_parent_dir"),
                ["<C-w>"] = file_browser_action("goto_cwd"),
              },
              n = {
                n = file_browser_action("create"),
                r = file_browser_action("rename"),
                d = file_browser_action("remove"),
                h = file_browser_action("toggle_hidden"),
                ["-"] = file_browser_action("goto_parent_dir"),
                w = file_browser_action("goto_cwd"),
              },
            },
          },
          projects = {
            on_project_selected = function(prompt_bufnr)
              require("telescope._extensions.project.actions").find_project_files(prompt_bufnr, false)
            end,
          },
        },
      })
    end,

    init = function()
      LazyVim.on_load("telescope.nvim", function()
        -- fzf/projectsは既存spec側で読み込まれる。ここではfile_browserだけ補う。
        pcall(require("telescope").load_extension, "file_browser")
      end)
    end,

    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Find word under cursor" },
      {
        "<leader>fc",
        function()
          require("telescope.builtin").find_files({
            cwd = vim.fn.stdpath("config"),
            hidden = true,
          })
        end,
        desc = "Find nvim config files",
      },
      { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Projects" },
      {
        "<localleader>f",
        function()
          require("telescope").extensions.file_browser.file_browser({
            path = vim.uv.cwd(),
            cwd = vim.uv.cwd(),
            respect_gitignore = false,
            hidden = true,
            grouped = true,
            previewer = false,
            initial_mode = "normal",
            layout_config = { height = 40 },
          })
        end,
        desc = "File browser",
      },
      {
        "<localleader>F",
        function()
          require("telescope").extensions.file_browser.file_browser({
            path = "%:p:h",
            select_buffer = true,
            respect_gitignore = false,
            hidden = true,
            grouped = true,
            previewer = false,
            initial_mode = "normal",
          })
        end,
        desc = "File browser current file dir",
      },
    },
  },

  {
    "ahmedkhalf/project.nvim",
    optional = true,
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        manual_mode = false,
        detection_methods = { "lsp", "pattern" },
        patterns = {
          ".git",
          "package.json",
          "Cargo.toml",
          "go.mod",
          "pyproject.toml",
          "Makefile",
          "README.md",
        },
        show_hidden = true,
        silent_chdir = true,
        scope_chdir = "global",
      })
    end,
  },
}
