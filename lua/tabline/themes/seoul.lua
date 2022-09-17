local fmt = require'tabline.themes'.fmt

local dtrm = 234
local dgui = '#1e1e1e'

local Select =      { 187,    23,  '#DFDEBD',   '#007173',   true }
local SelectMod =   { 174,    23,  '#DF8C8C',   '#007173',   true }
local Visible =     { 237,    233, '#F2C38F',   '#383838',   false }
local VisibleMod =  { 174,    233, '#DF8C8C',   '#383838',   true }
local Hidden =      { 231,    241, '#f8f8f2',   '#616161',   false }
local HiddenMod =   { 174,    241, '#DF8C8C',   '#616161',   false }
local Extra =       { 253,    126, '#D9D9D9',   '#9B1D72',   true }
local ExtraMod =    { 174,    126, '#DF8C8C',   '#9B1D72',   true }
local Special =     { 239,    237, '#3C4C55',   '#F2C38F',   true }
local NumSel =      { 239,    150, '#3C4C55',   '#A8CE93',   false }
local Num =         { 237,    233, '#F2C38F',   '#383838',   false }
local Corner =      { 237,    233, '#F2C38F',   '#383838',   false }
local Fill =        { 248,    233, '#a9a9a9',   '#383838',   false }
local FillLight =   { 231,    241, '#f8f8f2',   '#616161',   false }
local SelectDim =   { dtrm,   23,  dgui,        '#007173',   false }
local VisibleDim =  { dtrm,   233, dgui,        '#383838',   false }
local HiddenDim =   { dtrm,   241, dgui,        '#616161',   false }
local ExtraDim =    { dtrm,   126, dgui,        '#9B1D72',   false }
local SpecialDim =  { dtrm,   237, dgui,        '#F2C38F',   false }
local SelectSep =   { 174,    23,  '#DF8C8C',   '#007173',   false }
local VisibleSep =  { dtrm,   233, dgui,        '#383838',   false }
local HiddenSep =   { dtrm,   241, dgui,        '#616161',   false }
local ExtraSep =    { dtrm,   126, dgui,        '#9B1D72',   false }
local SpecialSep =  { dtrm,   237, dgui,        '#F2C38F',   false }

local function theme()
  return {
    name = 'seoul',

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
