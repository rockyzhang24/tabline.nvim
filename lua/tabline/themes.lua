local h = require'tabline.helpers'

local index = require'tabline.table'.index

local M = {}

M.themes = {}
M.available = { 'default', 'apprentice' }

function M.apply(theme)
  local s = require'tabline.setup'.settings
  if M.restore_settings then
    for k, v in pairs(M.restore_settings) do
      s[k] = v
    end
    M.restore_settings = nil
  end
  M.current = theme
  local skip = {'name', 'settings'}
  for k, v in pairs(theme) do
    if not index(skip, k) then
      vim.cmd(string.format('hi! ' .. v, k))
    end
  end
  if theme.settings then
    M.restore_settings = {}
    for k, v in pairs(theme.settings) do
      M.restore_settings[k] = s[k]
      s[k] = v
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
