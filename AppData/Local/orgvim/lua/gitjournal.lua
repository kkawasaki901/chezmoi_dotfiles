-- Minimal GitJournal-like local journaling plugin for Neovim
-- Config:
--   Set directory via: vim.g.gitjournal_dir = "/path/to/journal"
--   Or use command: :GitJournalSetDir /path/to/journal
-- Usage:
--   :GitJournalNote  -> opens a floating window to type a memo; close with :q
-- Keymaps:
--   Default: <leader>jn runs :GitJournalNote (can be disabled)

local function notify(msg, level)
	vim.notify("gitjournal: " .. msg, level or vim.log.levels.INFO)
end

local function ensure_dir(dir)
	if not dir or dir == "" then
		return false, "gitjournal_dir is not set"
	end
	dir = vim.fn.expand(dir)
	if vim.fn.isdirectory(dir) == 0 then
		local ok = vim.fn.mkdir(dir, "p")
		if ok == 0 then
			return false, "failed to create directory: " .. dir
		end
	end
	return true, dir
end

local function tz_offset()
	local z = os.date("%z") or "+0000"
	if #z == 5 then
		return string.sub(z, 1, 3) .. ":" .. string.sub(z, 4, 5)
	end
	return "+00:00"
end

local function now_iso()
	return os.date("%Y-%m-%dT%H:%M:%S") .. tz_offset()
end

local function today_filename()
	return os.date("%Y-%m-%d") .. ".md"
end

local function current_time_line()
	return os.date("%H:%M:%S")
end

local function joinpath(...)
	if vim.fs and vim.fs.joinpath then
		return vim.fs.joinpath(...)
	end
	local sep = package.config:sub(1, 1)
	local parts = { ... }
	return table.concat(parts, sep)
end

local function read_lines(path)
	if vim.fn.filereadable(path) == 1 then
		return vim.fn.readfile(path)
	end
	return {}
end

local function write_lines(path, lines)
	-- writefile() writes the bytes held by Neovim strings. Neovim's internal
	-- encoding is UTF-8, so keep the conversion explicit at this output boundary.
	local utf8_lines = {}
	for i, line in ipairs(lines) do
		utf8_lines[i] = vim.fn.iconv(line, vim.o.encoding, "utf-8")
	end
	return vim.fn.writefile(utf8_lines, path) == 0
end

local function trim_trailing_empty(lines)
	local last = #lines
	while last > 0 do
		local s = (lines[last] or ""):gsub("%s+$", "")
		if s ~= "" then
			break
		end
		last = last - 1
	end
	local out = {}
	for i = 1, last do
		out[i] = lines[i]
	end
	return out
end

local function ensure_front_matter(lines, created, modified)
	-- Ensures a YAML front matter with created/modified exists and is updated.
	-- Returns new lines.
	local n = #lines
	if n >= 3 and lines[1] == "---" then
		-- find end of front matter
		local end_idx = nil
		for i = 2, n do
			if lines[i] == "---" then
				end_idx = i
				break
			end
		end
		if end_idx then
			-- map existing keys
			local created_idx, modified_idx
			for i = 2, end_idx - 1 do
				local l = lines[i]
				if l:match("^created:%s*") then
					created_idx = i
				end
				if l:match("^modified:%s*") then
					modified_idx = i
				end
			end
			if not created_idx then
				table.insert(lines, 2, "created: " .. created)
				end_idx = end_idx + 1
			else
				-- preserve existing created
				created = lines[created_idx]:gsub("^created:%s*", "")
			end
			if modified_idx then
				lines[modified_idx] = "modified: " .. modified
			else
				table.insert(lines, 2 + (created_idx and 1 or 0), "modified: " .. modified)
				end_idx = end_idx + 1
			end
			return lines
		end
	end
	-- No valid front matter, prepend new block
	local new_lines = {
		"---",
		"created: " .. created,
		"modified: " .. modified,
		"---",
		"",
	}
	for _, l in ipairs(lines) do
		table.insert(new_lines, l)
	end
	return new_lines
end

local function append_entry(dir, memo_lines)
	local ok, resolved = ensure_dir(dir)
	if not ok then
		return false, resolved
	end
	local path = joinpath(resolved, today_filename())

	local now = now_iso()
	local lines = read_lines(path)
	local exists = (vim.fn.filereadable(path) == 1)

	if not exists then
		-- create initial front matter
		lines = ensure_front_matter({}, now, now)
	else
		-- update modified in front matter
		lines = ensure_front_matter(lines, now, now)
	end

	-- ensure a blank line before the new entry unless file ends with blank already
	if #lines > 0 and (lines[#lines] or "") ~= "" then
		table.insert(lines, "")
	end

	-- Append time + memo
	table.insert(lines, current_time_line())
	for _, l in ipairs(memo_lines) do
		table.insert(lines, l)
	end

	-- Ensure trailing newline for readability
	if (lines[#lines] or "") ~= "" then
		table.insert(lines, "")
	end

	local okw = write_lines(path, lines)
	if not okw then
		return false, "failed to write: " .. path
	end
	return true, path
end

local function ensure_today_file(dir)
	local ok, resolved = ensure_dir(dir)
	if not ok then
		return false, resolved
	end
	local path = joinpath(resolved, today_filename())
	if vim.fn.filereadable(path) == 1 then
		return true, path
	end
	local now = now_iso()
	local lines = ensure_front_matter({}, now, now)
	if not write_lines(path, lines) then
		return false, "failed to create: " .. path
	end
	return true, path
end

local function open_popup_for_memo()
	local buf = vim.api.nvim_create_buf(false, true)
	if buf == 0 then
		notify("failed to create buffer", vim.log.levels.ERROR)
		return
	end

	-- vim.api.nvim_buf_set_name(buf, "[GitJournal]")
	vim.bo[buf].buftype = ""
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "markdown"
	vim.bo[buf].fileencoding = "utf-8"
	vim.bo[buf].swapfile = false

	local width = math.floor(vim.o.columns * 0.6)
	local height = math.floor(vim.o.lines * 0.5)
	width = math.max(40, math.min(width, vim.o.columns - 4))
	height = math.max(10, math.min(height, vim.o.lines - 4))
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	-- Helpful hint in the cmdline
	notify("Type your memo, close with :q to append")

    -- Helper: capture and append buffer content once
    local function capture_and_append(b)
        if vim.b[b].gitjournal_captured then
            return
        end
        local lines = vim.api.nvim_buf_get_lines(b, 0, -1, false)
        lines = trim_trailing_empty(lines)
        local nonempty = false
        for _, l in ipairs(lines) do
            if l:match("%S") then
                nonempty = true
                break
            end
        end
        -- Mark as captured to avoid double-append on multiple events
        vim.b[b].gitjournal_captured = true
        if not nonempty then
            -- Nothing to append; also clear modified so :q doesn't complain
            pcall(function()
                vim.bo[b].modified = false
            end)
            return
        end
        local dir = vim.g.gitjournal_dir
        local ok, res = append_entry(dir, lines)
        if ok then
            notify("Appended note to " .. res)
            -- Allow plain :q by clearing modified after saving
            pcall(function()
                vim.bo[b].modified = false
            end)
        else
            notify(res or "failed to append", vim.log.levels.ERROR)
        end
    end

    -- Autocmds to capture content on close or quit
    local aug = vim.api.nvim_create_augroup("GitJournalCapture" .. buf, { clear = true })
    -- Handle plain :q before Neovim blocks on modified buffer
    vim.api.nvim_create_autocmd({ "QuitPre" }, {
        group = aug,
        buffer = buf,
        callback = function(args)
            capture_and_append(args.buf)
        end,
    })
    -- Fallback when buffer is wiped by closing the window or switching buffers
    vim.api.nvim_create_autocmd({ "BufWipeout" }, {
        group = aug,
        buffer = buf,
        callback = function(args)
            capture_and_append(args.buf)
        end,
    })

	-- Return focus for editing
	vim.api.nvim_set_current_win(win)
end

-- Public command: open popup and append on close
vim.api.nvim_create_user_command("GitJournalNote", function()
	if not vim.g.gitjournal_dir or vim.g.gitjournal_dir == "" then
		notify("Set journal dir via :GitJournalSetDir <path> or vim.g.gitjournal_dir")
	end
	open_popup_for_memo()
end, {})

-- Set directory command
vim.api.nvim_create_user_command("GitJournalSetDir", function(opts)
	if not opts.args or opts.args == "" then
		notify("Usage: :GitJournalSetDir <path>", vim.log.levels.WARN)
		return
	end
	vim.g.gitjournal_dir = opts.args
	local ok, resolved = ensure_dir(vim.g.gitjournal_dir)
	if ok then
		notify("journal dir set to: " .. resolved)
	else
		notify(resolved, vim.log.levels.ERROR)
	end
end, { nargs = 1, complete = "dir" })

local function _gj_open_mode_to_cmd(mode)
	mode = (mode or ""):lower()
	if mode == "" or mode == "edit" then
		return "edit"
	end
	if mode == "split" then
		return "split"
	end
	if mode == "vsplit" or mode == "v" then
		return "vsplit"
	end
	if mode == "tab" or mode == "tabedit" or mode == "tabnew" then
		return "tabedit"
	end
	return nil, "invalid open mode: " .. mode .. " (use edit|split|vsplit|tab)"
end

local function _gj_open_mode_complete(arglead, _cmdline, _cursorpos)
	local items = { "edit", "split", "vsplit", "tab" }
	if not arglead or arglead == "" then
		return items
	end
	local out = {}
	for _, it in ipairs(items) do
		if it:find("^" .. vim.pesc(arglead)) then
			table.insert(out, it)
		end
	end
	return out
end

-- Open today's file (creating it if missing). Optional arg: edit|split|vsplit|tab
vim.api.nvim_create_user_command("GitJournalOpenToday", function(opts)
	local dir = vim.g.gitjournal_dir
	if not dir or dir == "" then
		notify("Set journal dir via :GitJournalSetDir <path> or vim.g.gitjournal_dir")
		return
	end
	local ok, res = ensure_today_file(dir)
	if not ok then
		notify(res or "failed to open today's file", vim.log.levels.ERROR)
		return
	end
	local cmd, err = _gj_open_mode_to_cmd(opts.args)
	if not cmd then
		notify(err, vim.log.levels.ERROR)
		return
	end
	vim.cmd(("%s %s"):format(cmd, vim.fn.fnameescape(res)))
end, { nargs = "?", complete = _gj_open_mode_complete })

-- List existing journal files and open selected one
local function list_journal_files(dir)
	local ok, resolved = ensure_dir(dir)
	if not ok then
		return false, resolved
	end
	local names = vim.fn.readdir(resolved)
	local items = {}
	for _, name in ipairs(names) do
		if name:match("^%d%d%d%d%-%d%d%-%d%d%.md$") then
			table.insert(items, {
				label = name:gsub("%.md$", ""),
				path = joinpath(resolved, name),
				name = name,
			})
		end
	end
	if #items == 0 then
		return true, {}
	end
	table.sort(items, function(a, b)
		return a.name > b.name
	end) -- newest first by date in name
	return true, items
end

vim.api.nvim_create_user_command("GitJournalList", function(opts)
	local dir = vim.g.gitjournal_dir
	if not dir or dir == "" then
		notify("Set journal dir via :GitJournalSetDir <path> or vim.g.gitjournal_dir")
		return
	end
	local ok, items_or_err = list_journal_files(dir)
	if not ok then
		notify(items_or_err or "failed to list journal files", vim.log.levels.ERROR)
		return
	end
	local items = items_or_err
	if #items == 0 then
		notify("No journal files found")
		return
	end
	vim.ui.select(items, {
		prompt = "Select journal",
		format_item = function(it)
			return it.label
		end,
	}, function(choice)
		if not choice then
			return
		end
		local cmd, err = _gj_open_mode_to_cmd(opts.args)
		if not cmd then
			notify(err, vim.log.levels.ERROR)
			return
		end
		vim.cmd(("%s %s"):format(cmd, vim.fn.fnameescape(choice.path)))
	end)
end, { nargs = "?", complete = _gj_open_mode_complete })

-- Default keymap (can be disabled by setting vim.g.gitjournal_default_keymaps = false)
local function set_default_keymaps()
	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, desc = desc })
	end
	map("n", "<leader>jn", ":GitJournalNote<CR>", "GitJournal: New note")
	map("n", "<leader>jl", ":GitJournalList<CR>", "GitJournal: List journals")
end

if vim.g.gitjournal_default_keymaps == nil or vim.g.gitjournal_default_keymaps == true then
	pcall(set_default_keymaps)
end
