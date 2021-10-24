local o = vim.o
local g = require'tabline.setup'.global
local v = require'tabline.setup'.variables
local s = require'tabline.setup'.settings
local i = require'tabline.setup'.indicators
local h = require'tabline.helpers'

-- vim functions {{{1
local bufnr = vim.fn.bufnr
local bufname = vim.fn.bufname
local getbufvar = vim.fn.getbufvar
local fnamemodify = vim.fn.fnamemodify
local winbufnr = vim.fn.winbufnr
local tabpagebuflist = vim.fn.tabpagebuflist
local tabpagenr = vim.fn.tabpagenr
local filereadable = vim.fn.filereadable
local argv = vim.fn.argv
local argc = vim.fn.argc

-- table functions {{{1
local tbl = require'tabline.table'
local remove = table.remove
local concat = table.concat
local insert = table.insert
local index = tbl.index
local filter = tbl.filter
local filternew = tbl.filternew
local slice = tbl.slice
local map = tbl.map
--}}}


local printf = string.format

local get_bufs = require'tabline.bufs'.get_bufs
local short_bufname = require'tabline.render.paths'.short_bufname
local devicon = require'tabline.render.icons'.devicon

local buf_path, buf_icon, buf_label, buf_mod, format_buffer_labels
local render_buffers, render_args, limit_buffers


-------------------------------------------------------------------------------
-- Bufferline mode
-------------------------------------------------------------------------------

function render_buffers()
  return format_buffer_labels(get_bufs())
end

-------------------------------------------------------------------------------
-- Arglist mode
-------------------------------------------------------------------------------

function render_args(render_tabs)
  if argc() == 0 then  -- if arglist is empty, switch mode {{{1
    v.mode = s.modes[(index(s.modes, 'args')) % #s.modes + 1]
    if h.tabs_mode() then
      return render_tabs()
    else
      return render_buffers()
    end
  end -- }}}
  local bufs = filter(
    map(argv(), function(k,v) return bufnr(v) end),
    function(k,v) return v > 0 end
  )
  bufs = limit_buffers(bufs)
  return format_buffer_labels(bufs)
end

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

-- limit the number of buffers to be rendered
function limit_buffers(bufs)
  local tot, limit = #bufs, math.floor(o.columns / 15)
  if tot > limit then
    local cur, mid = index(bufs, bufnr()), math.floor(limit / 2)
    if cur and cur > mid then
      local start, stop = cur - mid + 1, limit + cur - mid
      if stop > tot then
        start = start - (stop - tot)
        stop = tot
      end
      bufs = slice(bufs, start, stop)
    else
      bufs = slice(bufs, 1, limit)
    end
  end
  return bufs
end

function format_buffer_labels(bufs) -- {{{1
  local curbuf, tabs, all = winbufnr(0), {}, g.buffers
  local usebnr = s.bufline_style == 'bufnr'
  local pagebufs = tabpagebuflist(tabpagenr())

  if #bufs == 0 and next(all) then
    bufs = { all[bufnr()] and bufnr() or next(all).nr }
  end

  g.current_buffers = bufs

  for k, bnr in pairs(bufs) do
    local iscur = curbuf == bnr
    local b = all[bnr]
    local haswin = index(pagebufs, bnr)

    local buf = {
      nr = bnr,
      n = k,
      name = b.name or buf_path(bnr, not s.show_full_path),
      hi = (iscur and b.special)   and 'Special' or
           iscur                   and 'Select' or
           (b.special or b.pinned) and 'Extra' or
           haswin                  and 'Visible' or 'Hidden'
    }

    buf.himod = b.special and buf.hi or buf.hi .. 'Mod'
    buf.label = buf_label(buf, buf_mod(buf, usebnr))

    if iscur then center = bnr end

    insert(tabs, buf)
  end

  return center, tabs
end

function buf_path(bnr, basename) -- {{{1
  local bname = bufname(bnr)
  local minimal = basename or o.columns < 100 -- window is small
  local scratch = getbufvar(bnr, '&buftype') ~= ''

  if filereadable(bname) == 0 then           -- new files/scratch buffers
    return bname == '' and ( scratch and s.scratch_label or s.unnamed_label )
           or scratch and bname
           or minimal and fnamemodify(bname, ':t')
           or short_bufname(bnr)               -- shortened buffer path

  elseif minimal then
    return fnamemodify(bname, ':t')

  else
    return short_bufname(bnr)
  end
end


function buf_icon(b, selected)  -- {{{1
  if g.buffers[b.nr].icon then
    return g.buffers[b.nr].icon .. ' '
  else
    local devicon = devicon(b, selected)
    if devicon then
      b.icon = devicon
      return devicon .. ' '
    end
  end
  return ''
end

function buf_label(blabel, mod, usebnr)  -- {{{1
  local curbuf = winbufnr(0) == blabel.nr
  local icons = g.buffers[blabel.nr].doubleicon

  local hi = printf(' %%#T%s# ', blabel.hi)
  local icon = buf_icon(blabel, curbuf)
  local bn   = usebnr and blabel.nr or blabel.n
  local number = curbuf and ("%#TNumSel# " .. bn) or ("%#TNum# " .. bn)

  return icons
         and number .. hi .. icon .. ' ' .. blabel.name .. ' ' .. icon .. mod
         or  number .. hi .. icon .. blabel.name .. ' ' .. mod
end

function buf_mod(blabel, modified) -- {{{1
  local mod = g.buffers[blabel.nr].pinned and i.pinned .. ' ' or ''
  if modified then
    mod = mod .. printf('%%#T%s#%s', blabel.himod, i.modified .. ' ')
  end
  return mod
end

-- }}}



return {
  render_buffers = render_buffers,
  render_args = render_args,
  buf_icon = buf_icon,
  buf_path = buf_path,
}
