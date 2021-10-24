local h = require'tabline.helpers'

local M = {}

M.themes = {}
M.available = { 'default', 'apprentice' }

function M.apply(theme)
  for k, v in pairs(theme) do
    vim.cmd(string.format('hi! ' .. v, k))
  end
end

function M.add(theme)
  if not theme.name then
    print('Error adding tabline theme: theme doesn\'t have a name')
    return
  end
  M.themes[theme.name] = theme
  table.insert(M.available, theme.name)
end

return M
