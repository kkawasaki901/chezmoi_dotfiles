local M = {}

---@param lines string[]
---@param heading string
---@param entry string
---@return string[]
function M.append_to_section(lines, heading, entry)
	local result = vim.deepcopy(lines)
	local heading_index

	for index, line in ipairs(result) do
		if vim.trim(line) == heading then
			heading_index = index
			break
		end
	end

	if not heading_index then
		if #result > 0 and result[#result] ~= "" then
			table.insert(result, "")
		end
		table.insert(result, heading)
		table.insert(result, "")
		table.insert(result, entry)
		return result
	end

	local next_heading = #result + 1
	for index = heading_index + 1, #result do
		if result[index]:match("^#+%s+") then
			next_heading = index
			break
		end
	end

	local insert_at = next_heading
	while insert_at > heading_index + 1 and result[insert_at - 1]:match("^%s*$") do
		insert_at = insert_at - 1
	end

	table.insert(result, insert_at, entry)
	if next_heading <= #lines and insert_at == next_heading then
		table.insert(result, insert_at + 1, "")
	end

	return result
end

---@param client obsidian.Client
---@param opts { heading: string, time_format: string }
---@param content string|nil
function M.capture(client, opts, content)
	content = vim.trim(content or "")
	if content == "" then
		vim.notify("Thino capture cancelled", vim.log.levels.INFO)
		return
	end

	local entry = "- " .. os.date(opts.time_format) .. " " .. content:gsub("\r\n", "\n"):gsub("\n", "\n\t")
	local note = client:today()
	local path = tostring(note.path)
	local buffer = vim.fn.bufnr(path)

	if buffer >= 0 and vim.api.nvim_buf_is_loaded(buffer) then
		local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
		local updated = M.append_to_section(lines, opts.heading, entry)
		vim.api.nvim_buf_set_lines(buffer, 0, -1, false, updated)
		vim.api.nvim_buf_call(buffer, function()
			vim.cmd.write()
		end)
	else
		local lines = vim.fn.readfile(path)
		vim.fn.writefile(M.append_to_section(lines, opts.heading, entry), path)
	end

	vim.notify("Captured to " .. path, vim.log.levels.INFO)
end

---@param client obsidian.Client
---@param opts { heading: string, time_format: string, window_width: integer|nil, window_height: integer|nil }
function M.open_capture(client, opts)
	local buffer = vim.api.nvim_create_buf(false, true)
	local width = math.max(20, math.min(opts.window_width or 80, vim.o.columns - 4))
	local height = math.max(5, math.min(opts.window_height or 16, vim.o.lines - 4))
	local row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1)
	local col = math.max(0, math.floor((vim.o.columns - width) / 2))
	local saved_content

	local uv = vim.uv or vim.loop
	vim.api.nvim_buf_set_name(buffer, "thino://capture/" .. tostring(uv.hrtime()))
	vim.bo[buffer].buftype = "acwrite"
	vim.bo[buffer].bufhidden = "wipe"
	vim.bo[buffer].swapfile = false
	vim.bo[buffer].filetype = "markdown"

	vim.api.nvim_open_win(buffer, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " Thino Capture ",
		title_pos = "center",
	})

	local namespace = vim.api.nvim_create_namespace("obvim-thino-capture")
	vim.api.nvim_buf_set_extmark(buffer, namespace, 0, 0, {
		virt_lines = {
			{ { "  :wq で保存 / :q! でキャンセル", "Comment" } },
		},
		virt_lines_above = true,
	})

	vim.api.nvim_create_autocmd("BufWriteCmd", {
		buffer = buffer,
		once = false,
		callback = function()
			local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
			saved_content = vim.trim(table.concat(lines, "\n"))
			vim.bo[buffer].modified = false
			vim.notify("Thino saved. Close the window to capture.", vim.log.levels.INFO)
		end,
	})

	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = buffer,
		once = true,
		callback = function()
			if not saved_content or saved_content == "" then return end
			vim.schedule(function()
				M.capture(client, opts, saved_content)
			end)
		end,
	})

	vim.keymap.set("n", "<C-s>", "<cmd>write<cr>", {
		buffer = buffer,
		silent = true,
		desc = "Save Thino capture",
	})

	vim.cmd.startinsert()
end

return M
