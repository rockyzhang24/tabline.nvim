local fn = vim.fn
local o = vim.o
local g = require'tabline.setup'.tabline
local s = require'tabline.setup'.settings
local find = string.find

local M = {}

vim.cmd([[
au tabline TabNew * lua require'tabline.tabs'.init_tabs()
]])

-------------------------------------------------------------------------------
-- Tab initializer
-------------------------------------------------------------------------------

local function new_tab(page)  -- {{{1
  return {}
end

--}}}

function M.init_tabs()
  for i = 1, fn.tabpagenr('$') do
    local t = fn.gettabvar(i, 'tab', nil)
    if t == vim.NIL then
      fn.settabvar(i, 'tab', new_tab(i))
    end
  end
end

return M
