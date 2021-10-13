local commands
local s = require'tabline.setup'.settings
local g = require'tabline.setup'.tabline
local index = table.index

-------------------------------------------------------------------------------
-- Main command
-------------------------------------------------------------------------------

local function command(arg)
  local subcmd, args = nil, {}
  for w in string.gmatch(arg, '(%w+)') do
    if not subcmd then
      subcmd = w
    else
      table.insert(args, w)
    end
  end
  if not commands[subcmd] then
    print('Invalid subcommand: ' .. subcmd)
  else
    commands[subcmd](args)
  end
end

-------------------------------------------------------------------------------
-- Command completion
-------------------------------------------------------------------------------

local subcmds = {
  'mode', 'info'
}

local completion = {
  ['mode'] = { 'next', 'auto', 'tabs', 'buffers', 'args' }
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
    return table.filternew(completion[subcmd],
                           function(k,v) return string.find(v, '^' .. arg) end)
  elseif subcmd and completion[subcmd] then
    return completion[subcmd]
  elseif subcmd then
    return table.filternew(subcmds,
                           function(k,v) return string.find(v, '^' .. subcmd) end)
  else
    return subcmds
  end
end

-- }}}

-------------------------------------------------------------------------------
-- Subcommands
-------------------------------------------------------------------------------

local function change_mode(mode) -- {{{1
  local modes = { 'auto', 'tabs', 'buffers', 'args' }
  if table.index(modes, mode[1]) then
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
}

return {
  command = command,
  complete = complete,
  change_mode = change_mode,
}
