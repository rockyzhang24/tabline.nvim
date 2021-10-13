local M = { ['icons'] = {}, ['normalbg'] = nil }

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
    ret[v] = printf('%%#T%s%s#___%%#T%s# ', v, col, v)
  end
  return ret
end


function M.devicon(b, hi)  -- {{{1
  if devicons then
    local buf = g.buffers[b.nr]
    local icon, color = devicons.get_icon_color(buf.basename, buf.ext)
    if icon then
      if not M.icons[color] then
        M.icons[color] = make_icons_hi(color)
      end
      local hi = M.icons[color][hi]
      return hi and string.gsub(hi, '___', icon) or ''
    end
  end
  return nil
end

-- }}}

return M
