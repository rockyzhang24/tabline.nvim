local fn = vim.fn
local o = vim.o
local g = require'tabline.setup'.tabline
local s = require'tabline.setup'.settings
local h = require'tabline.helpers'
local find = string.find

local M, closed, last = {}, {}, nil

vim.cmd([[
au tabline TabNew * lua require'tabline.tabs'.init_tabs()
]])

-------------------------------------------------------------------------------
-- Tab initializer
-------------------------------------------------------------------------------

local function new_tab(page)  -- {{{1
  return { ['name'] = false }
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

function M.new_tab()
  local t = fn.tabpagenr()
  fn.settabvar(t, 'tab', new_tab(t))
  return vim.t.tab
end

function M.store()
  local ldir = h.localdir()
  last = {
    buf = fn.bufnr(),
    cmd = ldir == 1 and 'tcd' or ldir == 2 and 'lcd' or 'cd',
    wd = fn.getcwd()
  }
end

function M.save()
  if last then table.insert(closed, last) end
end

function M.reopen()
  if #closed == 0 then return end
  local tab = table.remove(closed)
  local cmd = 'b ' .. tab.buf
  if fn.bufexists(tab.buf) == 0 then
    cmd = 'bnext'
  end
  vim.cmd('tabnew +set\\ bufhidden=wipe')
  vim.cmd(cmd)
  vim.cmd(tab.cmd .. ' ' .. tab.wd)
end

return M
