local g = require'tabline.setup'.tabline
local v = g.v
local s = require'tabline.setup'.settings

-- vim functions {{{1
local argv = vim.fn.argv
local tabpagenr = vim.fn.tabpagenr
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




return M
