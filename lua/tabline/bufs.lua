local g = require'tabline.setup'.global
local s = require'tabline.setup'.settings
local h = require'tabline.helpers'

local icons = require'tabline.setup'.icons

-- vim functions {{{1
local fnamemodify = vim.fn.fnamemodify
local bufname = vim.fn.bufname
local getbufvar = vim.fn.getbufvar
local buflisted = vim.fn.buflisted
local getcwd = vim.fn.getcwd
local tabpagebuflist = vim.fn.tabpagebuflist
local tabpagenr = vim.fn.tabpagenr
local bufnr = vim.fn.bufnr
--}}}

local strfind = string.find
local remove = table.remove
local insert = table.insert
local index = require'tabline.table'.index
local slice = require'tabline.table'.slice
local copy = require'tabline.table'.copy
local filter = require'tabline.table'.filter
local validbuf = h.validbuf

-------------------------------------------------------------------------------
-- Initialize buffers
--
-- Whenever a buffer is created, an entry to the global table is added. If it's
-- recognized as a (supported) special buffer, an icon and a name may be
-- assigned.
-------------------------------------------------------------------------------
local M = {}

local special_ft = {
  ['GV']        = { name = 'GV', icon = icons.git },
  ['gitcommit'] = { name = 'Commit', icon = icons.git },
  ['magit']     = { name = 'Magit', icon = icons.git },
  ['git']       = { name = 'Git', icon = icons.git },
  ['fugitive']  = { name = 'Status', icon = icons.git },
  ['netrw']     = { name = 'Netrw', icon = icons.disk, doubleicon = true },
  ['dirvish']   = { name = 'Dirvish', icon = icons.disk, doubleicon = true },
  ['startify']  = { name = 'Startify', icon = icons.flag2, doubleicon = true },
  ['ctrlsf']    = { name = 'CtrlSF', icon = icons.lens, doubleicon = true },
}

--------------------------------------------------------------------------------
-- Function: new_buf
--
-- Create a new buffer entry. 'name' is displayed instead of 'path' if present.
--
-- @param bnr: the buffer number
-- @return: a basic buffer object
--------------------------------------------------------------------------------
local function new_buf(bnr) -- {{{1
  local bname, ext, path, basename = bufname(bnr)
  if bname ~= '' then
    ext = fnamemodify(bname, ':e')
    if ext == '' then
      ext = getbufvar(bnr, '&filetype')
      if ext == '' then ext = nil end
    end
    path = fnamemodify(bname, ':p')
    basename = fnamemodify(bname, ':t')
  end
  return {
    nr = bnr,
    path = path,
    basename = basename,
    ext = ext,
    special = false,
    pinned = false,
    name = nil,
    icon = nil,
    doubleicon = nil,
    recent = 0,
  }
end -- }}}

--------------------------------------------------------------------------------
-- Function: special_or_listed
--
-- @param bnr: the buffer number
-- @return: a buffer object, if the buffer is either a regular listed buffer, or
--          a special buffer, otherwise nil
--------------------------------------------------------------------------------
local function special_or_listed(bnr) -- {{{1
  local ft, buf = getbufvar(bnr, '&filetype'), new_buf(bnr)

  if ft == 'help' and getbufvar(bnr, '&modifiable') == 0 then
    buf.name = 'HELP'
    buf.icon = icons.book
    buf.special = true

  elseif getbufvar(bnr, '&buftype') == 'terminal' then
    if string.find(buf.path, ';#FZF') then
      buf.name = 'FZF'
      buf.devicon = 'fzf'
      buf.doubleicon = true
    else
      local pid = string.match(buf.path, '//(%d+):')
      buf.name = 'TERMINAL' .. (pid and ' [' .. pid .. ']' or '')
    end
    buf.special = true

  elseif special_ft[ft] then
    buf.name = special_ft[ft].name
    buf.icon = special_ft[ft].icon
    buf.doubleicon = special_ft[ft].doubleicon
    buf.special = true
  end

  if buf.special or ( buflisted(bnr) > 0 and getbufvar(bnr, '&buftype') == '' ) then
    return buf
  end
end -- }}}


--------------------------------------------------------------------------------
-- Module functions
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Function: M.init_bufs
--
-- Initialize all buffers from scratch. Called on VimEnter or when the buffers
-- table must be rebuilt.
--------------------------------------------------------------------------------
function M.init_bufs()
  g.buffers = {}
  for i = 1, bufnr('$') do
    M.add_buf(i)
  end
end

--------------------------------------------------------------------------------
-- Function: M.add_buf
--
-- Whenever a buffer is created, an entry to the global table is added. If it's
-- recognized as a (supported) special buffer, an icon and a name may be
-- assigned. Can also be used to update a buffer entry: in fact, any previous
-- entry for the buffer is first removed, and it could happen that it isn't
-- added again, because the buffer isn't considered valid (unlisted and not
-- special). This can happen if a buffer was initially listed on BufAdd, but
-- then made unlisted.
--
-- @param bnr: the buffer number
--------------------------------------------------------------------------------
function M.add_buf(bnr)
  local buf = special_or_listed(bnr)
  if buf then
    g.buffers[bnr] = buf
  else
    g.buffers[bnr] = nil
  end
end

function M.add_file(file)
  M.add_buf(bufnr(file))
end

-------------------------------------------------------------------------------
-- Function: M.remove_buf
--
-- @param bnr: the buffer number
-------------------------------------------------------------------------------
function M.remove_buf(bnr)
  g.buffers[bnr] = nil
end

-------------------------------------------------------------------------------
-- Function: M.recent_buf
-- Update the recency counter for a buffer. Called on BufEnter.
--
-- @param bnr: the buffer number
-------------------------------------------------------------------------------
function M.recent_buf(bnr)
  if g.buffers[bnr] then
    g.buffers[bnr].recent = g.buffers[bnr].recent + 1
  end
end

-------------------------------------------------------------------------------
-- Function: M.get_bufs
--
-- @return: the ordered list of the buffers to render
-------------------------------------------------------------------------------
function M.get_bufs()
  g.valid, g.pinned = M.valid_bufs()
  if s.filtering then
    local cwd = getcwd()
    g.recent[cwd] = M.recent_bufs()
    g.order[cwd] = M.ordered_bufs(g.recent[cwd], cwd)
    return g.order[cwd]
  else
    g.recent.unfiltered = M.recent_bufs()
    g.order.unfiltered = M.ordered_bufs(g.recent.unfiltered)
    return g.order.unfiltered
  end
end

-------------------------------------------------------------------------------
-- Function: M.valid_bufs
--
-- @return: table with valid buffers numbers
-------------------------------------------------------------------------------
function M.valid_bufs()
  local valid, pinned, wd = {}, {}, getcwd()
  local pagebufs = tabpagebuflist(tabpagenr())
  for nr, b in pairs(g.buffers) do
    if b.pinned then
      insert(pinned, nr)
    elseif index(pagebufs, nr) then
      insert(valid, nr)
    elseif not b.special and validbuf(b.path, wd) then
      insert(valid, nr)
    end
  end
  return valid, pinned
end

-------------------------------------------------------------------------------
-- Function: M.recent_bufs
-- Table with most recently accessed buffers, limited in number by
-- s.max_recent. Includes also current buffer and any pinned buffer.
--
-- @return: either a slice of the valid buffers (a different table), or the
-- valid buffers table (same table).
-------------------------------------------------------------------------------
function M.recent_bufs()
  local recent, cur = copy(g.valid), bufnr()
  if #recent > s.max_recent then
    table.sort(recent, function(a,b) return g.buffers[a].recent > g.buffers[b].recent end)
    recent = slice(recent, 1, s.max_recent)
    table.sort(recent, function(a,b) return g.buffers[a].nr < g.buffers[b].nr end)
  end
  if g.buffers[cur] and not index(recent, cur) then
    insert(recent, cur)
  end
  for _, b in ipairs(g.pinned) do
    if not index(recent, b) then
      insert(recent, 1, b)
    end
  end
  return recent
end

-------------------------------------------------------------------------------
-- Function: M.ordered_bufs
-- Adjust the list of ordered buffers (the one that is actually rendered),
-- removing buffers that aren't valid anymore (not recent or deleted), and
-- adding new entries from the recent buffers list. Ordered lists are
-- remembered because stored in g.order, with keys equal to the cwd (if buffer
-- filtering is enabled) or inside g.order.unfiltered (if it's disabled).
-- This is done because otherwise every time the list of valid buffers would
-- change, old order would be mostly lost.
--
-- @return: the ordered buffers table
-------------------------------------------------------------------------------
function M.ordered_bufs(recent, cwd)
  local order = {}
  if cwd and g.order[cwd] then
    order = g.order[cwd]
  elseif not cwd then
    order = g.order.unfiltered
  end
  order = filter(order, function(k,v) return index(recent, v) end)
  for _, b in ipairs(recent) do
    if not index(order, b) then
      insert(order, b)
    end
  end
  return order
end

--------------------------------------------------------------------------------
-- Function: M.set_order
-- Replace the current list of ordered buffers with a new list.
--
-- @param bufs: table of buffer numbers
--------------------------------------------------------------------------------
function M.set_order(bufs)
  if s.filtering then
    g.order[getcwd()] = bufs
  else
    g.order.unfiltered = bufs
  end
  g.current_buffers = bufs
end

function M.click(nr, clicks, button, mod)
  local cmd = require'tabline.cmds'
  local n, cur = g.current_buffers[nr], bufnr()
  if button == 'r' then
    if string.find(mod, 's') then
      if getbufvar(n, '&modified') == 1 then
        print('Cannot delete, buffer is modified')
      else
        vim.cmd('bdelete ' .. n)
      end
    else
      cmd.away({nr})
      vim.cmd('buffer ' .. cur)
    end
  elseif button == 'l' then
    vim.cmd('buffer ' .. n)
  end
end

-- this is global, will be called by vimscript
buflineclick = M.click

return M
