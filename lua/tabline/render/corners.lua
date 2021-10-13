local v = require'tabline.setup'.tabline.v
local s = require'tabline.setup'.settings
local index = table.index
local tabpagenr = vim.fn.tabpagenr
local tabpagebuflist = vim.fn.tabpagebuflist
local printf = string.format

local short_cwd = require'tabline.render.paths'.short_cwd
local tab_icon = require'tabline.render.tabline'.tab_icon
local tab_mod_flag = require'tabline.render.tabline'.tab_mod_flag

local hide_tab_number = function() return tabpagenr('$') == 1 or s.tab_number_in_left_corner end

local format_right_corner, right_corner_label, mode_label

--------------------------------------------------------------------------------
-- Corner labels
--------------------------------------------------------------------------------

function format_right_corner()
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
    local icon  = '%#TNumSel# ' .. tab_icon(N, true)
    local mod   = tab_mod_flag(N, true)
    local label = right_corner_label()
    return printf('%s%s %s %s', icon, hi, label, mod)

  else
    -- tab number in form n/N, plus tab name or cwd
    local hi    = '%#TCorner#'
    local nr    = tab_num(N)
    local icon  = tab_icon(N, true)
    local mod   = tab_mod_flag(N, true)
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
function right_corner_label()
  local N = tabpagenr()

  if v.mode == 'tabs' then
    return short_cwd(N)

  elseif v.mode == 'buffers' or v.mode == 'arglist' then
    return v.user_labels and vim.t.tab.name and vim.t.tab.name or short_cwd(N)
  end
end

-------------------------------------------------------------------------------
-- Label for left corner
--
-- It's the tabline mode, and it's only shown under certain conditions.
-------------------------------------------------------------------------------
function mode_label()
  local labels = s.mode_labels
  if labels == 'none' or
        labels == 'secondary' and index(s.modes, v.mode) == 1 or
        labels ~= 'all' and labels ~= 'secondary' and not string.find(labels, v.mode) then
    return ''
  else
    return printf('%%#TExtra# %s %%#TFill# ', v.mode)
  end
end


return {
  format_right_corner = format_right_corner,
  right_corner_label = right_corner_label,
  mode_label = mode_label,
}

