return {
  "danilshvalov/org-modern.nvim",
  dependencies = { "nvim-orgmode/orgmode" },
  -- このpluginにはsetup()がない。orgmode.luaのui.menu.handlerからmenu:new(config)を呼ぶ。
  -- menu config: border、title、title_pos、relative、style、row、col、width、height。
  -- いずれもnvim_open_win()へ渡すfloating-window設定で、通常は既定値のままでよい。
}
