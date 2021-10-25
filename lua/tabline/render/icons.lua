local M = { icons = {}, normalbg = nil }

-------------------------------------------------------------------------------
-- Icons
-------------------------------------------------------------------------------

local printf = string.format

local g = require'tabline.setup'.global
local s = require'tabline.setup'.settings
local h = require'tabline.helpers'

-- Load devicons and add custom icons {{{1
local ok, devicons = pcall(require, 'nvim-web-devicons')
if not ok then
  devicons = nil
else
  devicons.set_icon({
    fzf = { icon = "🗲", color = "#d0bf41", name = 'fzf' },
    python = { icon = "", color = "#3572A5", name = 'python' },
  })
end
--}}}

local function make_icons_hi(color)
  local col, ret = string.sub(color, 2), {}
  local groups = { 'Special', 'Select', 'Extra', 'Visible', 'Hidden' }
  local gui = vim.o.termguicolors and 'gui' or 'cterm'
  if not M.normalbg then
    M.normalbg = h.get_hi_color('Normal', gui, 'bg', '000000')
  end
  if not M.normalfg then
    M.normalfg = h.get_hi_color('Normal', gui, 'fg', 'bcbcbc')
  end
  for _, v in ipairs(groups) do
    local bg = h.get_hi_color('T' .. v, gui, 'bg', M.normalbg)
    vim.cmd(printf('hi T%s%s %sbg=#%s %sfg=#%s', v, col, gui, bg, gui, col))
    ret[v] = {}
    ret[v].sel = printf('%%#T%s%s#___%%#T%s#', v, col, v)
    ret[v].dim = printf('%%#T%sDim#___%%#T%s#', v, v)
    ret[v].ncl = printf('%%#T%s#___%%#T%s#', v, v)
  end
  return ret
end


function M.devicon(b, selected)  -- {{{1
  if devicons then
    local buf = g.buffers[b.nr]
    if not buf.basename then
      return ''
    end
    local icon, color = devicons.get_icon_color(buf.devicon or buf.basename, buf.ext)
    if icon then
      if not M.icons[color] then
        M.icons[color] = make_icons_hi(color)
      end
      local hi = M.icons[color][b.hi]
      local typ = (selected or not s.dim_inactive_icons)
                  and (not s.colored_icons and 'ncl' or 'sel') or 'dim'
      -- TODO don't use string.gsub
      return hi and string.gsub(hi[typ], '___', icon) or ''
    end
  end
  return nil
end

-- }}}

return M
