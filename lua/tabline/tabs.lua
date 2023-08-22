local fn = vim.fn
local h = require('tabline.helpers')

local M = { closed = {}, last = false }

-------------------------------------------------------------------------------
-- Tab initializer
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--- Initialize t:tab variable for all tabs.
function M.init_tabs()
  for i = 1, fn.tabpagenr('$') do
    local t = fn.gettabvar(i, 'tab', nil)
    if t == vim.NIL then
      fn.settabvar(i, 'tab', {})
    end
  end
end

-------------------------------------------------------------------------------
--- Get t:tab scoped variable. If not existing, set it to an empty table.
---@param tnr number|nil
---@return table
function M.get_tab(tnr)
  tnr = tnr or fn.tabpagenr()
  local tab = fn.gettabvar(tnr, 'tab', false)
  if tab then
    return tab
  end
  fn.settabvar(tnr, 'tab', {})
  return {}
end

-------------------------------------------------------------------------------
--- This is called on TabLeave, so that we save informations about the tab that
--- could be closed. It's not possible to save more than one buffer, because at
--- this point all windows in the tab have been closed, except one.
function M.store()
  local ldir = h.localdir()
  M.last = {
    buf = fn.bufnr(),
    cmd = ldir == 1 and 'tcd' or ldir == 2 and 'lcd' or 'cd',
    wd = fn.getcwd(),
    name = vim.t.tab.name,
    icon = vim.t.tab.icon,
  }
end

-------------------------------------------------------------------------------
--- This is called on TabClosed: we add the closed tab informations to the list
--- of closed tabs.
function M.save()
  if M.last then
    table.insert(M.closed, M.last)
    M.last = false
  end
end

-------------------------------------------------------------------------------
--- ":Tabline reopen" command.
---@param ix number: index in M.closed of tab to reopen
function M.reopen(ix)
  if #M.closed == 0 then
    return
  end
  local tab =
    table.remove(M.closed, ix and math.max(ix, #M.closed) or #M.closed)
  local cmd = fn.bufexists(tab.buf) == 1 and ('b ' .. tab.buf) or 'bnext'
  vim.cmd('tabnew +set\\ bufhidden=wipe')
  vim.cmd(cmd)
  vim.cmd(tab.cmd .. ' ' .. tab.wd)
  fn.settabvar(fn.tabpagenr(), 'tab', {
    name = tab.name,
    icon = tab.icon,
  })
end

-------------------------------------------------------------------------------
--- ":Tabline filter" command.
--- Set a filter for the bufferline, so that only buffers with paths that match
--- the filter are shown.
---@param filter string
---@param all bool
function M.set_filter(filter, all)
  local function _flt(tnr)
    local t = M.get_tab(tnr)
    t.filter = filter
    fn.settabvar(tnr or fn.tabpagenr(), 'tab', t)
  end
  if all then
    for i = 1, fn.tabpagenr('$') do
      _flt(i)
    end
  else
    _flt()
  end
end

return M
