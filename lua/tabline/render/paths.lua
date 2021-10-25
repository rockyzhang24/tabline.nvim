-- vim functions {{{1
local bufname = vim.fn.bufname
local fnamemodify = vim.fn.fnamemodify
local substitute = vim.fn.substitute
local tabpagewinnr = vim.fn.tabpagewinnr
local getcwd = vim.fn.getcwd
--}}}

local strsub = string.sub
local strfind = string.find
local gsub = string.gsub

local M = {}

local pathpat = vim.fn.has('win32') == 1 and '([/\\]?%.?[^/\\])[^/\\]-[/\\]'
                                         or '(/?%.?[^/])[^/]-/'

local slash = vim.fn.has('win32') == 1 and '[/\\]' or '/'
local slashchar = vim.fn.has('win32') == 1 and '\\' or '/'

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
