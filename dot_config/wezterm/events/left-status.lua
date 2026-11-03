local wezterm = require('wezterm')
local Cells = require('utils.cells')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick --[[ '' ]]
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[ '' ]]
local GLYPH_KEY_TABLE = nf.md_table_key --[[ '󱏅' ]]
local GLYPH_KEY = nf.md_key --[[ '󰌆' ]]
local GLYPH_FOLDER = '📁'

-- アクティブペインのカレントディレクトリとして表示する最大文字数
-- （これを超える場合は末尾のディレクトリを優先して先頭を … で省略する）
local MAX_CWD_LEN = 36

---@type table<string, Cells.SegmentColors>
local colors = {
   default = { bg = '#fab387', fg = '#1c1b19' },
   scircle = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#fab387' },
   cwd = { bg = '#89b4fa', fg = '#1c1b19' },
   cwd_scircle = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#89b4fa' },
}

local cells = Cells:new()

cells
   :add_segment(
      'cwd_scircle_left',
      GLYPH_SEMI_CIRCLE_LEFT,
      colors.cwd_scircle,
      attr(attr.intensity('Bold'))
   )
   :add_segment('cwd_icon', ' ' .. GLYPH_FOLDER .. ' ', colors.cwd, attr(attr.intensity('Bold')))
   :add_segment('cwd_text', '', colors.cwd, attr(attr.intensity('Bold')))
   :add_segment(
      'cwd_scircle_right',
      GLYPH_SEMI_CIRCLE_RIGHT,
      colors.cwd_scircle,
      attr(attr.intensity('Bold'))
   )
   :add_segment(1, GLYPH_SEMI_CIRCLE_LEFT, colors.scircle, attr(attr.intensity('Bold')))
   :add_segment(2, ' ', colors.default, attr(attr.intensity('Bold')))
   :add_segment(3, ' ', colors.default, attr(attr.intensity('Bold')))
   :add_segment(4, GLYPH_SEMI_CIRCLE_RIGHT, colors.scircle, attr(attr.intensity('Bold')))

---ホームディレクトリを `~` に置き換え、長すぎる場合は末尾のディレクトリを
---優先して先頭を `…` で省略する（パスの途中でぶつ切りにしない）
---@param path string
---@param max_len number
local function shorten_path(path, max_len)
   path = path:gsub('\\', '/')

   local home = wezterm.home_dir and wezterm.home_dir:gsub('\\', '/')
   if home and path:sub(1, #home) == home then
      path = '~' .. path:sub(#home + 1)
   end

   if path:len() <= max_len then
      return path
   end

   local parts = {}
   for part in path:gmatch('[^/]+') do
      table.insert(parts, part)
   end

   local result = parts[#parts] or path
   for i = #parts - 1, 1, -1 do
      local candidate = parts[i] .. '/' .. result
      if candidate:len() + 2 > max_len then
         break
      end
      result = candidate
   end

   return '…/' .. result
end

M.setup = function()
   wezterm.on('update-right-status', function(window, pane)
      local cwd_text = ''
      local cwd_url = pane and pane:get_current_working_dir()
      if cwd_url then
         cwd_text = shorten_path(cwd_url.file_path, MAX_CWD_LEN)
      end
      cells:update_segment_text('cwd_text', cwd_text)

      local res = { 'cwd_scircle_left', 'cwd_icon', 'cwd_text', 'cwd_scircle_right' }

      local name = window:active_key_table()
      if name then
         cells:update_segment_text(2, GLYPH_KEY_TABLE):update_segment_text(3, ' ' .. string.upper(name))
         for _, id in ipairs({ 1, 2, 3, 4 }) do
            table.insert(res, id)
         end
      elseif window:leader_is_active() then
         cells:update_segment_text(2, GLYPH_KEY):update_segment_text(3, ' ')
         for _, id in ipairs({ 1, 2, 3, 4 }) do
            table.insert(res, id)
         end
      end

      window:set_left_status(wezterm.format(cells:render(res)))
   end)
end

return M
