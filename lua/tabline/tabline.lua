local o = vim.o
local v = require'tabline.setup'.variables
local s = require'tabline.setup'.settings
local i = require'tabline.setup'.indicators
local h = require'tabline.helpers'

-- vim functions {{{1
local tabpagenr = vim.fn.tabpagenr
local strwidth = vim.api.nvim_strwidth

-- table functions {{{1
local tbl = require'tabline.table'
local remove = table.remove
local concat = table.concat
local map = tbl.map
local index = tbl.index
--}}}

local strsub = string.sub
local subst  = string.gsub
local printf = string.format

local render_tabs = require'tabline.render.tabline'.render_tabs
local render_buffers = require'tabline.render.bufline'.render_buffers
local render_args = require'tabline.render.bufline'.render_args

local fit_tabline, render

local format_right_corner = require'tabline.render.corners'.format_right_corner
local mode_label = require'tabline.render.corners'.mode_label

local function bufwidth(str) str = subst(str, '%%#%w+#', '') return strwidth(str) end
local function tabwidth(str) str = subst(subst(str, '%%#%w+#', ''), '%%%d+T', '') return strwidth(str) end

-------------------------------------------------------------------------------
-- Entry point for tabline rendering
-------------------------------------------------------------------------------

function render()
  if o.columns < 40 then
    return format_right_corner()
  elseif h.tabs_mode() then
    return fit_tabline(render_tabs())
  elseif v.mode == 'args' then
    return fit_tabline(render_args(render_tabs))
  else
    return fit_tabline(render_buffers())
  end
end


-------------------------------------------------------------------------------
-- Make all tabs fit
-------------------------------------------------------------------------------

local function tabs_badge() -- Tabs badge {{{1
  local bdg = s.tabs_badge
  if not bdg or bdg.visibility and not index(bdg.visibility, v.mode) then
    return ''
  end
  if not bdg.fraction then
    local ret = '%#THidden#'
    for i = 1, tabpagenr('$') do
      if tabpagenr() == i then
        ret = ret .. '%#TSelect# ' .. i .. ' %#THidden#'
      else
        ret = ret .. ' ' .. i .. ' '
      end
    end
    return ret .. '%#TFill# '
  elseif tabpagenr('$') > 1 then
    local tn = tabpagenr() .. '/' .. tabpagenr('$')
    return '%#ErrorMsg# ' .. tn .. ' %#TFill# ', #tn + 3
  else
    return ''
  end
end

-- }}}

function fit_tabline(center, tabs)
  local labelwidth = h.tabs_mode() and tabwidth or bufwidth
  local limit = o.columns - 1

  local cwdbadge = format_right_corner()
  limit = limit - labelwidth(cwdbadge)

  local modebadge = mode_label()
  limit = limit - labelwidth(modebadge)

  local tabsbadge = tabs_badge()
  limit = limit - labelwidth(tabsbadge)

  if limit < 30 then
    return '%#TFill#%=' .. cwdbadge
  end

  -- now keep the current buffer center-screen as much as possible
  local L = { ['width'] = 0 }
  local R = { ['width'] = 0 }

  -- sum the string lengths for the left and right halves
  local currentside = L
  for _, tab in ipairs(tabs) do
    tab.width = labelwidth(tab.label)
    if tab.width >= limit then
      tab.label = strsub(tab.label, 1, limit - 1) .. '…'
      tab.width = labelwidth(tab.label)
    end
    if center == tab.nr then
      local halfwidth = math.floor(tab.width / 2)
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

  local left_has_been_cut, right_has_been_cut, arrow = false, false, 0

  if ( L.width + R.width ) > limit then
    while limit - ( L.width + R.width + arrow ) < 0 do
      -- remove a tab from the biggest side
      if L.width <= R.width then
        right_has_been_cut = true
        R.width = R.width - remove(tabs, #tabs).width
      else
        left_has_been_cut, arrow = true, 3
        L.width = L.width - remove(tabs, 1).width
      end
    end
    local ntabs = #tabs
    if left_has_been_cut then
      tabs[1].label = '%#DiffDelete# < ' .. tabs[1].label
    end
    -- adapt the tabs to the available space
    local i, used = 1, L.width + R.width + arrow
    while used < limit do
      if i > ntabs then i = 1 end
      tabs[i].label = tabs[i].label .. ' '
      i, used = i + 1, used + 1
    end
    if right_has_been_cut then
      tabs[ntabs].label = printf('%s%%#DiffDelete# > ', strsub(tabs[ntabs].label, 1, #tabs[ntabs].label - 4))
    end
  else
    -- make labels a bit broader as long as there is enough room
    local i, used, ntabs = 1, L.width + R.width, #tabs
    while used < limit do
      if i > ntabs then
        break
      end
      tabs[i].label = tabs[i].label .. ' '
      i, used = i + 1, used + 1
    end
  end

  -- button to close buffer
  local button = '@CloseButtonClick@' .. i.close .. '%X'

  if h.buffers_mode() then
    if s.clickable_bufline and s.show_button then
      for _, l in ipairs(tabs) do
        l.label = '%' .. l.n .. '@BuflineClick@' .. l.label .. '%X'
        .. '%' .. l.n .. button
      end
    elseif s.clickable_bufline then
      for _, l in ipairs(tabs) do
        l.label = '%' .. l.n .. '@BuflineClick@' .. l.label .. '%X'
      end
    elseif s.show_button then
      for _, l in ipairs(tabs) do
        l.label = l.label .. '%' .. l.n .. button
      end
    end
  end

  local labels = map(tabs, function(_,val) return val.label end)
  if h.tabs_mode() then
    for n, l in ipairs(labels) do
      labels[n] = '%' .. n .. 'T' .. l
    end
  end
  labels = concat(labels, '')
  if s.tabs_badge and s.tabs_badge.left then
    return tabsbadge .. modebadge .. labels .. '%#TFill#%=' .. cwdbadge .. '%999X'
  else
    return modebadge .. labels .. '%#TFill#%=' .. tabsbadge .. cwdbadge .. '%999X'
  end
end

-- }}}


return { render = render }
