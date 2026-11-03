return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "nvim-orgmode/orgmode",
  },
  config = function()
    local cmp = require("cmp")
    cmp.setup({
      -- enabled: 補完を有効にするbooleanまたはcontextを判定する関数。
      -- performance: debounce、throttle、fetching_timeout、filtering_context_budget、
      --   confirm_resolve_timeout、async_budget、max_view_entries。
      -- preselect: cmp.PreselectMode.Item|None。
      -- mapping: insert/cmdline modeのkeyとcmp.mapping関数の対応表。
      -- snippet.expand: snippet本文を展開する関数。
      -- completion: autocomplete、completeopt、keyword_pattern、keyword_length。
      -- matching: disallow_fuzzy_matching、disallow_fullfuzzy_matching、
      --   disallow_partial_fuzzy_matching、disallow_partial_matching、
      --   disallow_prefix_unmatching、disallow_symbol_nonprefix_matching。
      -- sorting: priority_weightとcomparators配列。
      -- formatting: fields、expandable_indicator、format関数。
      -- window: completion/documentation windowのborder、winhighlight、winblend、
      --   scrollbar、scrolloff、col_offset、side_padding。
      -- confirmation: default_behavior、get_commit_characters。
      -- experimental: ghost_text、native_menu。
      -- sources: source名、group_index、priority、keyword_length、max_item_count、
      --   trigger_characters、entry_filter、option。option配下はsourceごとの任意設定。
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }),
      sources = cmp.config.sources({
        { name = "orgmode" },
        { name = "buffer" },
        { name = "path" },
      }),
    })
  end,
}
