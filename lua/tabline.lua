local o = vim.o
local v = require'tabline.setup'.tabline.v
local s = require'tabline.setup'.settings

local tabpagenr = vim.fn.tabpagenr

local remove = table.remove
local strsub = string.sub
local subst  = string.gsub
local printf = string.format

local render_tabs = require'tabline.render.tabline'.render_tabs
local render_buffers = require'tabline.render.bufline'.render_buffers
local render_args = require'tabline.render.bufline'.render_args

local fit_tabline, render

local format_right_corner = require'tabline.render.corners'.format_right_corner
local mode_label = require'tabline.render.corners'.mode_label

local function tabs_mode() return v.mode == 'tabs' or v.mode == 'auto' and tabpagenr('$') > 1 end
local function strwidth(s) return #subst(s, '%%#%w+#', '') end
local function tabwidth(s) return #subst(subst(s, '%%#%w+#', ''), '%%%d+T', '') end


-------------------------------------------------------------------------------
-- Entry point for tabline rendering
-------------------------------------------------------------------------------

function render()
  if o.columns < 40 then
    return format_right_corner()
  elseif tabs_mode() then
    return fit_tabline(render_tabs())
  elseif v.mode == 'args' then
    return fit_tabline(render_args())
  else
    return fit_tabline(render_buffers())
  end
end


-------------------------------------------------------------------------------
-- Make all tabs fit
-------------------------------------------------------------------------------

function fit_tabline(center, tabs)
  local labelwidth = tabs_mode() and tabwidth or strwidth
  local limit = o.columns - 1
  local corner_label = format_right_corner()
  limit = limit - labelwidth(corner_label)

  local modelabel = mode_label()
  if modelabel ~= '' then
    limit = limit - #v.mode - 3
  end

  local tabsnums = ''
  if tabpagenr('$') > 1 and s.tab_number_in_left_corner then
    local tn = tabpagenr() .. '/' .. tabpagenr('$')
    tabsnums = '%#ErrorMsg# ' .. tn .. ' %#TFill# '
    limit = limit - #tn - 3
  end

  -- now keep the current buffer center-screen as much as possible
  local L = { ['width'] = 0 }
  local R = { ['width'] = 0 }

  -- sum the string lengths for the left and right halves
  local currentside = L
  for _, tab in ipairs(tabs) do
    tab.width = labelwidth(tab.label) - (tab.icon and 2 or 0)
    if tab.width >= limit then
      tab.label = strsub(tab.label, 1, limit - 1) .. '…'
      tab.width = labelwidth(tab.label) - (tab.icon and 2 or 0)
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

  local left_has_been_cut, right_has_been_cut = false, false

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
      table.insert(tabs, 1, {['label'] = '%#DiffDelete# < '})
    end
    if right_has_been_cut then
      local ntabs = #tabs
      tabs[ntabs].label = printf('%s%%#DiffDelete# > ', strsub(tabs[ntabs].label, 1, #tabs[ntabs].label - 4))
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


return { render = render }
