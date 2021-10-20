local g = require'tabline.setup'.tabline
local s = require'tabline.setup'.settings
local h = require'tabline.helpers'

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
  ['GV']        = { name = 'GV', icon = s.icons.git },
  ['gitcommit'] = { name = 'Commit', icon = s.icons.git },
  ['magit']     = { name = 'Magit', icon = s.icons.git },
  ['git']       = { name = 'Git', icon = s.icons.git },
  ['fugitive']  = { name = 'Status', icon = s.icons.git },
  ['netrw']     = { name = 'Netrw', icon = s.icons.disk, doubleicon = true },
  ['dirvish']   = { name = 'Dirvish', icon = s.icons.disk, doubleicon = true },
  ['startify']  = { name = 'Startify', icon = s.icons.flag2, doubleicon = true },
  ['ctrlsf']    = { name = 'CtrlSF', icon = s.icons.lens, doubleicon = true },
}

--------------------------------------------------------------------------------
-- Function: new_buf
--
-- Create a new buffer entry. 'name' is displayed instead of 'path' if present.
--
-- @param bnr: the buffer number
-- @return: a basic buffer object
--------------------------------------------------------------------------------
local function new_buf(bnr)
  return {
    nr = bnr,
    path = fnamemodify(bufname(bnr), ':p'),
    basename = fnamemodify(bufname(bnr), ':t'),
    ext = fnamemodify(bufname(bnr), ':e'),
    special = false,
    pinned = false,
    name = nil,
    icon = nil,
    doubleicon = nil,
  }
end

--------------------------------------------------------------------------------
-- Function: special_or_listed
--
-- @param bnr: the buffer number
-- @return: a buffer object, if the buffer is either a regular listed buffer, or
--          a special buffer, otherwise nil
--------------------------------------------------------------------------------
local function special_or_listed(bnr)
  local ft, buf = getbufvar(bnr, '&filetype'), new_buf(bnr)

  if ft == 'help' and getbufvar(bnr, '&modifiable') == 0 then
    buf.name = 'HELP'
    buf.icon = s.icons.book
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
end


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
  g.buffers[bnr] = nil
  local buf = special_or_listed(bnr)
  if buf then
    g.buffers[bnr] = buf
  end
end

function M.get_bufs()
  local ix, tbl, wd = 1, {}, getcwd()
  for nr, b in pairs(g.buffers) do
    if not b.special and validbuf(b.path, wd) then
      tbl[ix] = nr
      ix = ix + 1
    end
  end
  return tbl
end

return M
