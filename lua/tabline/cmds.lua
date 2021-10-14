local commands
local s = require'tabline.setup'.settings
local g = require'tabline.setup'.tabline
local h = require'tabline.helpers'

local CU = vim.api.nvim_replace_termcodes('<C-U>', true, false, true)
local Esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)

local fn = vim.fn

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
  elseif bang and banged[subcmd] then
    banged[subcmd](bang, args)
  else
    commands[subcmd](args)
  end
end

-------------------------------------------------------------------------------
-- Command completion
-------------------------------------------------------------------------------

local subcmds = {
  'mode', 'info', 'next', 'prev', 'filtering', 'close',
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

local function select_tab(cnt) -- {{{1
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

local function next_tab(args) -- {{{1
  local cnt, last = unpack(args)
  local max = #g.current_buffers
  if last then
    vim.cmd('buffer ' .. g.current_buffers[max])
    return
  end
  local cur = index(g.current_buffers, fn.bufnr()) or 1
  local target = (cur - 1 + (cnt or 1)) % max + 1
  vim.cmd('buffer ' .. g.current_buffers[target])
end

local function prev_tab(args) -- {{{1
  local cnt, first = unpack(args)
  if first then
    vim.cmd('buffer ' .. g.current_buffers[1])
    return
  end
  local max = #g.current_buffers
  local cur = index(g.current_buffers, fn.bufnr()) or 0
  local target = cur - (cnt or 1)
  while target <= 0 do
    target = target + max
  end
  vim.cmd('buffer ' .. g.current_buffers[target])
end

local function change_mode(mode) -- {{{1
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

local function toggle_filtering(bang, args) -- {{{1
  if bang then
    s.filtering = not s.filtering
  else
    s.filtering = #args == 0 or args[1] ~= 'off'
  end
  vim.cmd('redraw! | echo "buffer filtering turned ' .. (s.filtering and 'on' or 'off') .. '"')
end

local function close() -- {{{1
  local cur, alt, bufs = fn.bufnr(), fn.bufnr('#'), g.current_buffers
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
  if fn.getbufvar(cur, '&buftype') == 'nofile' then
    vim.cmd('silent! bwipe ' .. cur)
  elseif fn.getbufvar(cur, '&modified') == 0 then
    vim.cmd('bdelete ' .. cur)
  else
    vim.cmd('echo "Modified buffer has been hidden"')
  end
end

local function info() -- {{{1
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
}

banged = {
  ['filtering'] = toggle_filtering,
}

return {
  command = command,
  complete = complete,
  change_mode = change_mode,
  select_tab = select_tab,
}
