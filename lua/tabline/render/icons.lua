local M = { icons = {}, normalbg = nil }

-------------------------------------------------------------------------------
-- Icons
-------------------------------------------------------------------------------

local printf = string.format

local g = require'tabline.setup'.global
local s = require'tabline.setup'.settings
local h = require'tabline.helpers'

-- Load devicons and add custom icons {{{1
local ok, icons = pcall(require, 'nvim-web-devicons')
if not ok then
  icons = nil
else
  icons = icons.get_icons()
  icons.fzf = { icon = "🗲", color = "#d0bf41", cterm_color = "185", name = 'fzf' }
  icons.python = { icon = "", color = "#3572A5", cterm_color = "67", name = 'python' }
  icons.default = { icon = "", color = "#6d8086", cterm_color = "66", name = "default" }
end
--}}}

local function make_icons_hi(gcol, tcol)
  local ret, tgc = {}, vim.o.termguicolors
  local gui = tgc and 'gui' or 'cterm'
  local groups = { 'Special', 'Select', 'Extra', 'Visible', 'Hidden' }
  if not M.normalbg then
    M.normalbg = h.get_hi_color('Normal', 'bg', tgc and '#000000' or 0)
  end
  if not M.normalfg then
    M.normalfg = h.get_hi_color('Normal', 'fg', tgc and '#bcbcbc' or 250)
  end
  for _, v in ipairs(groups) do
    local bg = h.get_hi_color('T' .. v, 'bg', M.normalbg)
    local c = tgc and gcol:sub(2) or tcol or require'tabline.term256'.hex2term(gcol:sub(2))
    vim.cmd(printf('hi T%s%s %sbg=%s %sfg=%s', v, c, gui, bg, gui, tgc and gcol or c))
    ret[v] = {}
    ret[v].sel = printf('%%#T%s%s#___%%#T%s#', v, c, v)
    ret[v].dim = printf('%%#T%sDim#___%%#T%s#', v, v)
    ret[v].ncl = printf('%%#T%s#___%%#T%s#', v, v)
  end
  return ret
end

local function get_icon(name, ext)
  local i = icons[name] or icons[ext] or icons.default
  i.cterm_color = i.cterm_color or '250'
  return i
end

function M.devicon(b, selected)  -- {{{1
  if icons then
    local buf = g.buffers[b.nr]
    if not buf.basename then
      return ''
    end
    local icon = get_icon(buf.basename, buf.ext)
    if icon then
      if not M.icons[icon.color] then
        M.icons[icon.color] = make_icons_hi(
          -- increase contrast for some colors
          icon.color:gsub('#56', '#a6'), icon.cterm_color:gsub('^60$', '126'))
      end
      local hi = M.icons[icon.color][b.hi]
      local typ = selected and (not s.colored_icons and 'ncl' or 'sel') or 'dim'
      return hi and string.gsub(hi[typ], '___', icon.icon) or ''
    end
  end
  return nil
end

-- }}}

return M
