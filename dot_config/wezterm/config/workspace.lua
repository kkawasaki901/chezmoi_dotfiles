local wezterm = require('wezterm')
local mux = wezterm.mux
local M = {}

function M.setup()
   wezterm.on('gui-startup', function()
      -- 各 workspace は分割せず、単一ペインの窓として起動する
      for _, name in ipairs({ 'ws1-single', 'ws1-2pane', 'ws2-ide', 'ws3-dashboard' }) do
         mux.spawn_window({
            workspace = name,
         })
      end

      mux.set_active_workspace('ws1-single')
   end)
end

return M
