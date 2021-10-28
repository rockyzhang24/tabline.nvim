local fn = vim.fn
local o = vim.o
local g = require'tabline.setup'.global
local s = require'tabline.setup'.settings
local h = require'tabline.helpers'
local find = string.find

local M, last = { closed = {} }, {}, nil

-------------------------------------------------------------------------------
-- Tab initializer
-------------------------------------------------------------------------------

local function new(page)  -- {{{1
  return { ['name'] = false }
end

--}}}

function M.init_tabs()
  for i = 1, fn.tabpagenr('$') do
    local t = fn.gettabvar(i, 'tab', nil)
    if t == vim.NIL then
      fn.settabvar(i, 'tab', new(i))
    end
  end
end

function M.get_tab(tnr)
  local t = tnr or fn.tabpagenr()
  local tab = fn.gettabvar(t, 'tab', false)
  if tab then
    return tab
  end
  fn.settabvar(t, 'tab', new(t))
  return fn.gettabvar(t, 'tab')
end

function M.new_tab(tnr)
  local t = tnr or fn.tabpagenr()
  fn.settabvar(t, 'tab', new(t))
  return fn.gettabvar(t, 'tab')
end

function M.store()
  local ldir = h.localdir()
  last = {
    buf = fn.bufnr(),
    cmd = ldir == 1 and 'tcd' or ldir == 2 and 'lcd' or 'cd',
    wd = fn.getcwd(),
    name = vim.t.tab.name or '',
  }
end

function M.save()
  if last then table.insert(M.closed, last) end
end

function M.reopen(ix)
  if #M.closed == 0 then return end
  local tab = table.remove(M.closed, ix or #M.closed)
  local cmd = 'b ' .. tab.buf
  if fn.bufexists(tab.buf) == 0 then
    cmd = 'bnext'
  end
  vim.cmd('tabnew +set\\ bufhidden=wipe')
  vim.cmd(cmd)
  vim.cmd(tab.cmd .. ' ' .. tab.wd)
end

return M
