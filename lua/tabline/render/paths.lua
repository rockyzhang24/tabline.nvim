-- vim functions {{{1
local fn = vim.fn
local bufname = fn.bufname
local fnamemodify = fn.fnamemodify
local tabpagewinnr = fn.tabpagewinnr
local getcwd = fn.getcwd
--}}}

local strfind = string.find
local gsub = string.gsub

local M = {}

local pathpat = fn.has('win32') == 1 and '([/\\]?%.?[^/\\])[^/\\]-[/\\]'
  or '(/?%.?[^/])[^/]-/'

local slash = fn.has('win32') == 1 and '[/\\]' or '/'
local slashchar = fn.has('win32') == 1 and '\\' or '/'

function M.short_bufname(bnr)
  local name = fnamemodify(bufname(bnr), ':~:.')
  if not strfind(name, slash) then
    return name
  end
  return gsub(name, pathpat, '%1' .. slashchar)
end

function M.short_cwd(tnr)
  local wd = fnamemodify(getcwd(tabpagewinnr(tnr), tnr), ':~')
  if not strfind(wd, slash) then
    return wd
  end
  return gsub(wd, pathpat, '%1' .. slashchar)
end

return M
