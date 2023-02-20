--------------------------------------------------------------------------------
-- Description: buffer clean up functions
-- File:        cleanup.lua
-- Author:      Gianmaria Bajo <mg1979.git@gmail.com>
-- License:     MIT
-- Created:     mar 22 mar 2022, 10:54:31
--------------------------------------------------------------------------------

local M = {}

local g = require("tabline.setup").global
local h = require("tabline.helpers")

local fn = vim.fn
local tabpagebuflist = fn.tabpagebuflist
local tabpagenr = fn.tabpagenr
local getbufvar = fn.getbufvar
local filereadable = fn.filereadable
local buflisted = fn.buflisted
local bufexists = fn.bufexists
local bufloaded = fn.bufloaded
local getcwd = fn.getcwd
local argv = fn.argv
local winid = fn.win_getid
local bufname = fn.bufname
local index = require("tabline.table").index

local debug = function()
  return require("tabline.setup").settings.debug
end

-------------------------------------------------------------------------------
-- Local functions
-------------------------------------------------------------------------------

local function bdelete(bnr) -- try to delete buffer {{{1
  if debug() then
    return false
  end
  vim.cmd("silent! bdelete " .. bnr)
  return buflisted(bnr) == 0
end

local function bwipeout(bnr) -- try to wipeout buffer {{{1
  if debug() then
    return false
  end
  vim.cmd("silent! bwipeout " .. bnr)
  return bufexists(bnr) == 0
end

local function is_scratch(bnr) -- is scratch buffer {{{1
  local bt = getbufvar(bnr, "&buftype")
  return bt == "nofile" or bt == "acwrite" or bt == "help"
end

local function not_a_file(path) -- file not readable {{{1
  return filereadable(path) == 0
end

local function invalid_path(b, wds, args) -- path outside valid directories {{{1
  local invalid, reason = true, ""
  for _, f in ipairs(args) do
    if b.path == f then
      invalid, reason = false, "args"
      break
    end
  end
  if invalid then
    for wd, _ in pairs(wds) do
      if h.validbuf(b.path, wd) then
        invalid, reason = false, "wd"
        break
      end
    end
  end
  if debug() then
    print("invalid buf " .. b.path .. " =", invalid, reason)
  end
  return invalid
end

local function working_directories() -- working directories from open windows {{{1
  local wds = {}
  for tnr = 1, tabpagenr("$") do
    for win = 1, fn.tabpagewinnr(tnr, "$") do
      wds[getcwd(win, tnr)] = true
    end
  end
  if debug() then
    print("dirs = ", vim.inspect(wds))
  end
  return wds
end

local function arglists() -- arglists for open windows {{{1
  local args = argv()
  for tnr = 1, tabpagenr("$") do
    for win = 1, fn.tabpagewinnr(tnr, "$") do
      local argw = argv(-1, winid(win, tnr))
      for _, f in ipairs(argw) do
        if not index(args, f) then
          table.insert(args, f)
        end
      end
    end
  end
  args = fn.map(args, "fnamemodify(v:val, ':p')")
  if debug() then
    print("args = ", vim.inspect(args))
  end
  return args
end

local function bufs_with_wins() -- buffers in open windows {{{1
  local bufs = {}
  for tnr = 1, tabpagenr("$") do
    for _, bnr in ipairs(tabpagebuflist(tnr)) do
      bufs[bnr] = true
    end
  end
  return bufs
end

-- }}}

--------------------------------------------------------------------------------
-- Module functions
--------------------------------------------------------------------------------

--- Delete all buffers without a window in any tabpage.
---@return number deleted buffers
function M.without_window()
  local cnt = 0
  local has_win = bufs_with_wins()
  for bnr = 1, fn.bufnr("$") do
    if bufexists(bnr) == 1 and not has_win[bnr] then
      cnt = cnt + (bdelete(bnr) and 1 or 0)
    end
  end
  return cnt
end

--- Delete listed buffers that don't belong to any arglist or whose path isn't
--- within any of the working directories of any of the open windows.
--- Never delete buffers shown in any window.
---@return number deleted buffers
function M.outside_valid_wds(wipe)
  local cnt, wpd = 0, 0
  local wds = working_directories()
  local args = arglists()
  local has_win = bufs_with_wins()
  for n, b in pairs(g.buffers) do
    if not has_win[n] and buflisted(n) == 1 and getbufvar(n, "&modified") == 0 then
      if is_scratch(n) or not_a_file(b.path) or invalid_path(b, wds, args) then
        cnt = cnt + (bdelete(n) and 1 or 0)
      end
    end
  end
  if wipe then
    for n = 1, fn.bufnr("$") do
      if
        bufexists(n) == 1
        and buflisted(n) == 0
        and not has_win[n]
        and (is_scratch(n) or not_a_file(bufname(n)))
      then
        wpd = wpd + (bwipeout(n) and 1 or 0)
      end
    end
  end
  return cnt + wpd, wpd
end

return M
