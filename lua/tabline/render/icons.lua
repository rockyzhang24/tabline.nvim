local M = { ['icons'] = {}, ['normalbg'] = nil, ['dimfg'] = nil }

-------------------------------------------------------------------------------
-- Icons
-------------------------------------------------------------------------------

local printf = string.format
local execute = vim.fn.execute

local g = require'tabline.setup'.tabline
local s = require'tabline.setup'.settings
local devicons = require'nvim-web-devicons'



local function make_icons_hi(color)
  local col, ret = string.sub(color, 2), {}
  local groups = { 'Special', 'Select', 'Extra', 'Visible', 'Hidden' }
  for _, v in ipairs(groups) do
    local hi = execute('hi T' .. v)
    local _, _, link = string.find(hi, 'links to (%w+)')
    if link then
      hi = execute('hi ' .. link)
    end
    local _, _, bg = string.find(hi, 'guibg=#(%x+)')
    if not bg then
      bg = M.normalbg
    end
    vim.cmd(printf('hi T%s%s guibg=#%s guifg=#%s', v, col, bg, col))
    vim.cmd(printf('hi T%sDim guibg=#%s guifg=#%s', v, bg, M.dimfg))
    ret[v] = {}
    ret[v].sel = printf('%%#T%s%s#___%%#T%s#', v, col, v)
    ret[v].dim = printf('%%#T%sDim#___%%#T%s#', v, v)
  end
  return ret
end


function M.devicon(b, hi, selected)  -- {{{1
  if devicons then
    local buf = g.buffers[b.nr]
    local icon, color = devicons.get_icon_color(buf.basename, buf.ext)
    if icon then
      if not M.icons[color] then
        M.icons[color] = make_icons_hi(color)
      end
      local hi = M.icons[color][hi]
      local typ = (selected or not s.dim_inactive_icons) and 'sel' or 'dim'
      return hi and string.gsub(hi[typ], '___', icon) or ''
    end
  end
  return nil
end

-- }}}

return M
