return {
  "hamidi-dev/org-super-agenda.nvim",
  dependencies = { "nvim-orgmode/orgmode" },
  opts = {
    -- keymaps: quit、help、toggle_other、toggle_group、toggle_all_groups、
    --   toggle_tag、cycle_sort、reverse_sort、reschedule、set_deadline、
    --   set_todo、set_priority、refile、preview、open、open_split、open_vsplit、
    --   refresh、fold_all、unfold_all、toggle_duplicates、cycle_view、set_state、
    --   bulk_mark、bulk_unmark_all、bulk_reselect、bulk_action、open_view、goto、
    --   fold_or_action、edit。
    -- todo_states: {name,keymap,color,strike_through,fields} の配列。
    -- groups: {name,matcher,sort={by,order}} の配列。
    -- window: width、height、border、title、title_pos、margin_left、margin_right、
    --   fullscreen_border。
    -- upcoming_days = 10, hide_empty_groups = true, keep_order = false,
    -- allow_duplicates = false, group_format = "* %s", other_group_name = "Other",
    -- show_other_group = false, show_tags = true, show_filename = true,
    -- heading_max_length = 70, persist_hidden = false,
    -- fold_item_action = "preview", view_mode = "classic",
    -- classic = { heading_order = {}, short_date_labels = false, inline_dates = true },
    -- compact = { filename_min_width = 10, label_min_width = 12 },
    -- group_sort = { by = "date_nearest", order = "asc" },
    -- popup_mode = { enabled = false, hide_command = "tmux detach-client" },
    -- debug = false, custom_views = {},
  },
}
