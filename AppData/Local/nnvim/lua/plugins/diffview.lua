-- Diffview.nvim
-- Gitの差分確認、ファイル履歴、マージコンフリクト解消を1つのタブで扱う。
-- Neogitやgitgraph.nvimから依存として参照されていても、lazy.nvimが同じspecをマージする。

return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
      "DiffviewLog",
    },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      diff_binaries = false, -- バイナリファイルのdiffは表示しない
      enhanced_diff_hl = true, -- 変更箇所のハイライトを見やすくする
      git_cmd = { "git" },
      use_icons = true,
      show_help_hints = true,
      watch_index = true, -- indexの変更をDiffview側へ反映する
      view = {
        default = {
          layout = "diff2_horizontal",
          disable_diagnostics = false,
          winbar_info = true,
        },
        merge_tool = {
          layout = "diff3_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
        file_history = {
          layout = "diff2_horizontal",
          disable_diagnostics = false,
          winbar_info = true,
        },
      },
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 35,
        },
      },
      file_history_panel = {
        win_config = {
          position = "bottom",
          height = 16,
        },
      },
    },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview file history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview repo history" },
      { "<leader>gf", "<cmd>DiffviewToggleFiles<cr>", desc = "Diffview toggle files" },
      { "<leader>gF", "<cmd>DiffviewFocusFiles<cr>", desc = "Diffview focus files" },
      { "<leader>gr", "<cmd>DiffviewRefresh<cr>", desc = "Diffview refresh" },
    },
  },
}
