return {
  "nvim-orgmode/telescope-orgmode.nvim",
  dependencies = { "nvim-orgmode/orgmode", "nvim-telescope/telescope.nvim" },
  -- setup()はなく、Telescope extensionとして設定する。
  -- telescope.luaのextensions.orgmodeにpicker共通オプションを指定可能:
  -- prompt_title、results_title、preview_title、layout_strategy、layout_config、
  -- sorting_strategy、selection_strategy、scroll_strategy、entry_prefix、
  -- selection_caret、multi_icon、initial_mode、border、borderchars、
  -- winblend、mappings、attach_mappings、file_ignore_patterns、path_display。
}
