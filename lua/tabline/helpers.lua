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

--}}}

return M
