local fn = vim.fn
local o = vim.o
local g = require'tabline.setup'.tabline
local v = g.v
local s = require'tabline.setup'.settings
local i = s.indicators
local index = table.index
local tabpagenr = fn.tabpagenr
local tabpagebuflist = fn.tabpagebuflist
local tabpagewinnr = fn.tabpagewinnr
local bufname = fn.bufname
local fnamemodify = fn.fnamemodify
local remove = table.remove
local strsub = string.sub
local printf = string.format
local getbufvar = fn.getbufvar

local short_bufname = require'tabline.render.helpers'.short_bufname
local short_cwd = require'tabline.render.helpers'.short_cwd
local render_buffers = require'tabline.render.bufline'.render_buffers
local render_args = require'tabline.render.bufline'.render_args

local hide_tab_number = function() return tabpagenr('$') == 1 or s.tab_number_in_left_corner end
local tab_buffer = function(tnr) return tabpagebuflist(tnr)[tabpagewinnr(tnr)] end

--------------------------------------------------------------------------------
-- Corner labels
--------------------------------------------------------------------------------

local function format_right_corner()
  -- Label for the upper right corner.
  local N = tabpagenr()

  if vim.t.tab.corner then
    -- special right corner with its own label
    return vim.t.tab.corner

  elseif not s.show_right_corner then
    -- no label, just the tab number in form n/N
    return (v.mode == 'tabs' or hide_tab_number()) and '' or tab_num(N)

  elseif v.mode == 'tabs' or hide_tab_number() then
    -- no number, just the name or the cwd
    local hi    = '%#TCorner#'
    local icon  = '%#TNumSel# ' .. get_tab_icon(N, 1)
    local mod   = tab_mod_flag(N, 1)
    local label = right_corner_label()
    return printf('%s%s %s %s', icon, hi, label, mod)

  else
    -- tab number in form n/N, plus tab name or cwd
    local hi    = '%#TCorner#'
    local nr    = tab_num(N)
    local icon  = get_tab_icon(N, 1)
    local mod   = tab_mod_flag(N, 1)
    local label = right_corner_label()
    return printf('%s%s %s%s %s', nr, hi, icon, label, mod)
  end
end --}}}

-------------------------------------------------------------------------------
-- Label for the right corner
--
-- The label can be either:
-- 1. the shortened cwd ('tabs' and 'buffers' mode)
-- 2. a custom tab name ('buffers' mode)
-- 3. the name of the active buffer for this tab ('buffers' mode)
-- 4. the number/total files in the arglist ('arglist' mode)
-------------------------------------------------------------------------------
local function right_corner_label()
  local N = tabpagenr()

  if v.mode == 'tabs' then
    return short_cwd(N)

  elseif v.mode == 'buffers' or v.mode == 'arglist' then
    return v.user_labels and vim.t.tab.name and vim.t.tab.name or short_cwd(N)
  end
end

local function get_mode_label()
  local labels = s.mode_labels
  if labels == 'none' or
        labels == 'secondary' and index(s.modes, v.mode) == 1 or
        labels ~= 'all' and labels ~= 'secondary' and not string.find(labels, v.mode) then
    return ''
  else
    return printf('%%#TExtra# %s %%#TFill# ', v.mode)
  end
end



-------------------------------------------------------------------------------
-- Tab label formatting
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Format the tab number, for either the tab label or the right corner.
--
-- @param tnr: tab number
-- Return the formatted tab number
-------------------------------------------------------------------------------
local function tab_num(tnr)

  if v.mode ~= 'tabs' then
    return printf("%s %d/%d ", "%#TNumSel#", tnr, tabpagenr('$'))
  else
    return tnr == tabpagenr() and printf("%s %d ", "%#TNumSel#", tnr)
            or printf("%s %d ", "%#TNum#", tnr)
  end
end

----
-- The highlight group for the tab label
----
local function tab_hi(tnr)
  if tnr == tabpagenr() then
    return (s.special_tabs and g.buffers[tab_buffer(tnr)].special) and 'Special' or 'Select'
  else
    return 'Hidden'
  end
end

-------------------------------------------------------------------------------
-- The icon for the tab label
--
-- @param tnr: the tab number
-- @param right_corner: if it's for the right corner
-- Return the icon
-------------------------------------------------------------------------------
local function get_tab_icon(tnr, right_corner)
  local T = fn.gettabvar(tnr, 'tab')
  if T.icon then
    return T.icon .. ' '
  end

  if right_corner then
    local icon = s.icons.tab

  else
    local bnr  = tab_buffer(tnr)
    local B    = g.buffers[bnr]
    local buf  = {['nr'] = bnr, ['icon'] = B.icon, ['name'] = B.name}
    local icon = get_buf_icon(buf)
  end

  return not icon and '' or type(icon) == 'string' and icon .. ' ' or icon[tnr ~= tabpagenr()] .. ' '
end

-------------------------------------------------------------------------------
-- Build the tab label in tabs mode.
--
-- The label can be either:
-- 1. the shortened cwd
-- 2. the name of the active special buffer for this tab
-- 3. custom tab or active buffer label (option: user_labels)
-- 4. the name of the active buffer for this tab (option-controlled)
--
-- @param tnr: the tab number
-- Return the formatted tab label
-------------------------------------------------------------------------------
local function tab_label(tnr)

  local bnr = tab_buffer(tnr)
  local buf = g.buffers[bnr]
  local tab = vim.t.tab

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

  local fname = bufname(bnr)
  local minimal = o.columns < 100      -- window is small

  if not fn.filereadable(fname) then   -- new files/scratch buffers
    local scratch = getbufvar(bnr, '&buftype') ~= ''
    return fname == '' and scratch and s.scratch_label or s.unnamed_label
            or scratch and fname
            or minimal and fnamemodify(fname, ':t')
            or short_bufname(bnr)

  elseif minimal then
    return fnamemodify(fname, ':t')

  else
    return short_bufname(bnr)
  end
end

-------------------------------------------------------------------------------
-- 'modified' indicator for a tab label
--
-- @param tnr:  the tab number
-- @param corner: if the flag is for the right corner
-- Return the formatted flag
-------------------------------------------------------------------------------
local function tab_mod_flag(tnr, corner)
  for _, buf in ipairs(tabpagebuflist(tnr)) do
    if getbufvar(buf, '&modified') > 0 then
      return corner and '%#TVisibleMod#' .. i.modified
              or tnr == tabpagenr() and '%#TSelectMod#' .. i.modified .. ' '
              or '%#THiddenMod#' .. i.modified .. ' '
    end
  end
  return ''
end

-------------------------------------------------------------------------------
-- Format the tab label in 'tabs' mode
--
-- @param tnr: the tab's number
-- Return a tab 'object' with label and highlight groups
-------------------------------------------------------------------------------
local function format_tab_label(tnr)

  local nr    = '%' .. tnr .. 'T' .. tab_num(tnr)
  local hi    = tab_hi(tnr)
  local icon  = get_tab_icon(tnr, 0)
  local label = tab_label(tnr)
  local mod   = tab_mod_flag(tnr, 0)
  local width = 3 + #label + (icon == '' and 0 or 3) + (mod == '' and 0 or 2)

  local formatted = printf("%s%%#T%s# %s%s %s", nr, hi, icon, label, mod)

  return {['label'] = formatted, ['nr'] = tnr, ['hi'] = hi, ['width'] = width}
end




-------------------------------------------------------------------------------
-- Finalize
-------------------------------------------------------------------------------

local function fit_tabline(center, tabs)
  local corner_label = format_right_corner()
  local corner_width = #corner_label

  local modelabel = get_mode_label()
  if modelabel ~= '' then
    corner_width = corner_width + #modelabel
  end

  local tabsnums = ''
  if tabpagenr('$') > 1 and s.tab_number_in_left_corner then
    tabsnums = '%#ErrorMsg# ' .. tabpagenr() .. '/' .. tabpagenr('$') .. ' %#TFill# '
    corner_width = corner_width + #tabsnums
  end

  -- limit is the max bufline length
  local limit = o.columns - corner_width - 1

  -- now keep the current buffer center-screen as much as possible
  local L = { ['lasttab'] =  0, ['cut'] =  '.', ['indicator'] = '<', ['width'] = 0, ['half'] = math.floor(limit / 2) }
  local R = { ['lasttab'] = -1, ['cut'] = '.$', ['indicator'] = '>', ['width'] = 0, ['half'] = limit - L.half }

  -- sum the string lengths for the left and right halves
  local currentside = L
  for _, tab in ipairs(tabs) do
    if tab.width >= limit then
      tab.label = strsub(tab.label, 1, limit - 1) .. '…'
      tab.width = limit
    end
    if center == tab.nr then
      local halfwidth = tab.width / 2
      L.width = L.width + halfwidth
      R.width = R.width + tab.width - halfwidth
      currentside = R
    else
      currentside.width = currentside.width + tab.width
    end
  end

  if currentside == L then -- centered buffer not seen?
    L.width, R.width = 0, L.width
  end

  local left_has_been_cut = false
  local right_has_been_cut = false

  if ( L.width + R.width ) > limit then
    while limit - ( L.width + R.width ) < 0 do
      -- remove a tab from the biggest side
      if L.width <= R.width then
        right_has_been_cut = true
        R.width = R.width - remove(tabs, #tabs).width
      else
        left_has_been_cut = true
        L.width = L.width - remove(tabs, 1).width
      end
    end
    if left_has_been_cut then
      tabs[1].label = '%#DiffDelete# < %#TFill#'
    end
    if right_has_been_cut then
      tabs[#tabs].label = '%#DiffDelete# > '
    end
  end

  local labels = table.map(tabs, function(_,v) return v.label end)
  if v.mode == 'tabs' then
    for n = 1, #labels do
      labels[n] = '%' .. (n+1) .. 'T' .. labels[n]
    end
  end
  labels = tabsnums .. modelabel .. table.concat(labels, '')
  return labels .. '%#TFill#%=' .. corner_label .. '%999X'
end

-- }}}


-------------------------------------------------------------------------------
-- Tabline mode
-------------------------------------------------------------------------------

local function render_tabs()
  local tabs = {}
  for tnr = 1, tabpagenr('$') do
    table.insert(tabs, format_tab_label(tnr))
  end
  return tabpagenr(), tabs
end


local function render()
  if o.columns < 40 then
    return format_right_corner()
  elseif v.mode == 'tabs' then
    return fit_tabline(render_tabs())
  elseif v.mode == 'args' then
    return fit_tabline(render_args())
  else
    return fit_tabline(render_buffers())
  end
end


return { render = render }
