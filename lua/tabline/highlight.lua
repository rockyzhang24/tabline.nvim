--------------------------------------------------------------------------------
-- Description: helpers for highlights generation
-- File:        highlight.lua
-- Author:      Gianmaria Bajo <mg1979.git@gmail.com>
-- License:     MIT
-- Created:     Sun Feb 19 22:02:13 2023
--------------------------------------------------------------------------------

local M = {}

-- Format string for html notation
local XFMT = "#%02x%02x%02x"
local NORMAL

-------------------------------------------------------------------------------
-- Highlight helpers
-------------------------------------------------------------------------------
local bit = require("bit")
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

--- Fill the highlight definition with additional information:
--- t.rgb_bg = background in (r, g, b) notation
--- t.rgb_fg = foreground in (r, g, b) notation
--- t.bg = background in #xxxxxx notation
--- t.fg = foreground in #xxxxxx notation
---@param group string
---@return table
if vim.version().api_level > 10 then
  function M.get_hl(group)
    if not vim.o.termguicolors then
      local t = vim.api.nvim_get_hl(0, { name = group, link = true })
      if t.link then
        return M.get_hl(t.link)
      elseif not t.ctermfg and not t.ctermbg then
        return NORMAL or { fg = 15, bg = 0 }
      end
      return { fg = t.ctermfg or NORMAL.fg or 15, bg = t.ctermbg or NORMAL.bg or 0 }
    end
    local t = vim.api.nvim_get_hl(0, { name = group, link = true })
    if t.link then
      return M.get_hl(t.link)
    elseif not t.fg and not t.bg then
      return NORMAL or {
        fg = "#FFFFFF",
        bg = "#000000",
        rgb_fg = { r = 255, g = 255, b = 255},
        rgb_bg = { r = 0, g = 0, b = 0},
      }
    end
    t.rgb_fg = t.fg and rgb2tbl(t.fg) or NORMAL.rgb_fg
    t.rgb_bg = t.bg and rgb2tbl(t.bg) or NORMAL.rgb_bg
    local f, b = t.rgb_fg, t.rgb_bg
    t.fg = f and string.format(XFMT, f.r, f.g, f.b) or NORMAL.fg
    t.bg = b and string.format(XFMT, b.r, b.g, b.b) or NORMAL.bg
    return t
  end
else
  function M.get_hl(group)
    if not vim.o.termguicolors then
      local t = vim.api.nvim_get_hl_by_name(group, false)
      return {
        fg = t.foreground or (NORMAL or {}).fg or 15,
        bg = t.background or (NORMAL or {}).bg or 0,
      }
    end
    local t = vim.api.nvim_get_hl_by_name(group, true)
    if not t.foreground and not t.background then
      return NORMAL or {
        fg = "#FFFFFF",
        bg = "#000000",
        rgb_fg = { r = 255, g = 255, b = 255},
        rgb_bg = { r = 0, g = 0, b = 0},
      }
    end
    t.rgb_fg = t.foreground and rgb2tbl(t.foreground) or NORMAL.rgb_fg
    t.rgb_bg = t.background and rgb2tbl(t.background) or NORMAL.rgb_bg
    local f, b = t.rgb_fg, t.rgb_bg
    t.fg = f and string.format(XFMT, f.r, f.g, f.b) or NORMAL.fg
    t.bg = b and string.format(XFMT, b.r, b.g, b.b) or NORMAL.bg
    return t
  end
end

--- Reset Normal highlight definition.
function M.refresh()
  NORMAL = M.get_hl("Normal")
end
M.refresh()

return M
