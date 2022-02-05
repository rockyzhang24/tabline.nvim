local g = require'tabline.setup'.global
local v = require'tabline.setup'.variables
local s = require'tabline.setup'.settings

-- vim functions {{{1
local fn = vim.fn
local argv = vim.fn.argv
local tabpagenr = vim.fn.tabpagenr
local tabpagebuflist = vim.fn.tabpagebuflist
local haslocaldir = vim.fn.haslocaldir
--}}}

local find = string.find

local M = {}

-------------------------------------------------------------------------------
-- Local functions
-------------------------------------------------------------------------------

local function bdelete(bnr) -- try to delete buffer {{{1
  vim.v.errmsg = ''
  vim.cmd('silent! bdelete ' .. bnr)
  return vim.v.errmsg == ''
end
-- }}}

--------------------------------------------------------------------------------
-- Generic helpers
--------------------------------------------------------------------------------

function M.get_hi_color(hi, typ, fallback) -- {{{1
  local color = fn.synIDattr(fn.synIDtrans(fn.hlID(hi)), typ)
  return color == '' and fallback or color
end

function M.tabs_mode() -- {{{1
  return v.mode == 'tabs' or v.mode == 'auto' and tabpagenr('$') > 1
end

function M.buffers_mode() -- {{{1
  return v.mode == 'buffers' or v.mode == 'auto' and tabpagenr('$') == 1
end

function M.empty_arglist() -- {{{1
  return #argv() == 0
end

function M.localdir() -- {{{1
  if haslocaldir() > 0 then
    return 2
  elseif haslocaldir(-1, 0) > 0 then
    return 1
  else
    return nil
  end
end

function M.has_win(bnr, tnr) -- {{{1
  return tabpagebuflist(tnr or tabpagenr())[bnr]
end

function M.tabbufs(tnr) -- {{{1
  return tabpagebuflist(tnr or tabpagenr())
end

function M.validbuf(b, wd)  -- {{{1
  return b and ( not s.filtering or find(b, wd, 1, true) )
end

function M.delete_bufs_without_wins() -- {{{1
  local cnt, bufs = 0, {}
  for tnr = 1, tabpagenr('$') do
    for _, bnr in ipairs(tabpagebuflist(tnr)) do
      bufs[bnr] = true
    end
  end
  for bnr = 1, fn.bufnr('$') do
    if not bufs[bnr] then
      cnt = cnt + ( bdelete(bnr) and 1 or 0 )
    end
  end
  return cnt
end

function M.delete_buffers_out_of_valid_wds() -- {{{1
  local cnt, wds, bufs = 0, {}, {}
  for tnr = 1, tabpagenr('$') do
    wds[fn.getcwd(-1, tnr)] = true
    for win = 1, fn.tabpagewinnr(tnr, '$') do
      wds[fn.getcwd(win, tnr)] = true
    end
  end
  for n, b in pairs(g.buffers) do
    for wd, _ in pairs(wds) do
      if not bufs[n] then
        bufs[n] = M.validbuf(b.path, wd)
      end
    end
    if not bufs[n] then
      cnt = cnt + ( bdelete(n) and 1 or 0 )
    end
  end
  return cnt
end

--}}}

return M
