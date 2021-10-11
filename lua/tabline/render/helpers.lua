local bufname = vim.fn.bufname
local fnamemodify = vim.fn.fnamemodify
local substitute = vim.fn.substitute
local getcwd = vim.fn.getcwd
local strsub = string.sub
local strfind = string.find

local g = require'tabline.setup'.tabline
local devicons = require'nvim-web-devicons'

local M = {}

function M.short_bufname(bnr)
  local name = bufname(bnr)
  if not strfind(name, '/') then
    return name
  end
  local path = substitute(name, '\\v%((\\.?[^/])[^/]*)?/(\\.?[^/])[^/]*', '\\1/\\2', 'g')
  return strsub(path, 1, #path - 1) .. fnamemodify(name, ':t')
end

function M.short_cwd(tnr)
  local wd = getcwd(-1, tnr)
  if not strfind(wd, '/') then
    return wd
  end
  local path = substitute(wd, '\\v%((\\.?[^/])[^/]*)?/(\\.?[^/])[^/]*', '\\1/\\2', 'g')
  return strsub(path, 1, #path - 1) .. fnamemodify(wd, ':t')
end

function M.get_buf_icon(b)  -- {{{1
  if b.icon then
    return b.icon .. ' '
  elseif devicons then
    local icon = devicons.get_icon(g.buffers[b.nr].path)
    return icon and icon .. ' ' or ''
  else
    return ''
  end
end

-- }}}

return M
