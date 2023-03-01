local fn = vim.fn
local g = require'tabline.setup'.global
local s = require'tabline.setup'.settings
local v = require'tabline.setup'.variables
local i = require'tabline.setup'.indicators

-- vim functions {{{1
local tabpagenr = fn.tabpagenr
local tabpagebuflist = fn.tabpagebuflist
local tabpagewinnr = fn.tabpagewinnr
local getbufvar = fn.getbufvar
local gettabvar = fn.gettabvar

-- table functions {{{1
local insert = table.insert
--}}}

local printf = string.format

local buf_icon = require'tabline.render.bufline'.buf_icon
local buf_path = require'tabline.render.bufline'.buf_path
local get_tab = require'tabline.tabs'.get_tab
local get_buf = require'tabline.bufs'.get_buf
local devicons = require'tabline.render.icons'.icons

local tab_buffer = function(tnr) return tabpagebuflist(tnr)[tabpagewinnr(tnr)] end

local sepactive, sepinactive
local tab_nr, tab_num, tab_sep, tab_mod_flag, tab_label, tab_hi, tab_icon
local format_tab_label, render_tabs

local function refresh_icons()
  devicons = require'tabline.render.icons'.icons
end



-------------------------------------------------------------------------------
-- Tabline rendering
-------------------------------------------------------------------------------

function render_tabs()
  -- set function that renders the tabs number/separator
  tab_nr = v.label_style == 'sep' and tab_sep or tab_num
  sepactive, sepinactive = unpack(s.separators)

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

function tab_sep(tnr, hi)
  return tnr == tabpagenr() and "%#T" .. hi .. "Mod#" .. sepactive
                             or "%#T" .. hi .. "Dim#" .. sepinactive
end

----
-- The highlight group for the tab label
----
function tab_hi(bnr, tnr)
  if tnr == tabpagenr() then
    return (s.special_tabs and get_buf(bnr) and g.buffers[bnr].special) and 'Special' or 'Select'
  else
    return 'Hidden'
  end
end

----
-- Build the tab label in tabs mode.
--
-- The label can be either:
-- 1. the shortened cwd
-- 2. the name of the active special buffer for this tab
-- 3. custom tab or active buffer label
-- 4. the name of the active buffer for this tab
--
-- @param bnr: the buffer for the label
-- @param tnr: the tab number
-- @return: the formatted tab label
----
function tab_label(bnr, tnr)

  local buf = get_buf(bnr)
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

  return buf_path(bnr, not s.show_full_path)
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
function tab_icon(bnr, tnr, hi)
  if not s.show_icons then
    return ''
  end
  local T = gettabvar(tnr, 'tab')
  if T.icon then
    if devicons[T.icon] then
      return devicons[T.icon][tnr == tabpagenr() and 'Selected' or 'Visible']
    end
    return T.icon .. ' '
  end

  local B = get_buf(bnr)
  if not B then return '' end

  local buf  = {nr = bnr, hi = hi, icon = B.icon, name = B.name}
  local icon = buf_icon(buf, tnr == tabpagenr())

  return not icon and ''
         or type(icon) == 'string' and icon
         or icon[tnr == tabpagenr() and 1 or 2] .. ' '
end


-------------------------------------------------------------------------------
-- Format the tab label in 'tabs' mode
--
-- @param tnr: the tab's number
-- Return a tab 'object' with label and highlight groups
-------------------------------------------------------------------------------
function format_tab_label(tnr)

  local bnr   = tab_buffer(tnr)
  local hi    = tab_hi(bnr, tnr)
  local nr    = '%' .. tnr .. 'T' .. ( s.ascii_only and '' or tab_nr(tnr, hi) )
  local icon  = tab_icon(bnr, tnr, hi)
  local label = tab_label(bnr, tnr)
  local mod   = tab_mod_flag(tnr, false)

  local formatted = get_buf(bnr) and g.buffers[bnr].doubleicon
                    and printf("%s%%#T%s# %s%s %s%s", nr, hi, icon, label, icon, mod)
                    or printf("%s%%#T%s# %s%s %s", nr, hi, icon, label, mod)

  return {['label'] = formatted, ['nr'] = tnr, ['hi'] = hi}
end


return {
  tab_num = tab_num,
  tab_mod_flag = tab_mod_flag,
  tab_label = tab_label,
  format_tab_label = format_tab_label,
  render_tabs = render_tabs,
  refresh_icons = refresh_icons,
}


