local M = {}
local files, generation = {}, 0
function M.encode(s)
  return (s:gsub('[%% #%?()%[%]<>"]', function(c) return string.format("%%%02X", c:byte()) end))
end
function M.relative(target, source)
  local a = vim.split(vim.fs.normalize(target), "/", { plain = true })
  local b = vim.split(vim.fs.dirname(vim.fs.normalize(source)), "/", { plain = true })
  local i = 1
  while a[i] and b[i] and a[i]:lower() == b[i]:lower() do i = i + 1 end
  if i == 1 then return nil end
  local out = {}
  for _ = i, #b do out[#out + 1] = ".." end
  for j = i, #a do out[#out + 1] = a[j] end
  return M.encode(table.concat(out, "/"))
end
function M.refresh()
  generation = generation + 1
  local token, root = generation, vim.fn.getcwd()
  files = {}
  vim.system({ "rg", "--files", "-g", "*.md", "-g", "*.markdown" }, { cwd = root, text = true },
    vim.schedule_wrap(function(result)
      if token ~= generation then return end
      if result.code > 1 then return vim.notify("Markdown index: " .. (result.stderr or ""), vim.log.levels.WARN) end
      for line in (result.stdout or ""):gmatch("[^\r\n]+") do files[#files + 1] = vim.fs.normalize(root .. "/" .. line) end
      table.sort(files)
    end))
end
function M.suggest()
  if vim.bo.filetype ~= "markdown" or vim.fn.mode() ~= "i" or vim.fn.pumvisible() == 1 then return end
  local source = vim.api.nvim_buf_get_name(0)
  if source == "" then return end
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local prefix = vim.api.nvim_get_current_line():sub(1, col):match("%[[^%]]*%]%(([^%s%)]*)$")
  if not prefix or prefix:find("[:#]") then return end
  local matches = {}
  for _, path in ipairs(files) do
    local relative = M.relative(path, source)
    if path ~= vim.fs.normalize(source) and relative and relative:lower():find(prefix:lower(), 1, true) then
      matches[#matches + 1] = { word = relative, menu = "[md]", dup = 0 }
      if #matches >= 100 then break end
    end
  end
  if #matches > 0 then vim.fn.complete(col - #prefix + 1, matches) end
end
function M.setup()
  local group = vim.api.nvim_create_augroup("MarkdownLinks", { clear = true })
  vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, { group = group, callback = M.refresh })
  vim.api.nvim_create_autocmd("BufWritePost", { group = group, pattern = { "*.md", "*.markdown" }, callback = M.refresh })
  vim.api.nvim_create_autocmd("TextChangedI", { group = group, callback = M.suggest })
  vim.api.nvim_create_user_command("MarkdownLinksRefresh", M.refresh, {})
end
return M
