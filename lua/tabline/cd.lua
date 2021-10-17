local M = {}

local h = require'tabline.helpers'

local fn = vim.fn
local getcwd = vim.fn.getcwd
local locdir = vim.fn.haslocaldir

local roots = { -- {{{1
  git = '.git',
}

-- }}}

local function find_root() -- find root {{{1
  local dir, file
  for k, v in pairs(roots) do
    dir = fn.finddir(v, '.;')
    if dir ~= '' then
      return fn.fnamemodify(dir, ':p:h')
    end
    file = fn.findfile(v, ',;')
    if file ~= '' then
      return fn.fnamemodify(file, ':p:h')
    end
  end
  return nil
end

local function same_wd(typ, dir) -- is same directory and same type {{{1
  local haslcd, hastcd = locdir() == 1, locdir(-1, 0) == 1
  return typ == 'lcd' and haslcd and getcwd(0,0) == dir
      or typ == 'tcd' and hastcd and getcwd(-1,0) == dir
      or typ == 'cd'  and not haslcd and not hastcd and getcwd() == dir
end

local function verify_and_exec(typ, dst) -- verify choice {{{1
  vim.cmd('redraw!')
  local action

  if same_wd(typ, dst) then
    print('No difference')

  elseif typ == 'lcd' or typ == 'tcd' then
    -- explicitly asking to set a local working directory
    vim.cmd(typ .. ' ' .. dst)

  elseif locdir() == 1 and getcwd() == dst then
    -- same directory as current window-local directory, either keep or clear
    action = fn.confirm('Same as current window-local directory, keep it or clear it?', "&Keep\n&Clear")
    if action == 2 then
      vim.cmd('cd ' .. dst)
    end

  elseif locdir() == 1 then
    -- there is a window-local directory that would be overwritten, ask
    action = fn.confirm('Overwrite window-local directory ' .. getcwd() .. '?', "&Yes\n&Keep\n&Clear")
    if action == 1 then
      vim.cmd('lcd ' .. dst)
    elseif action == 3 then
      vim.cmd('cd ' .. dst)
    end

  elseif locdir(-1, 0) == 1 and getcwd(-1, 0) == dst then
    -- same directory as current tab-local directory, either keep or clear
    action = fn.confirm('Same as current tab-local directory, keep it or clear it?', "&Keep\n&Clear")
    if action == 2 then
      vim.cmd('cd ' .. dst)
    end

  elseif locdir(-1, 0) == 1 then
    -- there is a tab-local directory that would be overwritten, ask
    action = fn.confirm('Overwrite tab-local directory ' .. getcwd() .. '?', "&Yes\n&Keep\n&Clear")
    if action == 1 then
      vim.cmd('tcd ' .. dst)
    elseif action == 3 then
      vim.cmd('cd ' .. dst)
    end

  else
    -- no tab cwd, no local cwd: just cd
      vim.cmd('cd ' .. dst)
  end
end

local function input(dir, typ)  -- get directory from input {{{1
  vim.b._cdtype = typ % 3 + 1
  vim.cmd([[
  cnoremap <buffer><nowait><silent><expr> <C-j>
  \ "\<C-U>\e:call v:lua.require'tabline.cd'.set_dir(b:_cdtype + 1,".
  \  string(getcmdline()) .")\r"
  ]])
  local types = {'cd', 'tcd', 'lcd'}
  local cur = '[' .. types[vim.b._cdtype] .. '] '
  vim.cmd('redraw! | echohl Question')
  dst = fn.input(cur, dir and dir or find_root() or getcwd(), 'dir')
  vim.cmd('echohl None')
  vim.cmd('cunmap <buffer> <C-j>')
  return types[vim.b._cdtype], dst
end

-- }}}


function M.set_dir(typ, dir)
  local dst, newtype
  newtype, dst = input(dir, typ)
  if dst == '' then return end
  if fn.isdirectory(dst) == 0 then
    print('Invalid directory')
    return
  end
  verify_and_exec(newtype, dst)
end

function M.cdc()
  local dir = h.localdir()
  M.set_dir(dir and dir or 0, fn.expand('%:p:h'))
end

function M.cdl() M.set_dir(2) end
function M.cdt() M.set_dir(1) end
function M.cdw() M.set_dir(0) end

function M.info()
  local wdir, tdir = h.localdir() == 2, h.localdir() == 1
  local fmt, all, gitdir = "%-20s %s\n"

  -- working directory
  if wdir then
    all = string.format(fmt, 'Current local cwd:', getcwd(fn.winnr(), fn.tabpagenr()))
  elseif tdir then
    all = string.format(fmt, 'Current tab cwd:', getcwd(-1, 0))
  else
    all = string.format(fmt, 'Current cwd:', getcwd())
  end

  -- git dir
  if fn.exists('*FugitiveGitDir') > 0 then
    gitdir = fn.substitute(fn.FugitiveGitDir(), '/\\.git$', '', '')
  else
    gitdir = find_root() or ''
  end
  if gitdir ~= '' then
    all = all .. string.format("%-20s %s\n", 'Current git dir:', gitdir)
  end

  -- tag files
  if #fn.tagfiles() > 0 then
    all = all .. string.format("%-20s %s\n", 'Tag files:', fn.string(fn.tagfiles()))
  end

  print(all)
end

return M
