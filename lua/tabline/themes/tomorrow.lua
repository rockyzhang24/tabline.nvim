local fmt = require'tabline.themes'.fmt

local dtrm = 248
local dgui = '#a9a9a9'

local Select =      { 235,    151, '#262626',   '#99cc99',   true }
local SelectMod =   { 210,    151, '#f2777a',   '#99cc99',   true }
local Visible =     { 222,    238, '#ffcc66',   '#444444',   false }
local VisibleMod =  { 210,    238, '#f2777a',   '#444444',   true }
local Hidden =      { 252,    242, '#cccccc',   '#666666',   false }
local HiddenMod =   { 210,    242, '#f2777a',   '#666666',   false }
local Extra =       { 235,    182, '#262626',   '#cc99cc',   true }
local ExtraMod =    { 210,    182, '#f2777a',   '#cc99cc',   true }
local Special =     { 239,    222, '#3C4C55',   '#ffcc66',   true }
local NumSel =      { 150,    239, '#A8CE93',   '#3C4C55',   false }
local Num =         { 222,    238, '#ffcc66',   '#444444',   false }
local Corner =      { 222,    238, '#ffcc66',   '#444444',   false }
local Fill =        { 241,    236, '#666666',   '#2d2d2d',   false }
local FillLight =   { 252,    242, '#cccccc',   '#666666',   false }
local SelectDim =   { dtrm,   151, dgui,        '#99cc99',   false }
local VisibleDim =  { dtrm,   238, dgui,        '#444444',   false }
local HiddenDim =   { dtrm,   242, dgui,        '#666666',   false }
local ExtraDim =    { dtrm,   182, dgui,        '#cc99cc',   false }
local SpecialDim =  { dtrm,   222, dgui,        '#ffcc66',   false }
local SelectSep =   { 210,    151, '#f2777a',   '#99cc99',   false }
local VisibleSep =  { dtrm,   238, dgui,        '#444444',   false }
local HiddenSep =   { dtrm,   242, dgui,        '#666666',   false }
local ExtraSep =    { dtrm,   182, dgui,        '#cc99cc',   false }
local SpecialSep =  { dtrm,   222, dgui,        '#ffcc66',   false }

local function theme()
  return {
    name = 'tomorrow',

    settings = {
      colored_icons = false,
    },

    TSelect =     fmt(Select),
    TSelectMod =  fmt(SelectMod),
    TVisible =    fmt(Visible),
    TVisibleMod = fmt(VisibleMod),
    THidden =     fmt(Hidden),
    THiddenMod =  fmt(HiddenMod),
    TExtra =      fmt(Extra),
    TExtraMod =   fmt(ExtraMod),
    TSpecial =    fmt(Special),
    TNumSel =     fmt(NumSel),
    TNum =        fmt(Num),
    TCorner =     fmt(Corner),
    TFill =       vim.o.background == 'light' and fmt(FillLight) or fmt(Fill),
    TSelectDim =  fmt(SelectDim),
    TSpecialDim = fmt(SpecialDim),
    TVisibleDim = fmt(VisibleDim),
    THiddenDim =  fmt(HiddenDim),
    TExtraDim =   fmt(ExtraDim),
    TSelectSep =  fmt(SelectSep),
    TSpecialSep = fmt(SpecialSep),
    TVisibleSep = fmt(VisibleSep),
    THiddenSep =  fmt(HiddenSep),
    TExtraSep =   fmt(ExtraSep),
  }
end

return { theme = theme }
