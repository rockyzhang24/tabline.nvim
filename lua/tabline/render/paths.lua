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

function M.short_bufname(bnr)
  local name = fnamemodify(bufname(bnr), ':~:.')
  if not strfind(name, '/') then
    return name
  end
  local path = substitute(name, '\\v%((\\.?[^/])[^/]*)?/(\\.?[^/])[^/]*', '\\1/\\2', 'g')
  local _,_,root = strfind(path, '(.*/)')
  return root .. fnamemodify(name, ':t')
end

function M.short_cwd(tnr)
  local wd = fnamemodify(getcwd(tabpagewinnr(tnr), tnr), ':~')
  if not strfind(wd, '/') then
    return wd
  end
  local path = substitute(wd, '\\v%((\\.?[^/])[^/]*)?/(\\.?[^/])[^/]*', '\\1/\\2', 'g')
  return strsub(path, 1, #path - 1) .. fnamemodify(wd, ':t')
end

return M
