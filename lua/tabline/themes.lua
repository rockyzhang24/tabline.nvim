local M = {}

M.themes = {}
M.available = { 'default', 'apprentice' }

function M.apply(theme)
  local icons = require'tabline.render.icons'
  icons.normalbg = theme.normalbg
  icons.dimfg = theme.dimfg
  theme.normalbg = nil
  theme.dimfg = nil
  for k, v in pairs(theme) do
    if v[2] then
      vim.cmd(string.format('hi! link %s %s', k, v[1]))
    else
      vim.cmd(string.format('hi %s %s', k, v[1]))
    end
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
