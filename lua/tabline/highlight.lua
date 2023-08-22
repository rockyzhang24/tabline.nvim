--------------------------------------------------------------------------------
-- Description: helpers for highlights generation
-- File:        highlight.lua
-- Author:      Gianmaria Bajo <mg1979.git@gmail.com>
-- License:     MIT
-- Created:     Sun Feb 19 22:02:13 2023
--------------------------------------------------------------------------------

local M = {}

-- Format string for html notation
local XFMT = '#%02x%02x%02x'
local NORMAL

-------------------------------------------------------------------------------
-- Highlight helpers
-------------------------------------------------------------------------------
local bit = require('bit')
local rs, ls, band = bit.rshift, bit.lshift, bit.band

--- Translate an rgb integer to the (r, g, b) notation.
---@param rgb number
---@return table
local function rgb2tbl(rgb)
  local r = rs(rgb, 16)
  local g = rs(ls(rgb, 16), 24)
  local b = band(rgb, 255)
  return { r = r, g = g, b = b }
end

local get_hl = vim.version().api_level > 10
    and function(group)
      return vim.api.nvim_get_hl(0, { name = group, link = true })
    end
  or function(group)
    return vim.api.nvim_get_hl_by_name(group, vim.o.termguicolors)
  end

--- Get the background for a highlight group.
---@param group string
---@return string|number
function M.get_bg(group)
  local t = get_hl(group)
  if t.link then
    return M.get_bg(t.link)
  end
  if not vim.o.termguicolors then
    return t.ctermbg or t.background or NORMAL
  end
  if not t.bg and not t.background then
    return NORMAL
  end
  local rgb = rgb2tbl(t.bg or t.background)
  return string.format(XFMT, rgb.r, rgb.g, rgb.b)
end

--- Reset Normal highlight definition.
function M.refresh()
  NORMAL = vim.o.termguicolors and '#000000' or 0 -- fallback value
  NORMAL = M.get_bg('Normal')
end
M.refresh()

return M
