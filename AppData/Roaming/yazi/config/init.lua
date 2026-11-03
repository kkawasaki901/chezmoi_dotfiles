require("git"):setup({
	-- Order of status signs showing in the linemode
	order = 1500,
})

require("bookmarks"):setup({
	persist = "all",
	show_keys = true,
	notify = { enable = true },
})

require("yatline"):setup({
	section_separator = { open = "", close = "" },
	part_separator = { open = "", close = "" },
	inverse_separator = { open = "", close = "" },

	padding = { inner = 1, outer = 1 },

	style_a = {
		bg = "white",
		fg = "black",
		bg_mode = {
			normal = "white",
			select = "brightyellow",
			un_set = "brightred",
		},
	},
	style_b = { bg = "brightblack", fg = "brightwhite" },
	style_c = { bg = "black", fg = "brightwhite" },

	permissions_t_fg = "green",
	permissions_r_fg = "yellow",
	permissions_w_fg = "red",
	permissions_x_fg = "cyan",
	permissions_s_fg = "white",

	tab_width = 20,

	selected = { icon = "󰻭", fg = "yellow" },
	copied = { icon = "", fg = "green" },
	cut = { icon = "", fg = "red" },

	files = { icon = "", fg = "blue" },
	filtereds = { icon = "", fg = "magenta" },

	total = { icon = "󰮍", fg = "yellow" },
	success = { icon = "", fg = "green" },
	failed = { icon = "", fg = "red" },

	show_background = true,

	display_header_line = true,
	display_status_line = true,

	component_positions = { "header", "tab", "status" },

	header_line = {
		left = {
			section_a = {
				{ type = "line", name = "tabs" },
			},
			section_b = {},
			section_c = {},
		},
		right = {
			section_a = {
				-- { type = "string", name = "date", params = { "%Y-%m-%d" } },
				{ type = "string", name = "japanese_date" },
			},
			section_b = {
				{ type = "string", name = "date", params = { "%X" } },
			},
			section_c = {},
		},
	},

	status_line = {
		left = {
			section_a = {
				{ type = "string", name = "tab_mode" },
			},
			section_b = {
				{ type = "string", name = "hovered_size" },
			},
			section_c = {
				{ type = "string", name = "hovered_path" },
				{ type = "coloreds", name = "count" },
			},
		},
		right = {
			section_a = {
				{ type = "string", name = "cursor_position" },
			},
			section_b = {
				{ type = "string", name = "cursor_percentage" },
			},
			section_c = {
				{ type = "string", name = "hovered_file_extension", params = { true } },
				{ type = "coloreds", name = "permissions" },
			},
		},
	},
})

local weekdays = {
	[1] = "日",
	[2] = "月",
	[3] = "火",
	[4] = "水",
	[5] = "木",
	[6] = "金",
	[7] = "土",
}

function Yatline.string.get:japanese_date()
	-- %w は 日曜=0 ～ 土曜=6
	local weekday_index = tonumber(os.date("%w")) + 1
	return os.date("%Y-%m-%d") .. " " .. weekdays[weekday_index]
end

require("simple-tag"):setup({
	-- UI display mode (icon, text, hidden)
	ui_mode = "icon", -- (Optional)

	-- Disable tag key hints (popup in bottom right corner)
	hints_disabled = false, -- (Optional)

	-- Display tags on the left side or right side.
	left_side = false, -- (Optional)

	-- Entity order (if left_side = true): adjusts icon/text position.
	-- For example, if you want icon to be on the most left of line then set render_order less than 1000.
	-- More info about the order values: https://github.com/sxyazi/yazi/blob/a2996908deddd4fc5061d18cf77f0af9f07b0e5a/yazi-plugin/preset/components/entity.lua#L4-L9

	-- Linemode order (if left_side = false, by default): adjusts icon/text position.
	-- For example, if you want icon to be on the most right of linemode then set render_order larger than 1000 and less than 2000.
	-- More info about the order values: https://github.com/sxyazi/yazi/blob/a2996908deddd4fc5061d18cf77f0af9f07b0e5a/yazi-plugin/preset/components/linemode.lua#L4-L5
	-- Default is 1500 if tags is on the right side, otherwise 500 to make sure it won't conflict with default line padding left/right.
	render_order = 500, -- (Optional).

	-- Replace default yazi file/folder icons with tag icons. Only apply if left_side = true and have at least 1 tag.
	-- Look better if it has only 1 tag. -> use function instead of boolean
	replace_default_icon = false, -- (Optional)

	-- Padding for left/right side. Default will calculate automatically based on render_order and left_side.
	-- Unless you has custom linemode/entity render function, you mostly don't need to set these values.
	-- padding_left = " ", -- (Optional, string only)
	-- padding_right = " ", -- (Optional, string only)

	-- Use replace_default_icon as a function instead

	-- tags: list/table of tag keys
	-- file: fs::File. https://yazi-rs.github.io/docs/plugins/context#fs-file

	-- replace_default_icon = function(file, tags) -- (Optional)
	-- 	--return tags[1] == "*" and file.is_hovered -- Only apply to file/folder with tag key * and hovered
	-- 	return #tags == 1 -- Only apply to file/folder with only 1 tag
	-- end,

	-- You can backup/restore this folder within the same OS (Linux, windows, or MacOS).
	-- But you can't restore backed up folder in the different OS because they use difference absolute path.
	-- save_path =  -- full path to save tags folder (Optional)
	--       - Linux/MacOS: os.getenv("HOME") .. "/.config/yazi/tags"
	--       - Windows: os.getenv("APPDATA") .. "\\yazi\\config\\tags"

	-- Set tag colors
	colors = { -- (Optional)
		-- Set this same value with `theme.toml` > [mgr] > hovered > reversed
		-- Default theme use "reversed = true".
		-- More info: https://github.com/sxyazi/yazi/blob/077faacc9a84bb5a06c5a8185a71405b0cb3dc8a/yazi-config/preset/theme-dark.toml#L25
		-- Only need to set this if you use shipped/stable yazi <= v25.5.31 or nightly yazi installed before 11/12/2025
		reversed = true, -- (Optional)

		-- More colors: https://yazi-rs.github.io/docs/configuration/theme#types.color
		-- format: [tag key] = "color"
		["*"] = "#bf68d9", -- (Optional)
		["$"] = "green",
		["!"] = "#cc9057",
		["1"] = "cyan",
		["p"] = "red",
	},

	-- Set tag icons. Only show when ui_mode = "icon".
	-- Any text or nerdfont icons should work as long as you use nerdfont to render yazi.
	-- Default icon from mactag.yazi: ●; Some generic icons: , , 󱈤
	-- More icon from nerd fonts: https://www.nerdfonts.com/cheat-sheet
	icons = { -- (Optional)
		-- default icon
		default = "󰚋",

		-- format: [tag key] = "tag icon"
		["*"] = "*",
		["$"] = "",
		["!"] = "",
		["p"] = "",
		["w"] = "",
	},
})


-- Windows ConPTY/Zellij/wtmux miscounts supplementary-plane Nerd Font glyphs.
-- Keep the regular UI outside Zellij; substitute only these glyphs inside it.
local running_in_multiplexer = os.getenv("ZELLIJ_SESSION_NAME") or os.getenv("WTMUX")
if package.config:sub(1, 1) == "\\" and running_in_multiplexer then
    local function safe_icon(text)
        return (text:gsub("[\240-\244][\128-\191][\128-\191][\128-\191]", "*"))
    end
    local original_icon = Entity.icon
    function Entity:icon()
        local icon = self._file:icon()
        if icon and safe_icon(icon.text) ~= icon.text then
            local text = safe_icon(icon.text) .. " "
            return self._file.is_hovered and text or ui.Line(text):style(icon.style)
        end
        return original_icon(self)
    end
    if Yatline then
        for _, name in ipairs({ "selected", "copied", "cut", "files", "filtereds", "total", "success", "failed" }) do
            local item = Yatline.config[name]
            if item and item.icon then item.icon = safe_icon(item.icon) end
        end
        local original_extension = Yatline.string.get.hovered_file_extension
        function Yatline.string.get:hovered_file_extension(show_icon)
            return safe_icon(original_extension(self, show_icon))
        end
    end
end
