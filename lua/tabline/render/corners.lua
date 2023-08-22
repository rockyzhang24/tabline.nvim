local v = require'tabline.setup'.variables
local s = require('tabline.setup').settings

local icons = require('tabline.setup').icons

-- vim functions {{{1
local tabpagenr = vim.fn.tabpagenr
local gettabvar = vim.fn.gettabvar

local printf = string.format

local short_cwd = require('tabline.render.paths').short_cwd
local tab_mod_flag = require('tabline.render.tabline').tab_mod_flag
local get_tab = require('tabline.tabs').get_tab
local tabs_mode = require('tabline.helpers').tabs_mode

local format_right_corner, right_corner_icon, right_corner_label, mode_label

--------------------------------------------------------------------------------
-- Corner labels
--------------------------------------------------------------------------------

function format_right_corner()
  -- Label for the upper right corner.
  local N = tabpagenr()
  local t = vim.t.tab or get_tab()

  if t.corner then
    return vim.t.tab.corner
  elseif not s.cwd_badge then
    return ''
  else
    local flt = t.filter and '%#TExtra# ' .. t.filter .. ' ' or ''
    local hi = '%#TCorner#'
    local icon = '%#TNumSel# ' .. right_corner_icon(N)
    local mod = tab_mod_flag(N, true)
    local label = right_corner_label(N)
    return printf('%s%s%s %s %s', flt, icon, hi, label, mod)
  end
end --}}}

-------------------------------------------------------------------------------
-- The icon for the right corner label
--
-- @param tnr: the tab number
-- Return the icon
-------------------------------------------------------------------------------
function right_corner_icon(tnr)
  if not s.show_icons then
    return 'CWD '
  end
  local T, icon = gettabvar(tnr, 'tab'), icons.tab
  if T.icon then
    return T.icon .. ' '
  end
  return not icon and ''
    or type(icon) == 'string' and icon .. ' '
    or icon[tnr == tabpagenr() and 1 or 2] .. ' '
end

-------------------------------------------------------------------------------
-- Label for the right corner
--
-- The label can be either:
-- 1. the shortened cwd ('tabs' and 'buffers' mode)
-- 2. a custom tab name ('buffers' mode)
-- 3. the name of the active buffer for this tab ('buffers' mode) TODO?
-- 4. the number/total files in the arglist ('args' mode) TODO?
-------------------------------------------------------------------------------
function right_corner_label(N)
  return tabs_mode() and short_cwd(N) or vim.t.tab.name or short_cwd(N)
end

-------------------------------------------------------------------------------
-- Label that shows the current mode.
-------------------------------------------------------------------------------
function mode_label()
  local label = s.mode_badge
  if not label then
    return ''
  elseif label == true then
    if v.mode == 'auto' then
      return tabpagenr('$') == 1 and '%#TExtra# buffers %#TFill# '
        or '%#TExtra# tabs %#TFill# '
    else
      return printf('%%#TExtra# %s %%#TFill# ', v.mode)
    end
  elseif v.mode == 'auto' then
    if label.auto then
      return label.auto ~= '' and printf('%%#TExtra# %s %%#TFill# ', label.auto)
        or ''
    elseif tabpagenr('$') == 1 then
      return label.buffers
          and label.buffers ~= ''
          and printf('%%#TExtra# %s %%#TFill# ', label.buffers)
        or ''
        or ''
    else
      return label.tabs
          and label.tabs ~= ''
          and printf('%%#TExtra# %s %%#TFill# ', label.tabs)
        or ''
        or ''
    end
  else
    return label[v.mode]
        and label[v.mode] ~= ''
        and printf('%%#TExtra# %s %%#TFill# ', label[v.mode])
      or ''
      or ''
  end
end

return {
  format_right_corner = format_right_corner,
  right_corner_label = right_corner_label,
  mode_label = mode_label,
}
