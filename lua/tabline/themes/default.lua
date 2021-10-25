local gsub = string.gsub
local find  = string.find
local execute = vim.fn.execute

local function mod(group)
  local hi = execute('hi ' .. group)
  local _, _, link = find(hi, 'links to (%w+)')
  if link then
    hi = execute('hi ' .. link)
  end
  hi = gsub(hi, '.*xxx', '')
  hi = gsub(hi, 'ctermfg=%S+', 'ctermfg=124')
  hi = gsub(hi, 'guifg=%S+', 'guifg=#ff6666')
  hi = gsub(hi, 'cterm=%S+', '')
  hi = gsub(hi, 'gui=%S+', '')
  return '%s ' .. hi .. ' cterm=bold gui=bold'
end

local function dim(group)
  local guifg = vim.o.background == 'dark' and '6c6c6c' or 'a9a9a9'
  local termfg = vim.o.background == 'dark' and '242' or '248'
  local hi = execute('hi ' .. group)
  local _, _, link = find(hi, 'links to (%w+)')
  if link then
    hi = execute('hi ' .. link)
  end
  hi = gsub(hi, '.*xxx', '')
  hi = gsub(hi, 'ctermfg=%S+', 'ctermfg=' .. termfg)
  hi = gsub(hi, 'guifg=%S+', 'guifg=#' .. guifg)
  hi = gsub(hi, 'cterm=%S+', '')
  hi = gsub(hi, 'gui=%S+', '')
  return '%s ' .. hi
end

local function sep(group)
  local guifg = vim.o.background == 'dark' and '5f87af' or '4a679a'
  local termfg = vim.o.background == 'dark' and '67' or '7'
  local hi = execute('hi ' .. group)
  local _, _, link = find(hi, 'links to (%w+)')
  if link then
    hi = execute('hi ' .. link)
  end
  hi = gsub(hi, '.*xxx', '')
  hi = gsub(hi, 'ctermfg=%S+', 'ctermfg=' .. termfg)
  hi = gsub(hi, 'guifg=%S+', 'guifg=#' .. guifg)
  hi = gsub(hi, 'cterm=%S+', '')
  hi = gsub(hi, 'gui=%S+', '')
  return '%s ' .. hi
end

function theme()
  return {
    name = 'default',

    TSelect =     'link %s Pmenu',
    TVisible =    'link %s Special',
    THidden =     'link %s Comment',
    TExtra =      'link %s Title',
    TSpecial =    'link %s PmenuSel',
    TFill =       'link %s Folded',
    TNumSel =     'link %s CursorLine',
    TNum =        'link %s CursorLine',
    TCorner =     'link %s Special',
    TSelectMod =  mod('Pmenu'),
    TVisibleMod = mod('Special'),
    THiddenMod =  mod('Comment'),
    TExtraMod =   mod('Title'),
    TSelectDim =  dim('Pmenu'),
    TSpecialDim = dim('PmenuSel'),
    TVisibleDim = dim('Special'),
    THiddenDim =  dim('Comment'),
    TExtraDim =   dim('Title'),
    TSelectSep =  sep('Pmenu'),
    TSpecialSep = dim('PmenuSel'),
    TVisibleSep = dim('Special'),
    THiddenSep =  dim('Comment'),
    TExtraSep =   dim('Title'),
}
end

return { theme = theme }
