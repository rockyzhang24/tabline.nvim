-- vim functions {{{1
local bufname = vim.fn.bufname
local fnamemodify = vim.fn.fnamemodify
local substitute = vim.fn.substitute
local tabpagewinnr = vim.fn.tabpagewinnr
local getcwd = vim.fn.getcwd
--}}}

local strsub = string.sub
local strfind = string.find

local M = {}

local pathpat = vim.fn.has('win32') == 1 and '\\v%((\\.?[^\\/])[^\\/]*)?[\\/](\\.?[^\\/])[^\\/]*'
                                         or '\\v%((\\.?[^/])[^/]*)?/(\\.?[^/])[^/]*'

local slash = vim.fn.has('win32') == 1 and '\\' or '/'

function M.short_bufname(bnr)
  local name = fnamemodify(bufname(bnr), ':~:.')
  if not strfind(name, slash) then
    return name
  end
  local path = substitute(name, pathpat, '\\1/\\2', 'g')
  local _,_,root = strfind(path, '(.*[\\/])')
  return root .. fnamemodify(name, ':t')
end

function M.short_cwd(tnr)
  local wd = fnamemodify(getcwd(tabpagewinnr(tnr), tnr), ':~')
  if not strfind(wd, slash) then
    return wd
  end
  local path = substitute(wd, pathpat, '\\1/\\2', 'g')
  return strsub(path, 1, #path - 1) .. fnamemodify(wd, ':t')
end

return M
