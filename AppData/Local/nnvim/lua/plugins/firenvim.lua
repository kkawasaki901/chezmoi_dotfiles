-- Lazy.nvim plugin spec for firenvim (use Neovim inside the browser).
--
-- Setup:
-- 1. :Lazy sync (build step registers the native messaging host)
-- 2. Install the Firenvim extension in Firefox
-- 3. Restart Firefox

return {
  {
    "glacambre/firenvim",
    -- Only load eagerly when Neovim was started by the browser.
    lazy = not vim.g.started_by_firenvim,
    module = false,
    build = ":call firenvim#install(0)",
  },
}
