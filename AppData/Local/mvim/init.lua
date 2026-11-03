-- mvim: Markdown-focused Neovim configuration for Windows
-- Plugin management: lazy.nvim

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local startup_directory = vim.fn.expand("~/work-notes")
local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local config_file = vim.env.MYVIMRC or (vim.fn.stdpath("config") .. "/init.lua")
local config_directory = vim.fn.fnamemodify(config_file, ":p:h")

if not (vim.uv or vim.loop).fs_stat(lazy_path) then
  local clone_output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazy_path,
  })
  if vim.v.shell_error ~= 0 then
    error("Failed to install lazy.nvim:\n" .. clone_output)
  end
end

vim.opt.runtimepath:prepend(lazy_path)

require("lazy").setup({
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    opts = {},
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")
      treesitter.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })
      treesitter.install({
        "markdown",
        "markdown_inline",
        "html",
        "yaml",
        "lua",
        "vim",
        "vimdoc",
      })
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      hijack_netrw = false,
      hijack_directories = { enable = false },
      filesystem_watchers = { enable = false },
      git = { enable = false },
      view = {
        width = 34,
        side = "left",
        preserve_window_proportions = true,
      },
      renderer = {
        group_empty = true,
        highlight_git = false,
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = false,
          },
        },
      },
      filters = {
        dotfiles = false,
      },
      update_focused_file = {
        enable = false,
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      enabled = true,
      render_modes = { "n", "c", "t" },
      preset = "obsidian",
      heading = {
        sign = false,
      },
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      completions = {
        lsp = { enabled = false },
      },
    },
    keys = {
      {
        "<leader>mr",
        "<cmd>RenderMarkdown toggle<cr>",
        ft = "markdown",
        desc = "Toggle rendered Markdown",
      },
      {
        "<leader>ms",
        "<cmd>RenderMarkdown preview<cr>",
        ft = "markdown",
        desc = "Markdown side preview",
      },
    },
  },
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown",
    opts = {
      mappings = {
        inline_surround_toggle = "gs",
        inline_surround_toggle_line = "gss",
        inline_surround_delete = "ds",
        inline_surround_change = "cs",
        link_add = "gl",
        link_follow = "gx",
        go_curr_heading = "]c",
        go_parent_heading = "]p",
        go_next_heading = "]]",
        go_prev_heading = "[[",
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = {
      "MarkdownPreviewToggle",
      "MarkdownPreview",
      "MarkdownPreviewStop",
    },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_theme = "dark"
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {},
      }
    end,
    keys = {
      {
        "<leader>mp",
        "<cmd>MarkdownPreviewToggle<cr>",
        ft = "markdown",
        desc = "Toggle browser Markdown preview",
      },
    },
  },
}, {
  lockfile = config_directory .. "/lazy-lock.json",
  install = {
    missing = true,
    colorscheme = { "habamax" },
  },
  checker = {
    enabled = false,
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
  ui = {
    border = "rounded",
  },
})

-- Leaders must be defined before any mappings that use <leader>/<localleader>.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.grepprg = "rg --vimgrep --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard:append("unnamedplus")
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup" }

if vim.fn.isdirectory(startup_directory) == 1 then
  vim.api.nvim_set_current_dir(startup_directory)
else
  vim.schedule(function()
    vim.notify(
      "Startup directory does not exist: " .. startup_directory,
      vim.log.levels.WARN
    )
  end)
end

vim.keymap.set("n", "<leader>e", "<Cmd>NvimTreeToggle<CR>", {
  desc = "Toggle nvim-tree",
  silent = true,
})

-- ntelescope: external Go TUI search without an additional Neovim plugin.
local ntelescope_executable =
  vim.fn.expand("~/go/bin/ntelescope.exe")

local ntelescope_actions = {
  {
    label = "Files",
    mode = "files",
  },
  {
    label = "Live grep",
    mode = "grep",
  },
  {
    label = "Current buffer grep",
    mode = "buffer-grep",
  },
}

local function launch_ntelescope(mode)
  if vim.fn.executable(ntelescope_executable) ~= 1 then
    vim.notify(
      "ntelescope.exe was not found: " .. ntelescope_executable,
      vim.log.levels.ERROR
    )
    return
  end

  local target_win = vim.api.nvim_get_current_win()
  local target_buf = vim.api.nvim_get_current_buf()
  local cwd = vim.fn.getcwd()
  local command = {
    ntelescope_executable,
    mode,
    "--cwd",
    cwd,
    "--target-win",
    tostring(target_win),
    "--target-buf",
    tostring(target_buf),
  }

  vim.cmd("botright 18new")
  local terminal_win = vim.api.nvim_get_current_win()
  local terminal_buf = vim.api.nvim_get_current_buf()
  vim.bo[terminal_buf].bufhidden = "wipe"

  local job = vim.fn.jobstart(command, {
    term = true,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        if exit_code == 0 and vim.api.nvim_win_is_valid(terminal_win) then
          vim.api.nvim_win_close(terminal_win, true)
        elseif exit_code ~= 0 then
          vim.notify(
            "ntelescope exited with code "
              .. exit_code
              .. "; the terminal was kept open to show the error",
            vim.log.levels.ERROR
          )
        end
      end)
    end,
  })

  if job <= 0 then
    if vim.api.nvim_win_is_valid(terminal_win) then
      vim.api.nvim_win_close(terminal_win, true)
    end
    vim.notify("ntelescope could not be started", vim.log.levels.ERROR)
    return
  end

  vim.cmd("startinsert")
end

local function choose_ntelescope()
  vim.ui.select(ntelescope_actions, {
    prompt = "Find:",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if choice then
      launch_ntelescope(choice.mode)
    end
  end)
end

vim.keymap.set("n", "<leader>f", choose_ntelescope, {
  desc = "Choose ntelescope search",
  silent = true,
})

-- Move between splits without typing the <C-w> prefix.
vim.keymap.set("n", "<C-h>", "<C-w>h", {
  desc = "Move to left pane",
  silent = true,
})
vim.keymap.set("n", "<C-j>", "<C-w>j", {
  desc = "Move to lower pane",
  silent = true,
})
vim.keymap.set("n", "<C-k>", "<C-w>k", {
  desc = "Move to upper pane",
  silent = true,
})
vim.keymap.set("n", "<C-l>", "<C-w>l", {
  desc = "Move to right pane",
  silent = true,
})

local function save_current_buffer()
  local ok, error_message = pcall(vim.cmd, "silent update")
  if not ok then
    vim.notify(
      "Save failed: " .. tostring(error_message),
      vim.log.levels.ERROR
    )
  end
end

vim.keymap.set({ "n", "i", "v", "o", "c", "t" }, "<C-s>", save_current_buffer, {
  desc = "Save current buffer",
  silent = true,
})

local session_directory = vim.fn.stdpath("data") .. "/sessions"
vim.fn.mkdir(session_directory, "p")

local function session_items()
  local items = {}
  local paths = vim.fn.globpath(session_directory, "*.vim", false, true)

  for _, path in ipairs(paths) do
    table.insert(items, {
      name = vim.fn.fnamemodify(path, ":t:r"),
      path = path,
      modified = vim.fn.getftime(path),
    })
  end

  table.sort(items, function(left, right)
    if left.modified == right.modified then
      return left.name:lower() < right.name:lower()
    end
    return left.modified > right.modified
  end)

  return items
end

local function valid_session_name(input)
  local name = vim.trim(input or "")
  if name:lower():sub(-4) == ".vim" then
    name = name:sub(1, -5)
  end

  if name == "" then
    return nil, "Session name cannot be empty"
  end
  if name:find('[<>:"/\\|?*]') or name:match("[%. ]$") then
    return nil, "Session name contains characters invalid on Windows"
  end

  local upper = name:upper()
  if
    upper == "CON"
    or upper == "PRN"
    or upper == "AUX"
    or upper == "NUL"
    or upper:match("^COM[1-9]$")
    or upper:match("^LPT[1-9]$")
  then
    return nil, "This name is reserved on Windows"
  end

  return name
end

local function save_session(input)
  local name, error_message = valid_session_name(input)
  if not name then
    vim.notify(error_message, vim.log.levels.ERROR)
    return
  end

  local path = session_directory .. "/" .. name .. ".vim"
  local ok, save_error =
    pcall(vim.cmd, "silent mksession! " .. vim.fn.fnameescape(path))

  if ok then
    vim.notify("Session saved: " .. name)
  else
    vim.notify("Session save failed: " .. tostring(save_error), vim.log.levels.ERROR)
  end
end

vim.api.nvim_create_user_command("SessionSave", function(options)
  if options.args ~= "" then
    save_session(options.args)
    return
  end

  vim.ui.input({ prompt = "Session name: " }, function(name)
    if name then
      save_session(name)
    end
  end)
end, {
  nargs = "?",
  complete = function(arglead)
    local matches = {}
    for _, item in ipairs(session_items()) do
      if vim.startswith(item.name:lower(), arglead:lower()) then
        table.insert(matches, item.name)
      end
    end
    return matches
  end,
  desc = "Save the current session by name",
})

vim.api.nvim_create_user_command("SessionLoad", function()
  local items = session_items()
  if #items == 0 then
    vim.notify("No saved sessions in " .. session_directory, vim.log.levels.INFO)
    return
  end

  vim.ui.select(items, {
    prompt = "Load session:",
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    if not choice then
      return
    end

    local ok, load_error =
      pcall(vim.cmd, "silent source " .. vim.fn.fnameescape(choice.path))
    if ok then
      vim.notify("Session loaded: " .. choice.name)
    else
      vim.notify(
        "Session load failed: " .. tostring(load_error),
        vim.log.levels.ERROR
      )
    end
  end)
end, {
  desc = "Choose and load a saved session",
})

local function toggle_pane_zoom()
  local restore = vim.t.pane_zoom_restore

  if restore and restore ~= "" then
    vim.cmd(restore)
    vim.t.pane_zoom_restore = nil
    return
  end

  if vim.fn.winnr("$") == 1 then
    vim.notify("No other pane to hide", vim.log.levels.INFO)
    return
  end

  vim.t.pane_zoom_restore = vim.fn.winrestcmd()
  vim.cmd("wincmd _")
  vim.cmd("wincmd |")
end

vim.keymap.set("n", "<leader>z", toggle_pane_zoom, {
  desc = "Toggle current pane zoom",
  silent = true,
})

local function markdown_link_completion()
  local line = vim.api.nvim_get_current_line()
  local cursor_col = vim.fn.col(".") - 1
  local before_cursor = line:sub(1, cursor_col)
  local kind
  local prefix = before_cursor:match("%[%[([^%]]*)$")

  if prefix then
    kind = "wiki"
  else
    prefix = before_cursor:match("%]%(([^()]*)$")
    if prefix then
      kind = "markdown"
    end
  end

  if not kind then
    vim.notify(
      "Link completion works inside [[... or [label](...",
      vim.log.levels.INFO
    )
    return
  end

  local current_path = vim.api.nvim_buf_get_name(0)
  local current_dir = startup_directory
  if current_path ~= "" then
    current_dir = vim.fs.dirname(current_path)
  end

  local prefix_path = prefix:gsub("\\", "/")
  local prefix_normalized = prefix_path:lower()
  local matches = {}

  local path_navigation = kind == "markdown"
    and prefix_path:find("/", 1, true) ~= nil

  if path_navigation then
    local directory_prefix, leaf = prefix_path:match("^(.*[/])([^/]*)$")
    local search_directory =
      vim.fs.normalize(current_dir .. "/" .. directory_prefix)

    if vim.fn.isdirectory(search_directory) == 1 then
      for name, entry_type in vim.fs.dir(search_directory) do
        if
          leaf == ""
          or name:lower():find(leaf:lower(), 1, true) == 1
        then
          local is_directory = entry_type == "directory"
          table.insert(matches, {
            word = directory_prefix .. name .. (is_directory and "/" or ""),
            abbr = name .. (is_directory and "/" or ""),
            menu = is_directory and "[Directory]" or "[File]",
            kind = is_directory and "Folder" or "File",
          })
        end
      end
    end
  else
    local paths = vim.fn.globpath(startup_directory, "**/*.md", false, true)

    for _, path in ipairs(paths) do
      local root_relative = vim.fs.relpath(startup_directory, path)
      if root_relative then
        root_relative = root_relative:gsub("\\", "/")
        local is_scratch = vim.startswith(root_relative, ".scratch/")
        local is_current = current_path ~= ""
          and vim.fs.normalize(path) == vim.fs.normalize(current_path)

        if not is_scratch and not is_current then
          local word
          if kind == "wiki" then
            word = root_relative:gsub("%.md$", "")
          else
            word = vim.fs.relpath(current_dir, path)
            if word then
              word = word:gsub("\\", "/")
            end
          end

          if
            word
            and (
              prefix_normalized == ""
              or word:lower():find(prefix_normalized, 1, true)
            )
          then
            table.insert(matches, {
              word = word,
              abbr = vim.fn.fnamemodify(path, ":t:r"),
              menu = root_relative,
              kind = "File",
            })
          end
        end
      end
    end
  end

  table.sort(matches, function(left, right)
    return left.word:lower() < right.word:lower()
  end)

  if #matches == 0 then
    vim.notify("No matching files or Markdown notes", vim.log.levels.INFO)
    return
  end

  local start_col = cursor_col - #prefix + 1
  vim.fn.complete(start_col, matches)
end

local function insert_buffer_markdown_link()
  local source_buffer = vim.api.nvim_get_current_buf()
  local source_window = vim.api.nvim_get_current_win()
  local source_path = vim.api.nvim_buf_get_name(source_buffer)

  if vim.bo[source_buffer].filetype ~= "markdown" then
    vim.notify("BufferLink is available in Markdown buffers", vim.log.levels.INFO)
    return
  end
  if source_path == "" then
    vim.notify("Save the current Markdown file first", vim.log.levels.INFO)
    return
  end
  if not vim.bo[source_buffer].modifiable then
    vim.notify("This buffer is not editable", vim.log.levels.INFO)
    return
  end

  local source_directory = vim.fs.dirname(source_path)
  local source_normalized = vim.fs.normalize(source_path)
  local choices = {}

  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    local path = vim.api.nvim_buf_get_name(buffer)
    if
      buffer ~= source_buffer
      and vim.bo[buffer].buflisted
      and vim.bo[buffer].buftype == ""
      and path ~= ""
      and vim.fs.normalize(path) ~= source_normalized
    then
      local relative_path = vim.fs.relpath(source_directory, path)
      if relative_path then
        relative_path = relative_path:gsub("\\", "/")
        table.insert(choices, {
          buffer = buffer,
          path = path,
          relative_path = relative_path,
          title = vim.fn.fnamemodify(path, ":t:r"),
        })
      end
    end
  end

  table.sort(choices, function(left, right)
    return left.relative_path:lower() < right.relative_path:lower()
  end)

  if #choices == 0 then
    vim.notify("No other file buffers are open", vim.log.levels.INFO)
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(source_window)
  local row, column = cursor[1] - 1, cursor[2]

  vim.ui.select(choices, {
    prompt = "Insert link to buffer:",
    format_item = function(item)
      return item.title .. "  " .. item.relative_path
    end,
  }, function(choice)
    if
      not choice
      or not vim.api.nvim_buf_is_valid(source_buffer)
      or not vim.bo[source_buffer].modifiable
    then
      return
    end

    local lines =
      vim.api.nvim_buf_get_lines(source_buffer, row, row + 1, false)
    if #lines == 0 then
      return
    end

    local title = choice.title:gsub("]", "\\]")
    local destination = choice.relative_path
      :gsub(" ", "%%20")
      :gsub("([()])", "\\%1")
    local link = "[" .. title .. "](" .. destination .. ")"
    local line = lines[1]
    local new_line =
      line:sub(1, column) .. link .. line:sub(column + 1)

    vim.api.nvim_buf_set_lines(
      source_buffer,
      row,
      row + 1,
      false,
      { new_line }
    )

    if
      vim.api.nvim_win_is_valid(source_window)
      and vim.api.nvim_win_get_buf(source_window) == source_buffer
    then
      vim.api.nvim_win_set_cursor(
        source_window,
        { row + 1, column + #link }
      )
    end
  end)
end

vim.api.nvim_create_user_command("BufferLink", insert_buffer_markdown_link, {
  desc = "Insert a Markdown link to an open file buffer",
})

local toc_start_marker = "<!-- TOC:start -->"
local toc_end_marker = "<!-- TOC:end -->"

local function markdown_heading_slug(title)
  return title
    :lower()
    :gsub("[^%w%s_%-\128-\255]", "")
    :gsub("%s+", "-")
    :gsub("%-+", "-")
    :gsub("^%-", "")
    :gsub("%-$", "")
end

local function collect_markdown_headings(lines)
  local headings = {}
  local slug_counts = {}
  local inside_toc = false
  local fence

  for row, line in ipairs(lines) do
    local trimmed = vim.trim(line)

    if trimmed == toc_start_marker then
      inside_toc = true
    elseif trimmed == toc_end_marker then
      inside_toc = false
    elseif not inside_toc then
      local fence_marker = line:match("^%s*(```+)") or line:match("^%s*(~~~+)")
      if fence_marker then
        local marker_character = fence_marker:sub(1, 1)
        if not fence then
          fence = marker_character
        elseif fence == marker_character then
          fence = nil
        end
      elseif not fence then
        local hashes, title = line:match("^(#+)%s+(.+)$")
        if hashes and #hashes <= 3 and title then
          title = vim.trim(title:gsub("%s+#+%s*$", ""))
          if title ~= "" then
            local base_slug = markdown_heading_slug(title)
            if base_slug ~= "" then
              local duplicate_index = slug_counts[base_slug] or 0
              slug_counts[base_slug] = duplicate_index + 1
              local slug = duplicate_index == 0
                  and base_slug
                or base_slug .. "-" .. duplicate_index

              table.insert(headings, {
                row = row,
                level = #hashes,
                title = title,
                slug = slug,
              })
            end
          end
        end
      end
    end
  end

  return headings
end

local function generate_markdown_toc()
  if vim.bo.filetype ~= "markdown" then
    vim.notify(":Toc is available in Markdown buffers", vim.log.levels.INFO)
    return
  end
  if not vim.bo.modifiable then
    vim.notify("This buffer is not editable", vim.log.levels.INFO)
    return
  end

  local buffer = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
  local headings = collect_markdown_headings(lines)
  if #headings == 0 then
    vim.notify("No H1-H3 headings found", vim.log.levels.INFO)
    return
  end

  local minimum_level = 3
  for _, heading in ipairs(headings) do
    minimum_level = math.min(minimum_level, heading.level)
  end

  local toc_lines = {
    toc_start_marker,
    "## 目次",
    "",
  }
  for _, heading in ipairs(headings) do
    local indentation = string.rep("  ", heading.level - minimum_level)
    local label = heading.title
      :gsub("\\", "\\\\")
      :gsub("%[", "\\[")
      :gsub("%]", "\\]")
    table.insert(
      toc_lines,
      indentation .. "- [" .. label .. "](#" .. heading.slug .. ")"
    )
  end
  table.insert(toc_lines, toc_end_marker)

  local toc_start
  local toc_end
  for index, line in ipairs(lines) do
    local trimmed = vim.trim(line)
    if trimmed == toc_start_marker then
      toc_start = index
    elseif trimmed == toc_end_marker then
      toc_end = index
      break
    end
  end

  if (toc_start and not toc_end) or (toc_end and not toc_start) then
    vim.notify("TOC markers are incomplete", vim.log.levels.ERROR)
    return
  end

  local view = vim.fn.winsaveview()
  if toc_start and toc_end then
    vim.api.nvim_buf_set_lines(
      buffer,
      toc_start - 1,
      toc_end,
      false,
      toc_lines
    )
    vim.notify("Table of contents updated")
  else
    local insertion_index = 0
    if lines[1] == "---" then
      for index = 2, #lines do
        if lines[index] == "---" then
          insertion_index = index
          break
        end
      end
    end

    table.insert(toc_lines, "")
    vim.api.nvim_buf_set_lines(
      buffer,
      insertion_index,
      insertion_index,
      false,
      toc_lines
    )
    vim.notify("Table of contents created")
  end
  vim.fn.winrestview(view)
end

local function jump_from_markdown_toc()
  local line = vim.api.nvim_get_current_line()
  local cursor_column = vim.api.nvim_win_get_cursor(0)[2] + 1
  local search_start = 1
  local target_slug

  while search_start <= #line do
    local match_start, match_end, _, anchor =
      line:find("(%b[]%((#[^%)]+)%))", search_start)
    if not match_start then
      break
    end
    if cursor_column >= match_start and cursor_column <= match_end then
      target_slug = anchor:sub(2)
      break
    end
    search_start = match_end + 1
  end

  if not target_slug then
    vim.cmd("normal! +")
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, heading in ipairs(collect_markdown_headings(lines)) do
    if heading.slug == target_slug then
      vim.api.nvim_win_set_cursor(0, { heading.row, 0 })
      vim.cmd("normal! zz")
      return
    end
  end

  vim.notify("Heading not found: #" .. target_slug, vim.log.levels.WARN)
end

vim.api.nvim_create_user_command("Toc", generate_markdown_toc, {
  desc = "Create or update the Markdown table of contents",
})

local checkbox_marks = {
  [" "] = true,
  x = true,
  X = true,
  ["/"] = true,
  ["-"] = true,
}

local function checkbox_parts(line)
  local prefix, mark, suffix =
    line:match("^(%s*[-*+]?%s*)%[(.)%](.*)$")

  if not prefix then
    prefix, mark, suffix =
      line:match("^(%s*%d+[.)]%s*)%[(.)%](.*)$")
  end

  if prefix and checkbox_marks[mark] then
    return prefix, mark, suffix
  end
end

local function set_markdown_checkbox(mark)
  if not vim.bo.modifiable then
    vim.notify("This buffer is not editable", vim.log.levels.INFO)
    return
  end

  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local prefix, _, suffix = checkbox_parts(line)

  local new_line
  if prefix then
    new_line = prefix .. "[" .. mark .. "]" .. suffix
    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(0, { row, math.min(col, #new_line) })
    return
  end

  local indentation, content = line:match("^(%s*)(.*)$")
  content = content:gsub("^[-*+]%s+", "", 1)
  content = content:gsub("^%d+[.)]%s+", "", 1)
  new_line = indentation .. "- [" .. mark .. "] " .. content

  vim.api.nvim_set_current_line(new_line)
  local new_col = content == "" and #new_line or math.min(#new_line, col + 6)
  vim.api.nvim_win_set_cursor(0, { row, new_col })
end

local function toggle_markdown_checkbox()
  local _, mark = checkbox_parts(vim.api.nvim_get_current_line())
  if not mark then
    set_markdown_checkbox(" ")
  else
    set_markdown_checkbox(mark:lower() == "x" and " " or "x")
  end
end

local function choose_markdown_checkbox()
  local choices = {
    { label = "[ ] Pending", mark = " " },
    { label = "[x] Done", mark = "x" },
    { label = "[/] Postponed", mark = "/" },
    { label = "[-] Cancelled", mark = "-" },
  }

  vim.ui.select(choices, {
    prompt = "Checkbox state:",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if choice then
      set_markdown_checkbox(choice.mark)
    end
  end)
end

-- nvim-treesitter no longer enables highlighting through
-- require("nvim-treesitter.configs").setup(). Neovim starts it per filetype.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function(event)
    pcall(vim.treesitter.start, event.buf)
    vim.keymap.set("i", "<C-x><C-f>", markdown_link_completion, {
      buffer = event.buf,
      desc = "Complete Markdown note link",
      silent = true,
    })
    vim.keymap.set("n", "<leader>x", toggle_markdown_checkbox, {
      buffer = event.buf,
      desc = "Create or toggle Markdown checkbox",
      silent = true,
    })
    vim.keymap.set("n", "<leader>X", choose_markdown_checkbox, {
      buffer = event.buf,
      desc = "Choose Markdown checkbox state",
      silent = true,
    })
    vim.keymap.set("n", "<leader>l", insert_buffer_markdown_link, {
      buffer = event.buf,
      desc = "Insert link to an open file buffer",
      silent = true,
    })
    vim.keymap.set("n", "<leader>t", generate_markdown_toc, {
      buffer = event.buf,
      desc = "Create or update Markdown table of contents",
      silent = true,
    })
    vim.keymap.set("n", "<CR>", jump_from_markdown_toc, {
      buffer = event.buf,
      desc = "Jump from TOC link to Markdown heading",
      silent = true,
    })
  end,
})

-- =========================================================
-- Windows IME indicator
-- ステータスライン右端に A / あ / ア / ｱ / Ａ を表示する
-- =========================================================

local function setup_ime_indicator()
  -- Windows以外では何もしない
  if vim.fn.has("win32") ~= 1 then return end

  local ok_ffi, ffi = pcall(require, "ffi")
  if not ok_ffi then
    vim.notify(
      "IME indicator: LuaJIT FFIを読み込めませんでした",
      vim.log.levels.WARN
    )
    return
  end

  local bit = require("bit")

  -- -------------------------------------------------------
  -- Win32 APIの型と関数
  -- -------------------------------------------------------

  ffi.cdef([[
    typedef void* HWND;
    typedef void* HIMC;

    typedef unsigned long DWORD;
    typedef long LONG;
    typedef int BOOL;

    typedef struct tagRECT {
      LONG left;
      LONG top;
      LONG right;
      LONG bottom;
    } RECT;

    typedef struct tagGUITHREADINFO {
      DWORD cbSize;
      DWORD flags;
      HWND hwndActive;
      HWND hwndFocus;
      HWND hwndCapture;
      HWND hwndMenuOwner;
      HWND hwndMoveSize;
      HWND hwndCaret;
      RECT rcCaret;
    } GUITHREADINFO;

    BOOL GetGUIThreadInfo(
      DWORD idThread,
      GUITHREADINFO* pgui
    );

    HWND GetForegroundWindow(void);

    DWORD GetWindowThreadProcessId(
      HWND hWnd,
      DWORD* lpdwProcessId
    );

    intptr_t SendMessageW(
      HWND hWnd,
      unsigned int Msg,
      uintptr_t wParam,
      intptr_t lParam
    );

    HIMC ImmGetContext(HWND hWnd);

    HWND ImmGetDefaultIMEWnd(HWND hWnd);

    BOOL ImmReleaseContext(
      HWND hWnd,
      HIMC hIMC
    );

    BOOL ImmGetOpenStatus(HIMC hIMC);

    BOOL ImmGetConversionStatus(
      HIMC hIMC,
      DWORD* conversion,
      DWORD* sentence
    );
  ]])

  local ok_user32, user32 = pcall(ffi.load, "user32.dll")
  local ok_imm32, imm32 = pcall(ffi.load, "imm32.dll")

  if not ok_user32 or not ok_imm32 then
    vim.notify(
      "IME indicator: user32.dllまたはimm32.dllを読み込めませんでした",
      vim.log.levels.WARN
    )
    return
  end

  -- -------------------------------------------------------
  -- IME変換モード
  -- -------------------------------------------------------

  local IME_CMODE_NATIVE = 0x0001
  local IME_CMODE_KATAKANA = 0x0002
  local IME_CMODE_FULLSHAPE = 0x0008
  local WM_IME_CONTROL = 0x0283
  local IMC_GETCONVERSIONMODE = 0x0001
  local IMC_GETOPENSTATUS = 0x0005

  local states = {
    unknown = {
      text = " ? ",
      highlight = "ImeUnknown",
      description = "取得不能",
    },

    off = {
      text = " A ",
      highlight = "ImeOff",
      description = "IME OFF",
    },

    hiragana = {
      text = " あ ",
      highlight = "ImeHiragana",
      description = "ひらがな",
    },

    katakana = {
      text = " ア ",
      highlight = "ImeKatakana",
      description = "全角カタカナ",
    },

    half_katakana = {
      text = " ｱ ",
      highlight = "ImeKatakana",
      description = "半角カタカナ",
    },

    full_alpha = {
      text = " Ａ ",
      highlight = "ImeFullAlpha",
      description = "全角英数",
    },

    alpha = {
      text = " A ",
      highlight = "ImeOff",
      description = "半角英数",
    },
  }

  -- 使用中のカラースキームに追従させる
  vim.api.nvim_set_hl(0, "ImeUnknown", {
    link = "Comment",
  })

  vim.api.nvim_set_hl(0, "ImeOff", {
    link = "Comment",
  })

  vim.api.nvim_set_hl(0, "ImeHiragana", {
    link = "String",
  })

  vim.api.nvim_set_hl(0, "ImeKatakana", {
    link = "WarningMsg",
  })

  vim.api.nvim_set_hl(0, "ImeFullAlpha", {
    link = "Identifier",
  })

  local current_state = states.unknown

  -- ステータスラインから呼び出す関数
  _G.ime_indicator = function() return current_state.text end

  local function is_null(pointer) return pointer == nil or pointer == ffi.NULL end

  -- -------------------------------------------------------
  -- WindowsからIME状態を取得する
  -- -------------------------------------------------------

  local function focused_window()
    local foreground = user32.GetForegroundWindow()
    if is_null(foreground) then return nil end

    -- GetGUIThreadInfo(0) はNeovim自身のスレッドを調べるため、Windows
    -- Terminal等では失敗する。前面ウィンドウを所有するスレッドを指定する。
    local thread_id = user32.GetWindowThreadProcessId(foreground, nil)
    if thread_id == 0 then return foreground end

    local gui_info = ffi.new("GUITHREADINFO[1]")
    gui_info[0].cbSize = ffi.sizeof("GUITHREADINFO")
    if user32.GetGUIThreadInfo(thread_id, gui_info) == 0 then
      return foreground
    end

    local hwnd = gui_info[0].hwndFocus
    if is_null(hwnd) then hwnd = gui_info[0].hwndActive end
    if is_null(hwnd) then hwnd = foreground end
    return hwnd
  end

  local function state_from_mode(is_open, mode)
    if not is_open then return states.off end

    local native = bit.band(mode, IME_CMODE_NATIVE) ~= 0
    local katakana = bit.band(mode, IME_CMODE_KATAKANA) ~= 0
    local fullshape = bit.band(mode, IME_CMODE_FULLSHAPE) ~= 0
    if native and katakana and fullshape then
      return states.katakana
    elseif native and katakana then
      return states.half_katakana
    elseif native then
      return states.hiragana
    elseif fullshape then
      return states.full_alpha
    end
    return states.alpha
  end

  local function read_ime_state()
    local hwnd = focused_window()
    if is_null(hwnd) then return states.unknown end

    local ime_context = imm32.ImmGetContext(hwnd)
    if not is_null(ime_context) then
      local is_open = imm32.ImmGetOpenStatus(ime_context) ~= 0
      local conversion = ffi.new("DWORD[1]", 0)
      local sentence = ffi.new("DWORD[1]", 0)
      local conversion_ok = imm32.ImmGetConversionStatus(
        ime_context,
        conversion,
        sentence
      ) ~= 0
      imm32.ImmReleaseContext(hwnd, ime_context)
      if not is_open then
        return states.off
      elseif conversion_ok then
        return state_from_mode(true, tonumber(conversion[0]))
      end
    end

    -- TerminalやTSFベースのIMEではImmGetContextが取得できない場合がある。
    -- その場合は既定IMEウィンドウへWM_IME_CONTROLを送って照会する。
    local ime_window = imm32.ImmGetDefaultIMEWnd(hwnd)
    if is_null(ime_window) then return states.unknown end
    local is_open = user32.SendMessageW(
      ime_window,
      WM_IME_CONTROL,
      IMC_GETOPENSTATUS,
      0
    ) ~= 0
    if not is_open then return states.off end
    local mode = tonumber(
      user32.SendMessageW(ime_window, WM_IME_CONTROL, IMC_GETCONVERSIONMODE, 0)
    )
    return state_from_mode(true, mode)
  end

  local function apply_state(new_state)
    if current_state == new_state then return end

    current_state = new_state

    vim.api.nvim_set_hl(0, "ImeIndicator", {
      link = new_state.highlight,
    })

    vim.cmd("redrawstatus")
  end

  -- -------------------------------------------------------
  -- 定期監視
  -- -------------------------------------------------------

  local timer = vim.uv.new_timer()

  timer:start(
    0,
    100,
    vim.schedule_wrap(function() apply_state(read_ime_state()) end)
  )

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      if timer and not timer:is_closing() then
        timer:stop()
        timer:close()
      end
    end,
  })

  -- 手動確認用
  vim.api.nvim_create_user_command("ImeStatus", function()
    local state = read_ime_state()

    vim.notify(string.format("IME: %s %s", state.text, state.description))
  end, {})
end

setup_ime_indicator()

-- When IME text is committed in Normal mode, keep the text and enter Insert
-- mode automatically. Special keys and non-editable plugin buffers are ignored.
local ime_pending_text = ""
local ime_insert_scheduled = false
local ime_auto_insert_ns = vim.api.nvim_create_namespace("ime-auto-insert")

vim.on_key(function(key, typed)
  local first_byte = key:byte(1)
  local is_non_ascii_text = first_byte and first_byte >= 0xC2

  if
    vim.api.nvim_get_mode().mode ~= "n"
    or typed == ""
    or key ~= typed
    or not is_non_ascii_text
    or not vim.bo.modifiable
    or vim.bo.buftype ~= ""
  then
    return
  end

  ime_pending_text = ime_pending_text .. key

  if not ime_insert_scheduled then
    ime_insert_scheduled = true
    vim.schedule(function()
      local text = ime_pending_text
      ime_pending_text = ""
      ime_insert_scheduled = false

      if
        text ~= ""
        and vim.api.nvim_get_mode().mode == "n"
        and vim.bo.modifiable
        and vim.bo.buftype == ""
      then
        vim.api.nvim_feedkeys("i" .. text, "nt", false)
      end
    end)
  end

  -- Prevent the committed text from being interpreted as Normal-mode commands.
  return ""
end, ime_auto_insert_ns)

-- =========================================================
-- 組み込みステータスライン
-- =========================================================

vim.o.laststatus = 3

vim.o.statusline = table.concat({
  " %f", -- ファイル名
  " %h%m%r", -- help、変更済み、readonly
  "%=", -- 以下を右寄せ
  " %y", -- ファイル形式
  " %l:%c ", -- 行・列
  "%#ImeIndicator#", -- IME用ハイライト開始
  "%{v:lua.ime_indicator()}", -- A / あ
  "%*", -- ハイライト解除
  " ",
})
