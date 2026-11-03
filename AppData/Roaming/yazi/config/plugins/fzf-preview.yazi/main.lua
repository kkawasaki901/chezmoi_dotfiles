local M = {}

local state = ya.sync(function()
	local selected = {}
	for _, url in pairs(cx.active.selected) do
		selected[#selected + 1] = url
	end
	return cx.active.current.cwd, selected
end)

function M:entry()
	ya.emit("escape", { visual = true })

	local cwd, selected = state()
	if cwd.scheme.is_virtual then
		return ya.notify {
			title = "Fzf preview",
			content = "Not supported under virtual filesystems",
			timeout = 5,
			level = "warn",
		}
	end

	local permit = ui.hide()
	local output, err = M.run_with(cwd, selected)
	permit:drop()

	if not output then
		return ya.notify {
			title = "Fzf preview",
			content = tostring(err),
			timeout = 5,
			level = "error",
		}
	end

	local urls = M.split_urls(cwd, output)
	if #urls == 1 then
		local cha = #selected == 0 and fs.cha(urls[1])
		ya.emit(cha and cha.is_dir and "cd" or "reveal", { urls[1], raw = true })
	elseif #urls > 1 then
		urls.state = #selected > 0 and "off" or "on"
		ya.emit("toggle_all", urls)
	end
end

function M.run_with(cwd, selected)
	local preview_script = os.getenv("APPDATA")
		.. "\\yazi\\config\\plugins\\fzf-preview.yazi\\preview.ps1"
	local preview_command = string.format(
		[[pwsh.exe -NoLogo -NoProfile -File "%s" {}]],
		preview_script
	)

	local child, err = Command("fzf")
		:arg({
			"-m",
			"--preview-window=right,55%,border-left,wrap",
			"--preview=" .. preview_command,
			"--bind=ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down",
			"--header=Ctrl-U/D: preview scroll",
		})
		:cwd(tostring(cwd))
		:stdin(#selected > 0 and Command.PIPED or Command.INHERIT)
		:stdout(Command.PIPED)
		:spawn()

	if not child then
		return nil, Err("Failed to start `fzf`, error: %s", err)
	end

	for _, url in ipairs(selected) do
		child:write_all(string.format("%s\n", url))
	end
	if #selected > 0 then
		child:flush()
	end

	local output, wait_err = child:wait_with_output()
	if not output then
		return nil, Err("Cannot read `fzf` output, error: %s", wait_err)
	elseif not output.status.success and output.status.code ~= 130 then
		return nil, Err("`fzf` exited with error code %s", output.status.code)
	end
	return output.stdout, nil
end

function M.split_urls(cwd, output)
	local urls = {}
	for line in output:gmatch("[^\r\n]+") do
		local url = Url(line)
		urls[#urls + 1] = url.is_absolute and url or cwd:join(url)
	end
	return urls
end

return M
