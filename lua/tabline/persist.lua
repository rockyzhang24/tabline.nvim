local fn = vim.fn
local g = require('tabline.setup').global

local M = {}

--- Generate line with the global variable assignment.
local function info2var(data)
  return string.format("let g:Tnv_persist = '%s'", data)
end

--- Check if obsession is loaded and running.
---@return bool
local function obsession()
  return vim.g.this_obsession and vim.g.loaded_obsession
end

--- Enable or disable persistence with obsession.
--- If saved is nil, persistence is disabled if previously enabled.
---@param saved string|nil
local function obsession_update(saved)
  local ob = vim.g.obsession_append
  if ob and type(ob) == 'table' then
    for i, v in ipairs(ob) do
      if v:find('^let g:Tnv_persist') then
        table.remove(ob, i)
        break
      end
    end
    if saved then
      table.insert(ob, info2var(saved))
    end
    vim.g.obsession_append = ob
  elseif saved then
    vim.g.obsession_append = { info2var(saved) }
  end
  vim.cmd('silent Obsession ' .. fn.fnameescape(vim.g.this_obsession))
end

--- Restore values from persistence table.
function M.restore_persistence()
  if vim.g.Tnv_persist then
    local saved = load(vim.g.Tnv_persist)()
    for path, v in pairs(saved.bufs) do
      for _, buf in pairs(g.buffers) do
        if buf.path == path then
          buf.pinned = v.p
          buf.icon = v.i
          buf.name = v.n
          buf.custom = v.c
          break
        end
      end
    end
    for i, tab in ipairs(saved.tabs) do
      local t = fn.gettabvar(i, 'tab', false)
      if t then
        t.name = tab.name
        t.icon = tab.icon
        fn.settabvar(i, 'tab', t)
      end
    end
    g.persist = vim.v.this_session
  else
    -- the loaded session has persistence disabled, reset it
    g.persist = nil
  end
end

--- Update the session file so that customizations persist.
function M.update_persistence()
  if vim.v.this_session == '' or vim.v.this_session ~= g.persist then
    g.persist = nil
    return
  end
  local saved = { bufs = {}, tabs = {} }
  for _, buf in pairs(g.buffers) do
    if buf.custom or buf.pinned then
      saved.bufs[buf.path] = {
        p = buf.pinned,
        i = buf.icon,
        n = buf.name,
        c = buf.custom,
      }
    end
    for i = 1, fn.tabpagenr('$') do
      local tab = fn.gettabvar(i, 'tab')
      saved.tabs[i] = { name = tab.name, icon = tab.icon }
    end
  end
  saved = 'return ' .. vim.inspect(saved):gsub('%s+', '')
  if obsession() then
    obsession_update(saved)
  else
    vim.g.Tnv_persist = saved
    vim.cmd('mksession! ' .. fn.fnameescape(vim.v.this_session))
    vim.g.Tnv_persist = nil
  end
end

--- Revert changes to session file.
function M.remove_persistence()
  if vim.v.this_session == '' then
    return
  elseif obsession() then
    obsession_update()
    return
  else
    vim.g.Tnv_persist = nil
    vim.cmd('mksession! ' .. fn.fnameescape(vim.v.this_session))
  end
end

--- Disable persistence and revert changes to session file.
function M.disable_persistence()
  g.persist = nil
  M.remove_persistence()
end

return M
