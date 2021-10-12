local M = {}

-------------------------------------------------------------------------------
-- Icons
-------------------------------------------------------------------------------

M.icons = {}
local printf = string.format

local fn = vim.fn
local tabpagebuflist = fn.tabpagebuflist
local tabpagewinnr = fn.tabpagewinnr
local tabpagenr = fn.tabpagenr

local tab_buffer = function(tnr) return tabpagebuflist(tnr)[tabpagewinnr(tnr)] end

local g = require'tabline.setup'.tabline
local s = require'tabline.setup'.settings
local devicons = require'nvim-web-devicons'

local function make_icons_hi(color)
  local col, ret = string.sub(color, 2), {}
  local groups = { 'Special', 'Select', 'Extra', 'Visible', 'Hidden' }
  for _, v in ipairs(groups) do
    local hi = vim.fn.execute('hi T' .. v)
    local _, _, link = string.find(hi, 'links to (%w+)')
    if link then
      hi = vim.fn.execute('hi ' .. link)
    end
    local _, _, bg = string.find(hi, 'guibg=#(%x+)')
    if bg then
      vim.cmd(printf('hi T%s%s guibg=#%s guifg=#%s', v, col, bg, col))
      ret[v] = printf('%%#T%s%s#___%%#T%s# ', v, col, v)
    end
  end
  return ret
end

function M.get_buf_icon(b, hi)  -- {{{1
  if b.icon then
    return b.icon .. ' '
  elseif devicons then
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
  return ''
end

-- }}}

-------------------------------------------------------------------------------
-- The icon for the tab label
--
-- @param tnr: the tab number
-- @param right_corner: if it's for the right corner
-- Return the icon
-------------------------------------------------------------------------------
function M.get_tab_icon(tnr, right_corner, hi)
  local T, icon = fn.gettabvar(tnr, 'tab'), nil
  if T.icon then
    return T.icon .. ' '
  end

  if right_corner then
    icon = s.icons.tab

  else
    local bnr  = tab_buffer(tnr)
    local B    = g.buffers[bnr]
    local buf  = {['nr'] = bnr, ['icon'] = B.icon, ['name'] = B.name}
    icon = M.get_buf_icon(buf, hi)
  end

  return not icon and '' or type(icon) == 'string' and icon .. ' ' or icon[tnr == tabpagenr() and 1 or 2] .. ' '
end


return M
