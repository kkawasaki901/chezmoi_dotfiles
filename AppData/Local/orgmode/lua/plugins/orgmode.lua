return {
  "nvim-orgmode/orgmode",
  event = "VeryLazy",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    local org_files_dir = vim.fn.stdpath("data") .. "/orgfiles"
    require("orgmode").setup({
      -- Files/TODO:
      org_agenda_files = org_files_dir .. "/**/*",
      org_default_notes_file = org_files_dir .. "/refile.org",
      org_todo_keywords = { "TODO(t)", "PROGRESS(p)", "|", "DONE(d)" },
      -- org_todo_repeat_to_state = nil, -- repeat時に戻すTODO状態。
      -- org_todo_keyword_faces = {},    -- keyword別highlight指定。
      -- org_deadline_warning_days = 14,
      -- Agenda:
      -- org_agenda_min_height = 16, org_agenda_span = "week",
      -- org_agenda_start_on_weekday = 1, org_agenda_start_day = nil,
      -- calendar_week_start_day = 1,
      -- calendar = { round_min_with_hours = true, min_big_step = 15 },
      -- org_capture_templates = { t = { description = "Task", template = "* TODO %?\n  %u" } },
      -- org_agenda_skip_scheduled_if_done = false,
      -- org_agenda_skip_deadline_if_done = false,
      -- org_agenda_text_search_extra_files = {}, org_agenda_custom_commands = {},
      -- org_agenda_hide_empty_blocks = false, org_agenda_block_separator = "-",
      -- org_agenda_sorting_strategy = { agenda = {"time-up","priority-down","category-keep"},
      --   todo = {"priority-down","category-keep"}, tags = {"priority-down","category-keep"} },
      -- org_agenda_remove_tags = false,
      -- org_agenda_time_grid = { type = {"daily","today","require-timed"},
      --   times = {800,1000,1200,1400,1600,1800,2000},
      --   time_separator = "┄┄┄┄┄", time_label = "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄" },
      -- org_agenda_current_time_string = "<- now -----------------------------------------------",
      -- org_agenda_use_time_grid = true, org_agenda_show_future_repeats = true,
      -- Priority/archive/tags:
      -- org_priority_highest = "A", org_priority_default = "B", org_priority_lowest = "C",
      -- org_priority_start_cycle_with_default = true, org_archive_location = "%s_archive::",
      -- org_tags_column = -80, org_use_tag_inheritance = true,
      -- org_tags_exclude_from_inheritance = {}, org_use_property_inheritance = false,
      -- Display/logging:
      org_startup_folded = "overview",
      org_startup_indented = true,
      -- org_hide_leading_stars = false, org_hide_emphasis_markers = false, org_ellipsis = "...",
      -- org_log_done = "time", org_log_repeat = "time", org_log_into_drawer = nil,
      -- org_highlight_latex_and_related = nil, org_custom_exports = {},
      -- Indent/edit/source:
      -- org_adapt_indentation = true,
      -- org_indent_mode_turns_off_org_adapt_indentation = true,
      -- org_indent_mode_turns_on_hiding_stars = true,
      -- org_time_stamp_rounding_minutes = 5, org_cycle_separator_lines = 2,
      -- org_blank_before_new_entry = { heading = true, plain_list_item = false },
      -- org_src_window_setup = "top 16new", org_edit_src_content_indentation = 0,
      -- org_edit_src_filetype_map = {},
      -- ID/Babel:
      -- org_id_uuid_program = "uuidgen", org_id_ts_format = "%Y%m%d%H%M%S",
      -- org_id_method = "uuid", org_id_prefix = nil, org_id_link_to_org_use_id = false,
      -- org_babel_default_header_args = { [":tangle"] = "no", [":noweb"] = "no" },
      -- Window/notification/link:
      -- win_split_mode = "horizontal", win_border = "single",
      -- notifications = { enabled = false, cron_enabled = true,
      --   repeater_reminder_time = false, deadline_warning_reminder_time = 0,
      --   reminder_time = 10, deadline_reminder = true, scheduled_reminder = true },
      -- hyperlinks = { sources = {} }, -- custom hyperlink source定義。
      -- mappings = {
      --   disable_all = false, org_return_uses_meta_return = false, prefix = "<Leader>o",
      --   global = {}, agenda = {}, capture = {}, note = {}, org = {}, edit_src = {},
      --   text_objects = {},
      -- }, -- 各tableはorgmode action名 -> key。falseで個別無効化。
      -- emacs_config = { executable_path = "emacs", config_path = nil },
      ui = {
        -- folds = { colored = true },
        menu = {
          handler = function(data)
            require("org-modern.menu"):new():open(data)
          end,
        },
        -- input = { use_vim_ui = false },
        -- agenda = { preview_window = { wrap = false } },
      },
    })
  end,
}
