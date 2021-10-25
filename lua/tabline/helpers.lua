local g = require'tabline.setup'.global
local v = require'tabline.setup'.variables
local s = require'tabline.setup'.settings

-- vim functions {{{1
local fn = vim.fn
local argv = vim.fn.argv
local tabpagenr = vim.fn.tabpagenr
local tabpagebuflist = vim.fn.tabpagebuflist
local getcwd = vim.fn.getcwd
local haslocaldir = vim.fn.haslocaldir
local execute = vim.fn.execute
--}}}

local find = string.find

local M = {}

--------------------------------------------------------------------------------
-- Generic helpers
--------------------------------------------------------------------------------

function M.get_hi_color(hi, gui, typ, fallback)
  local hi, col = execute('hi ' .. hi)
  local _, _, link = find(hi, 'links to (%w+)')
  if link then
    hi = execute('hi ' .. link)
  end
  if gui == 'gui' then
    _, _, col = find(hi, gui .. typ .. '=#(%x+)')
  else
    _, _, col = find(hi, gui .. typ .. '=(%d+)')
  end
  return col or fallback
end

function M.tabs_mode() -- {{{1
  return v.mode == 'tabs' or v.mode == 'auto' and tabpagenr('$') > 1
end

function M.buffers_mode() -- {{{1
  return v.mode == 'buffers' or v.mode == 'auto' and tabpagenr('$') == 1
end

function M.empty_arglist() -- {{{1
  return #argv() == 0
end

function M.localdir() -- {{{1
  if haslocaldir() > 0 then
    return 2
  elseif haslocaldir(-1, 0) > 0 then
    return 1
  else
    return nil
  end
end

function M.has_win(bnr, tnr) -- {{{1
  return tabpagebuflist(tnr or tabpagenr())[bnr]
end

function M.tabbufs(tnr) -- {{{1
  return tabpagebuflist(tnr or tabpagenr())
end

function M.validbuf(b, wd)  -- {{{1
  return b and ( not s.filtering or find(b, wd) )
end

function M.delete_bufs_without_wins() -- {{{1
  local cnt, err, bufs = 0, 0, {}
  for tnr = 1, tabpagenr('$') do
    for _, bnr in ipairs(tabpagebuflist(tnr)) do
      bufs[bnr] = true
    end
  end
  for bnr = 1, fn.bufnr('$') do
    if fn.buflisted(bnr) == 1 and not bufs[bnr] then
      vim.v.errmsg = ''
      vim.cmd('silent! bdelete ' .. bnr)
      cnt = cnt + ( vim.v.errmsg == '' and 1 or 0 )
      err = err + ( vim.v.errmsg == '' and 0 or 1 )
    end
  end
  return cnt, err
end

function M.delete_buffers_out_of_valid_wds() -- {{{1
  local cnt, err, wds, bufs = 0, 0, {}, {}
  for tnr = 1, tabpagenr('$') do
    wds[fn.getcwd(-1, tnr)] = true
    for win = 1, fn.tabpagewinnr(tnr, '$') do
      wds[fn.getcwd(win, tnr)] = true
    end
  end
  for bnr = 1, fn.bufnr('$') do
    for wd, _ in pairs(wds) do
      if M.validbuf(fn.expand('#' .. bnr .. ':p'), wd) then
        bufs[bnr] = true
      end
    end
  end
  for bnr = 1, fn.bufnr('$') do
    if fn.buflisted(bnr) == 1 and not bufs[bnr] then
      vim.v.errmsg = ''
      vim.cmd('silent! bdelete ' .. bnr)
      cnt = cnt + ( vim.v.errmsg == '' and 1 or 0 )
      err = err + ( vim.v.errmsg == '' and 0 or 1 )
    end
  end
  return cnt, err
end

--}}}

return M
