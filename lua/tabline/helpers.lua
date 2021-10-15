local g = require'tabline.setup'.tabline
local v = g.v
local s = require'tabline.setup'.settings

-- vim functions {{{1
local argv = vim.fn.argv
local tabpagenr = vim.fn.tabpagenr
local getcwd = vim.fn.getcwd
local haslocaldir = vim.fn.haslocaldir
--}}}

local M = {}

--------------------------------------------------------------------------------
-- Generic helpers
--------------------------------------------------------------------------------

function M.tabs_mode()
  return v.mode == 'tabs' or v.mode == 'auto' and tabpagenr('$') > 1
end

function M.empty_arglist()
  return #argv() == 0
end

function M.localdir()
  if haslocaldir() > 0 then
    return 2
  elseif haslocaldir(-1, 0) > 0 then
    return 1
  else
    return nil
  end
end



return M
