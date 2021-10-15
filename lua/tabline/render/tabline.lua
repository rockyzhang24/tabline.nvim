local o = vim.o
local g = require'tabline.setup'.tabline
local v = g.v
local s = require'tabline.setup'.settings
local i = s.indicators

-- vim functions {{{1
local tabpagenr = vim.fn.tabpagenr
local tabpagebuflist = vim.fn.tabpagebuflist
local tabpagewinnr = vim.fn.tabpagewinnr
local bufname = vim.fn.bufname
local fnamemodify = vim.fn.fnamemodify
local getbufvar = vim.fn.getbufvar
local gettabvar = vim.fn.gettabvar
local filereadable = vim.fn.filereadable

-- table functions {{{1
local tbl = require'tabline.table'
local remove = table.remove
local concat = table.concat
local insert = table.insert
local index = tbl.index
--}}}

local printf = string.format

local short_bufname = require'tabline.render.paths'.short_bufname
local buf_icon = require'tabline.render.bufline'.buf_icon
local buf_path = require'tabline.render.bufline'.buf_path
local get_tab = require'tabline.tabs'.get_tab

local tab_buffer = function(tnr) return tabpagebuflist(tnr)[tabpagewinnr(tnr)] end

local tab_num, tab_mod_flag, tab_label, tab_hi, tab_icon, format_tab_label, render_tabs




-------------------------------------------------------------------------------
-- Tabline rendering
-------------------------------------------------------------------------------

function render_tabs()
  local tabs = {}
  for tnr = 1, tabpagenr('$') do
    insert(tabs, format_tab_label(tnr))
  end
  return tabpagenr(), tabs
end



-------------------------------------------------------------------------------
-- Tab label formatting
-------------------------------------------------------------------------------

----
-- Format the tab number for the tab label.
----
function tab_num(tnr)
  return printf("%%#TNum%s# %d ", tnr == tabpagenr() and 'Sel' or '', tnr)
end

----
-- The highlight group for the tab label
----
function tab_hi(tnr)
  if tnr == tabpagenr() then
    return (s.special_tabs and g.buffers[tab_buffer(tnr)].special) and 'Special' or 'Select'
  else
    return 'Hidden'
  end
end

-------------------------------------------------------------------------------
-- Build the tab label in tabs mode.
--
-- The label can be either:
-- 1. the shortened cwd
-- 2. the name of the active special buffer for this tab
-- 3. custom tab or active buffer label
-- 4. the name of the active buffer for this tab
--
-- @param tnr: the tab number
-- Return the formatted tab label
-------------------------------------------------------------------------------
function tab_label(tnr)

  local bnr = tab_buffer(tnr)
  local buf = g.buffers[bnr]
  local tab = get_tab(tnr)

  -- custom label
  if buf and buf.special then
    return buf.name
  elseif tab.name then
    return tab.name
  elseif not buf then
    return s.scratch_label
  elseif buf.name then
    return buf.name
  end

  return buf_path(bnr, not s.tabs_full_path)
end

-------------------------------------------------------------------------------
-- 'modified' indicator for a tab label
--
-- @param tnr:  the tab number
-- @param corner: if the flag is for the right corner
-- Return the formatted flag
-------------------------------------------------------------------------------
function tab_mod_flag(tnr, corner)
  for _, buf in ipairs(tabpagebuflist(tnr)) do
    if getbufvar(buf, '&modified') > 0 then
      return corner and '%#TVisibleMod#' .. i.modified .. ' '
              or tnr == tabpagenr() and '%#TSelectMod#' .. i.modified .. ' '
              or '%#THiddenMod#' .. i.modified .. ' '
    end
  end
  return ''
end

-------------------------------------------------------------------------------
-- The icon for the tab label
--
-- @param tnr: the tab number
-- @param right_corner: if it's for the right corner
-- Return the icon
-------------------------------------------------------------------------------
function tab_icon(tnr, right_corner, hi)
  local T, icon = gettabvar(tnr, 'tab'), nil
  if T.icon then
    return T.icon .. ' '
  end

  if right_corner then
    icon = s.icons.tab

  else
    local bnr  = tab_buffer(tnr)
    local B    = g.buffers[bnr]

    if not B then return '' end

    local buf  = {['nr'] = bnr, ['icon'] = B.icon, ['name'] = B.name}
    icon = buf_icon(buf, hi, tnr == tabpagenr())
  end

  return not icon and '' or type(icon) == 'string' and icon .. ' ' or icon[tnr == tabpagenr() and 1 or 2] .. ' '
end


-------------------------------------------------------------------------------
-- Format the tab label in 'tabs' mode
--
-- @param tnr: the tab's number
-- Return a tab 'object' with label and highlight groups
-------------------------------------------------------------------------------
function format_tab_label(tnr)

  local nr    = '%' .. tnr .. 'T' .. tab_num(tnr)
  local hi    = tab_hi(tnr)
  local icon  = tab_icon(tnr, false, hi)
  local label = tab_label(tnr)
  local mod   = tab_mod_flag(tnr, false)

  local formatted = printf("%s%%#T%s# %s%s %s", nr, hi, icon, label, mod)

  return {['label'] = formatted, ['nr'] = tnr, ['hi'] = hi}
end


return {
  tab_num = tab_num,
  tab_mod_flag = tab_mod_flag,
  tab_label = tab_label,
  tab_hi = tab_hi,
  tab_icon = tab_icon,
  format_tab_label = format_tab_label,
  render_tabs = render_tabs,
}


