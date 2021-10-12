local fn = vim.fn
local g = require'tabline.setup'.tabline
local s = require'tabline.setup'.settings
local fnamemodify = fn.fnamemodify
local bufname = fn.bufname
local getbufvar = fn.getbufvar
local buflisted = fn.buflisted
local getcwd = fn.getcwd
local strfind = string.find

vim.cmd([[
au tabline BufAdd * lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
au tabline BufUnload * lua require'tabline.setup'.tabline.buffers[tonumber(vim.fn.expand('<abuf>'))] = nil
au tabline OptionSet buf lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
au tabline FileType * lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
]])

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
  ['netrw']     = { name = 'Netrw', icons = s.icons.disk },
  ['dirvish']   = { name = 'Dirvish', icons = s.icons.disk },
  ['startify']  = { name = 'Startify', icons = s.icons.flag2 },
  ['ctrlsf']    = { name = 'CtrlSF', icons = s.icons.lens },
}

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function has_win(bnr) -- {{{1
  return fn.tabpagebuflist(fn.tabpagenr())[bnr]
end

local function winbufs() -- {{{1
  return fn.tabpagebuflist(fn.tabpagenr())
end

local function validbuf(b, wd)  -- {{{1
  return b.special and has_win(b.nr) or strfind(b.path, wd)
end

-- }}}

--------------------------------------------------------------------------------
-- Function: new_buf
--
-- Create a new buffer entry. The difference between 'icon' and 'icons' is that
-- 'icons' will display the icon on both sides of the buffer name.
-- 'name' is displayed instead of 'path' if present.
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
    icons = nil,
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

  if ft == 'help' and not getbufvar(bnr, '&modifiable') then
    buf.name = 'HELP'
    buf.icon = s.icons.book
    buf.special = true

  elseif special_ft[ft] then
    buf.name = special_ft[ft].name
    buf.icon = special_ft[ft].icon
    buf.icons = special_ft[ft].icons
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
  for i = 1, fn.bufnr('$') do
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

-- function M.recent_bufs() -- {{{1
--   local tbl = self.buffers.recent or table.copy(self.buffers.order)
--   if #tbl > v.max_bufs then
--     return table.slice(tbl, 1, v.max_bufs)
--   else
--     return tbl
--   end
-- end

function M.get_bufs()
  local ix, tbl, wd, all = 1, {}, getcwd(), not s.filtering
  for nr, b in pairs(g.buffers) do
    if (all or validbuf(b, wd)) and not b.special then
      tbl[ix] = nr
      ix = ix + 1
    end
  end
  return tbl
end

return M
