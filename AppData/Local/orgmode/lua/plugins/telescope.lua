return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    -- defaults: 全picker共通設定。指定可能な固定項目:
    -- prompt_prefix、selection_caret、entry_prefix、multi_icon、initial_mode、
    -- selection_strategy、sorting_strategy、scroll_strategy、layout_strategy、
    -- layout_config、cycle_layout_list、winblend、wrap_results、preview、
    -- border、borderchars、color_devicons、set_env、file_ignore_patterns、
    -- path_display、get_status_text、dynamic_preview_title、results_title、
    -- prompt_title、preview_title、vimgrep_arguments、buffer_previewer_maker、
    -- mappings、attach_mappings、history、cache_picker、preview、
    -- default_mappings、default_selection_index、on_input_filter_cb。
    -- pickers: builtin picker名をkeyにし、上記共通項目とpicker固有項目を上書きする。
    -- extensions: extension名をkeyにした設定。外部extensionが任意キーを定義する。
    -- fzf_sorter / generic_sorter / file_sorter: sorterを返す関数。
    -- file_previewer / grep_previewer / qflist_previewer: previewerを返す関数。
    -- defaults = {},
    -- pickers = {},
    extensions = { orgmode = {} },
  },
  config = function(_, opts)
    require("telescope").setup(opts)
    require("telescope").load_extension("orgmode")
  end,
}
