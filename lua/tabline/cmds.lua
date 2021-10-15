local commands
local s = require'tabline.setup'.settings
local g = require'tabline.setup'.tabline
local h = require'tabline.helpers'
local devicons = require'nvim-web-devicons'

local CU = vim.api.nvim_replace_termcodes('<C-U>', true, false, true)
local Esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)

local fn = vim.fn

-- vim functions {{{1
local getbufvar = vim.fn.getbufvar
local bufnr = vim.fn.bufnr

-- table functions {{{1
local tbl = require'tabline.table'
local remove = table.remove
local concat = table.concat
local insert = table.insert
local index = tbl.index
local filternew = tbl.filternew
--}}}

-------------------------------------------------------------------------------
-- Main command
-------------------------------------------------------------------------------

local function command(bang, arg)
  local subcmd, args = nil, {}
  for w in string.gmatch(arg, '(%w+)') do
    if not subcmd then
      subcmd = w
    else
      insert(args, w)
    end
  end
  if not commands[subcmd] and not banged[subcmd] then
    print('Invalid subcommand: ' .. subcmd)
  elseif banged[subcmd] then
    banged[subcmd](bang == 1, args)
  else
    commands[subcmd](args)
  end
end

-------------------------------------------------------------------------------
-- Command completion
-------------------------------------------------------------------------------

local subcmds = {
  'mode', 'info', 'next', 'prev', 'filtering', 'close', 'pin',
  'bufname', 'tabname', 'buficon', 'tabicon', 'bufreset', 'tabreset',
  'reopen', 'resetall'
}

local completion = {
  ['mode'] = { 'next', 'auto', 'tabs', 'buffers', 'args' },
  ['filtering'] = { 'on', 'off' },
}

local function complete(a, c, p)  -- {{{1
  vim.cmd('redraw!')
  local subcmd, arg
  cmdline = string.sub(c, 9)
  -- print(string.format('"%s"', cmdline))
  for w in string.gmatch(cmdline, '(%w+)') do
    if not subcmd then
      subcmd = w
    elseif not arg then
      arg = w
    else
      return {}
    end
  end
  local res
  if arg and completion[subcmd] then
    return filternew(completion[subcmd],
                           function(k,v) return string.find(v, '^' .. arg) end)
  elseif subcmd and completion[subcmd] then
    return completion[subcmd]
  elseif subcmd then
    return filternew(subcmds,
                           function(k,v) return string.find(v, '^' .. subcmd) end)
  else
    return subcmds
  end
end

-- }}}

-------------------------------------------------------------------------------
-- Subcommands
-------------------------------------------------------------------------------

local function select_tab(cnt) -- Select tab {{{1
  if cnt == 0 then return '' end
  local b
  if h.tabs_mode() then
    return 'gt'
  elseif g.v.mode == 'args' and not h.empty_arglist() then
    b = bufs[math.min(cnt, #fn.argv())]
  elseif s.actual_buffer_number then
    b = cnt + 1
  else
    b = g.current_buffers[math.min(cnt, #g.current_buffers)]
  end
  return string.format(':%ssilent! buffer %s\n', CU, b)
end

local function next_tab(args) -- Next tab {{{1
  local cnt, last = unpack(args)
  local max = #g.current_buffers
  if last then
    vim.cmd('buffer ' .. g.current_buffers[max])
    return
  end
  local cur = index(g.current_buffers, bufnr()) or 1
  local target = (cur - 1 + (cnt or 1)) % max + 1
  vim.cmd('buffer ' .. g.current_buffers[target])
end

local function prev_tab(args) -- Prev tab {{{1
  local cnt, first = unpack(args)
  if first then
    vim.cmd('buffer ' .. g.current_buffers[1])
    return
  end
  local max = #g.current_buffers
  local cur = index(g.current_buffers, bufnr()) or 0
  local target = cur - (cnt or 1)
  while target <= 0 do
    target = target + max
  end
  vim.cmd('buffer ' .. g.current_buffers[target])
end

local function change_mode(mode) -- Change mode {{{1
  local modes = { 'auto', 'tabs', 'buffers', 'args' }
  if index(modes, mode[1]) then
    g.v.mode = mode[1]
  elseif mode[1] == 'next' then
    local cur = index(s.modes, g.v.mode)
    if not cur then
      g.v.mode = s.modes[1]
    else
      g.v.mode = s.modes[(cur % #s.modes) + 1]
    end
  end
  vim.cmd('redrawtabline')
end

local function toggle_filtering(bang, args) -- Toggle filtering {{{1
  if bang then
    s.filtering = not s.filtering
  else
    s.filtering = #args == 0 or args[1] ~= 'off'
  end
  vim.cmd('redraw! | echo "buffer filtering turned ' .. (s.filtering and 'on' or 'off') .. '"')
end

local function close() -- Close {{{1
  local cur, alt, bufs = bufnr(), bufnr('#'), g.current_buffers
  vim.o.hidden = true
  if alt ~= -1 and index(bufs, alt) then
    vim.cmd('buffer #')
  elseif #bufs > 1 or not index(bufs, cur) then
    next_tab({1})
  elseif alt > 0 then
    vim.cmd('buffer #')
  else
    vim.cmd('bnext')
  end
  if getbufvar(cur, '&buftype') == 'nofile' then
    vim.cmd('silent! bwipe ' .. cur)
  elseif getbufvar(cur, '&modified') == 0 then
    vim.cmd('bdelete ' .. cur)
  else
    vim.cmd('echo "Modified buffer has been hidden"')
  end
end

local function name_buffer(bang, args) -- Name buffer {{{1
  if ( #args == 0 and not bang ) or not g.buffers[bufnr()] then return end
  local buf = g.buffers[bufnr()]
  if bang then
    buf.name = nil
  else
    if getbufvar(bufnr(), '&buftype') ~= '' then
      buf.special = true
    end
    buf.name = args[1]
  end
  vim.cmd('redraw!')
end

local function icon_buffer(bang, args) -- Icon buffer {{{1
  if ( #args == 0 and not bang ) or not g.buffers[bufnr()] then return end
  local buf, icon = g.buffers[bufnr()], nil
  if bang then
    buf.icon = nil
  elseif s.icons[args[1]] then
    icon = s.icons[args[1]]
  else
    icon = devicons.get_icon(args[1])
    if not icon then return end
  end
  if getbufvar(bufnr(), '&buftype') ~= '' then
    buf.special = true
  end
  buf.icon = icon
  vim.cmd('redraw!')
end

local function name_tab(bang, args) -- Name tab {{{1
  if #args == 0 and not bang then return end
  local t = vim.t.tab
  if bang and not t.name then
    return
  elseif bang then
    t.name = false
  else
    t.name = args[1]
  end
  vim.t.tab = t
  vim.cmd('redraw!')
end

local function icon_tab(bang, args) -- Icon tab {{{1
  if #args == 0 and not bang then return end
  local t, icon = vim.t.tab, nil
  if bang and not t.icon then
    return
  elseif bang then
    icon = nil
  elseif s.icons[args[1]] then
    icon = s.icons[args[1]]
  else
    icon = devicons.get_icon(args[1])
    if not icon then return end
  end
  t.icon = icon
  vim.t.tab = t
  vim.cmd('redraw!')
end

local function reset_buffer() -- Reset buffer {{{1
  local buf = g.buffers[bufnr()]
  if not buf then return end
  buf = require'tabline.bufs'.add_buf(bufnr())
  vim.cmd('redraw!')
end

local function reset_tab() -- Reset tab {{{1
  vim.t.tab = { ['name'] = false }
  vim.cmd('redraw!')
end

local function reset_all() -- Reset all tabs and buffers {{{1
  for i = 1, fn.tabpagenr('$') do
    fn.settabvar(i, 'tab', require'tabline.tabs'.new_tab(i))
  end
  require'tabline.bufs'.init_bufs()
end

local function pin_buffer(bang) -- Pin buffer {{{1
  if bang then
    if index(g.pinned, bufnr()) then
      table.remove(g.pinned, bufnr())
    end
  elseif not index(g.pinned, bufnr()) then
    table.insert(g.pinned, bufnr())
  end
  vim.cmd('redraw!')
end

local function reopen() -- Reopen {{{1
  require'tabline.tabs'.reopen()
end

local function info() -- Info {{{1
  print('--- BUFFERS ---')
  for k, v in pairs(g.buffers) do
    print(string.format('%s   %s', v.nr, vim.inspect(v)))
  end
end


-- }}}


-------------------------------------------------------------------------------

commands = {
  ['mode'] = change_mode,
  ['info'] = info,
  ['next'] = next_tab,
  ['prev'] = prev_tab,
  ['close'] = close,
  ['bufreset'] = reset_buffer,
  ['tabreset'] = reset_tab,
  ['reopen'] = reopen,
  ['resetall'] = reset_all,
}

banged = {
  ['filtering'] = toggle_filtering,
  ['bufname'] = name_buffer,
  ['tabname'] = name_tab,
  ['buficon'] = icon_buffer,
  ['tabicon'] = icon_tab,
  ['pin'] = pin_buffer,
}

return {
  command = command,
  complete = complete,
  change_mode = change_mode,
  select_tab = select_tab,
}
