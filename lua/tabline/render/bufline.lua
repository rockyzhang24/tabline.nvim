local o = vim.o
local g = require'tabline.setup'.tabline
local v = g.v
local s = require'tabline.setup'.settings
local i = s.indicators

local bufnr = vim.fn.bufnr
local bufname = vim.fn.bufname
local getbufvar = vim.fn.getbufvar
local fnamemodify = vim.fn.fnamemodify
local winbufnr = vim.fn.winbufnr
local tabpagebuflist = vim.fn.tabpagebuflist
local tabpagenr = vim.fn.tabpagenr
local filereadable = vim.fn.filereadable
local argv = vim.fn.argv
local printf = string.format
local index = table.index

local get_bufs = require'tabline.bufs'.get_bufs
local short_bufname = require'tabline.render.paths'.short_bufname
local devicon = require'tabline.render.icons'.devicon

local buf_path, buf_icon, buf_label, buf_mod, format_buffer_labels
local render_buffers, render_args, limit_buffers

-------------------------------------------------------------------------------
-- Bufferline mode
-------------------------------------------------------------------------------

function render_buffers()
  local all = g.buffers
  local bufs, special, other = get_bufs(), {}, {}

  for _, b in ipairs(tabpagebuflist(tabpagenr())) do
    if all[b] then
      if all[b].special then
        special[b] = true
      elseif not index(bufs, b) then
        other[b] = true
      end
    end
  end
  return format_buffer_labels(limit_buffers(bufs), special, other)
end

-------------------------------------------------------------------------------
-- Arglist mode
-------------------------------------------------------------------------------

function render_args()
  local bufs = table.filter(
    table.map(argv(), function(k,v) return bufnr(v) end),
    function(k,v) return v > 0 end)
  if #bufs == 0 then  -- if arglist is empty, switch to buffer mode {{{1
    v.mode = table.filternew(
      s.modes, function(k,v) return v ~= 'args' end)[1] or 'tabs'
    return render_buffers() -- }}}
  else
    return format_buffer_labels(limit_buffers(bufs))
  end
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
      bufs = table.slice(bufs, start, stop)
    else
      bufs = table.slice(bufs, 1, limit)
    end
  end
  return bufs
end

function format_buffer_labels(bufs, special, other) -- {{{1
  local curbuf, tabs, all = winbufnr(0), {}, g.buffers
  local oth, spc, pin = other or {}, special or {}, g.pinned or {}

  for b, _ in pairs(oth) do table.insert(bufs, 1, b) end
  for b, _ in pairs(pin) do table.insert(bufs, 1, b) end
  for b, _ in pairs(spc) do table.insert(bufs, 1, b) end

  for _, b in ipairs(bufs) do
    local iscur = curbuf == b
    local modified = getbufvar(b, '&modified') > 0

    local buf = {
      nr = b,
      n = index(bufs, b),
      name = all[b].name or buf_path(b),
      hi = (iscur and spc[b])  and 'Special' or
           iscur               and 'Select' or
           (spc[b] or pin[b])  and 'Extra' or
           oth[b]              and 'Visible' or 'Hidden'
    }

    buf.himod = spc[b] and buf.hi or buf.hi .. 'Mod'
    buf.label = buf_label(buf, buf_mod(buf, modified))

    if iscur then center = b end

    table.insert(tabs, buf)
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


function buf_icon(b, hi, selected)  -- {{{1
  if b.icon then
    return b.icon .. ' '
  else
    local devicon = devicon(b, hi, selected)
    if devicon then
      b.icon = devicon
      return devicon .. ' '
    end
  end
  return ''
end

function buf_label(b, mod)  -- {{{1
  local curbuf = winbufnr(0) == b.nr

  local hi = printf(' %%#T%s# ', b.hi)
  local icon = buf_icon(b, b.hi, curbuf)
  local bn   = s.actual_buffer_number and b.nr or b.n
  local number = curbuf and ("%#TNumSel# " .. bn) or ("%#TNum# " .. bn)

  return number .. hi .. icon .. b.name .. ' ' .. mod
end

function buf_mod(b, modified) -- {{{1
  local mod = g.pinned[b.nr] and i.pinned or ''
  if modified then
    mod = mod .. printf('%%#T%s#%s', b.himod, i.modified)
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
