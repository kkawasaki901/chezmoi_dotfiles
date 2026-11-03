local org_dir = vim.fn.stdpath("data") .. "/org"

local function edit_org_file(name)
  return function()
    vim.api.nvim_cmd({ cmd = "edit", args = { org_dir .. "/" .. name } }, {})
  end
end

return {
  {
    "xheisenbugx/org.nvim",
    main = "org",
    lazy = false,
    opts = {
      org_directory = org_dir,
      agenda_files = { org_dir .. "/**/*.org" },
      default_notes_file = org_dir .. "/inbox.org",
      todo_keywords = { "TODO(t) NEXT(n) WAITING(w@/!) | DONE(d!) CANCELLED(c@)" },
      log_done = "time",
      log_into_drawer = "LOGBOOK",
      startup_folded = "overview",
      deadline_warning_days = 14,
      agenda = { span = "week", start_on_weekday = 1, window = "current" },
      capture = {
        window = "float",
        templates = {
          t = { description = "Task", template = "* TODO %?\n  %U\n", target = org_dir .. "/inbox.org" },
          n = { description = "Note", template = "* %?\n  %U\n", target = org_dir .. "/notes.org" },
          j = { description = "Journal", template = "* %<%H:%M> %?\n", target = org_dir .. "/journal.org", datetree = true },
        },
      },
      notifications = { enabled = false },
      use_speed_commands = true,
      ui = { indent_mode = true, hide_emphasis_markers = false },
      mappings = {
        prefix = "<leader>o",
        org = { toggle_checkbox = "<C-Space>", open_at_point = { "<CR>", "gx" } },
        agenda = { goto_date = "gd" },
      },
    },
    config = function(_, opts)
      vim.fn.mkdir(org_dir, "p")
      local starter_files = {
        ["inbox.org"] = "#+title: Inbox\n\n* Inbox\n",
        ["notes.org"] = "#+title: Notes\n\n* Notes\n",
        ["journal.org"] = "#+title: Journal\n",
        ["index.org"] = "#+title: Org Home\n\n* Areas\n** Inbox\n[[file:inbox.org]]\n** Notes\n[[file:notes.org]]\n** Journal\n[[file:journal.org]]\n",
      }
      for name, contents in pairs(starter_files) do
        local path = org_dir .. "/" .. name
        if vim.fn.filereadable(path) == 0 then
          vim.fn.writefile(vim.split(contents, "\n", { plain = true }), path)
        end
      end

      require("org").setup(opts)
      local map = vim.keymap.set
      map("n", "<leader>oi", edit_org_file("inbox.org"), { desc = "Org: open inbox" })
      map("n", "<leader>on", edit_org_file("notes.org"), { desc = "Org: open notes" })
      map("n", "<leader>oj", edit_org_file("journal.org"), { desc = "Org: open journal" })
      map("n", "<leader>oI", edit_org_file("index.org"), { desc = "Org: open index" })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "org",
        callback = function(event)
          vim.opt_local.conceallevel = 2
          vim.opt_local.wrap = false
          vim.opt_local.linebreak = true
          vim.keymap.set("n", "<leader>ww", "<cmd>write<cr>", { buffer = event.buf, desc = "Org: save" })
        end,
      })
    end,
  },
}
