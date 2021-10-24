local commands
local s = require'tabline.setup'.settings
local g = require'tabline.setup'.global
local v = require'tabline.setup'.variables
local h = require'tabline.helpers'
local devicons = require'nvim-web-devicons'
local get_bufs = require'tabline.bufs'.get_bufs
local set_order = require'tabline.bufs'.set_order
local themes = require'tabline.themes'

local CU = vim.api.nvim_replace_termcodes('<C-U>', true, false, true)
local Esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)

local fn = vim.fn

-- vim functions {{{1
local getbufvar = vim.fn.getbufvar
local bufnr = vim.fn.bufnr
local getcwd = vim.fn.getcwd

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

local function command(arg)
  local subcmd, bang, args = nil, false, {}
  for w in string.gmatch(arg, '(%w+!?)') do
    if not subcmd then
      subcmd = w
      if string.find(w, '!', #w, true) then
        bang = true
        subcmd = string.sub(subcmd, 1, #subcmd - 1)
      end
    else
      insert(args, w)
    end
  end
  if not commands[subcmd] and not banged[subcmd] then
    print('Invalid subcommand: ' .. subcmd)
  elseif banged[subcmd] then
    banged[subcmd](bang, args)
  else
    commands[subcmd](args)
  end
end

-------------------------------------------------------------------------------
-- Command completion
-------------------------------------------------------------------------------

local subcmds = { -- {{{1
  'mode', 'info', 'next', 'prev', 'filtering', 'close', 'pin',
  'bufname', 'tabname', 'buficon', 'tabicon', 'bufreset', 'tabreset',
  'reopen', 'resetall', 'purge', 'cleanup', 'fullpath',
  'away', 'left', 'right', 'theme',
}

local completion = {  -- {{{1
  ['mode'] = { 'next', 'auto', 'tabs', 'buffers', 'args' },
  ['filtering'] = { 'on', 'off' },
  ['fullpath'] = { 'on', 'off' },
  ['theme'] = themes.available,
}

local function complete(a, c, p)  -- {{{1
  vim.cmd('redraw!')
  local subcmd, arg
  cmdline = string.sub(c, #s.main_cmd_name + 2)
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

local function select_tab(cnt, cmdline) -- Select tab {{{1
  if cnt == 0 then return '' end
  local bufs, b = g.current_buffers, nil
  if h.tabs_mode() then
    return 'gt'
  elseif v.mode == 'args' and not h.empty_arglist() then
    b = bufs[math.min(cnt, #fn.argv())]
  elseif s.bufline_style == 'bufnr' then
    b = cnt + 1
  else
    b = bufs[math.min(cnt, #bufs)]
  end
  if cmdline then
    vim.cmd('buffer ' .. b)
  else
    return string.format(':%ssilent! buffer %s\n', CU, b)
  end
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

local function move_left(arg) -- Move current tab N positions to the left {{{1
  local cnt = tonumber(arg[1]) or 1
  if h.tabs_mode() then
    local n = fn.tabpagenr()
    if n == 1 then
      return
    elseif cnt >= n then
      vim.cmd('0tabmove')
    else
      vim.cmd('-' .. cnt .. 'tabmove')
    end
  elseif h.buffers_mode() then
    local bufs = get_bufs()
    local nbufs, cur = #bufs, index(bufs, bufnr())
    if not cur or nbufs < 2 then return end
    local new = cur - cnt
    while new < 1 do
      new = new + nbufs
    end
    insert(bufs, new, remove(bufs, cur))
    set_order(bufs)
    vim.cmd('redrawtabline')
    select_tab(new, true)
  end
end

local function move_right(arg) -- Move current tab N positions to the right {{{1
  local cnt = tonumber(arg[1]) or 1
  if h.tabs_mode() then
    if fn.tabpagenr() + cnt >= fn.tabpagenr('$') then
      vim.cmd('$tabmove')
    else
      vim.cmd('+' .. cnt .. 'tabmove')
    end
  elseif h.buffers_mode() then
    local bufs = get_bufs()
    local nbufs, cur = #bufs, index(bufs, bufnr())
    if not cur or nbufs < 2 then return end
    local new = cur + cnt
    while new > nbufs do
      new = new - nbufs
    end
    insert(bufs, new, remove(bufs, cur))
    set_order(bufs)
    vim.cmd('redrawtabline')
    select_tab(new, true)
  end
end

local function away(arg) -- Move tab to last position {{{1
  local nr = #arg > 0 and arg[1] or nil
  if h.tabs_mode() then
    if nr then
      vim.cmd('normal! ' .. nr .. 'gt')
      vim.cmd('$tabmove')
      vim.cmd('normal! ' .. nr .. 'gt')
    else
      local cur = fn.tabpagenr()
      vim.cmd('$tabmove')
      vim.cmd('normal! ' .. cur .. 'gt')
    end
  elseif h.buffers_mode() then
    local bufs = get_bufs()
    local cur = nr or index(bufs, bufnr())
    if #bufs then
      insert(bufs, remove(bufs, cur))
      set_order(bufs)
    end
    vim.cmd('redrawtabline')
    if cur then
      select_tab(cur, true)
    end
  end
end

local function change_mode(arg) -- Change mode {{{1
  local mode = arg[1]
  if index({ 'auto', 'tabs', 'buffers', 'args' }, mode) then
    v.mode = mode
  elseif mode == 'next' then
    local cur = index(s.modes, v.mode)
    if not cur then
      v.mode = s.modes[1]
    else
      v.mode = s.modes[(cur % #s.modes) + 1]
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

local function fullpath(bang, args) -- Show full path in labels {{{1
  if bang then
    s.show_full_path = not s.show_full_path
  else
    s.show_full_path = #args == 0 or args[1] ~= 'off'
  end
  vim.cmd('redrawtabline')
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
  vim.cmd('redrawtabline')
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
  vim.cmd('redrawtabline')
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
  vim.cmd('redrawtabline')
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
  vim.cmd('redrawtabline')
end

local function reset_buffer() -- Reset buffer {{{1
  local buf = g.buffers[bufnr()]
  if not buf then return end
  buf = require'tabline.bufs'.add_buf(bufnr())
  vim.cmd('redrawtabline')
end

local function reset_tab() -- Reset tab {{{1
  vim.t.tab = { ['name'] = false }
  vim.cmd('redrawtabline')
end

local function reset_all() -- Reset all tabs and buffers {{{1
  for i = 1, fn.tabpagenr('$') do
    fn.settabvar(i, 'tab', require'tabline.tabs'.new_tab(i))
  end
  require'tabline.bufs'.init_bufs()
end

local function pin_buffer(bang) -- Pin buffer {{{1
  local b = g.buffers[bufnr()]
  if not b then return end
  if bang then
    b.pinned = not b.pinned
  else
    b.pinned = true
  end
  vim.cmd('redrawtabline')
end

local function reopen() -- Reopen {{{1
  require'tabline.tabs'.reopen()
end

local function purge(wipe) -- Purge {{{1
  local purged, cmd = {}, wipe and 'bwipe' or 'bdelete'

  for _, buf in ipairs(fn.tabpagebuflist(fn.tabpagenr())) do
    local unlisted = fn.buflisted(buf) == 0
    local noma     = fn.getbufvar(buf, "&modifiable") == 0
    local nofile   = fn.getbufvar(buf, "&buftype") ~= '' and fn.getbufvar(buf, "&modified") == 0

    if unlisted or noma or nofile then
      insert(purged, buf)
    end
  end

  if #fn.tabpagebuflist() == 1 and tbl.index(purged, fn.bufnr()) then
    return
  end

  for _, buf in ipairs(purged) do
    vim.cmd(buf .. cmd)
  end
end

local function cleanup(bang) -- Clean up {{{1
  local del, err = 0, 0
  if bang then
    del, err = h.delete_bufs_without_wins()
  else
    del, err = h.delete_buffers_out_of_valid_wds()
  end
  print('Cleaned up ' .. del .. ' buffers.')
  if err > 0 then
    print(err .. ' buffers not removed because of errors (modified?)')
  end
end

local function info(bang) -- Info {{{1
  if not bang then
    print('--- TABLES ---')
    print('mode: ' .. v.mode)
    print('valid: ' .. vim.inspect(g.valid))
    print('recent: ' .. vim.inspect(s.filtering and g.recent[getcwd()] or g.recent.unfiltered))
    print('order: ' .. vim.inspect(s.filtering and g.order[getcwd()] or g.order.unfiltered))
  else
    print('--- BUFFERS ---')
    for k, v in pairs(g.buffers) do
      print(string.format('%s   %s', v.nr, vim.inspect(v)))
    end
  end
end

local function testspeed() -- Test speed {{{1
  local fn = vim.fn
  local time = fn.reltime()
  for i = 1, 1000 do
    vim.cmd('redrawtabline')
  end
  print(
    fn.matchstr(
      fn.reltimestr(fn.reltime(time)), '.*\\..\\{,3}')
      .. ' seconds to redraw 1000 times'
    )
end

local function config() -- Configuration buffer {{{1
  vim.fn['tabline#config']()
end

local function theme(arg) -- Set theme {{{1
  s.theme = arg[1]
  if not index(themes.available, s.theme) then
    print('Theme not available')
  else
    require'tabline.setup'.load_theme(true)
  end
end

-- }}}


-------------------------------------------------------------------------------

commands = {  -- {{{1
  ['mode'] = change_mode,
  ['next'] = next_tab,
  ['prev'] = prev_tab,
  ['away'] = away,
  ['left'] = move_left,
  ['right'] = move_right,
  ['close'] = close,
  ['bufreset'] = reset_buffer,
  ['tabreset'] = reset_tab,
  ['reopen'] = reopen,
  ['resetall'] = reset_all,
  ['testspeed'] = testspeed,
  ['config'] = config,
  ['theme'] = theme,
}

banged = {  -- {{{1
  ['filtering'] = toggle_filtering,
  ['bufname'] = name_buffer,
  ['tabname'] = name_tab,
  ['buficon'] = icon_buffer,
  ['tabicon'] = icon_tab,
  ['info'] = info,
  ['pin'] = pin_buffer,
  ['cleanup'] = cleanup,
  ['purge'] = purge,
  ['fullpath'] = fullpath,
}

-- }}}

return {
  command = command,
  complete = complete,
  change_mode = change_mode,
  select_tab = select_tab,
  away = away,
}
