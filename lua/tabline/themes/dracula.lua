local fmt = require'tabline.themes'.fmt

local dtrm = 248
local dgui = '#a9a9a9'

local Select =      { 231,    80,  '#f8f8f2',   '#6272a4',   true }
local SelectMod =   { 212,    60,  '#ff79c6',   '#6272a4',   true }
local Visible =     { 81,     635, '#8be9fd',   '#282a36',   false }
local VisibleMod =  { 212,    235, '#ff79c6',   '#282a36',   true }
local Hidden =      { 248,    238, '#a9a9a9',   '#44475a',   false }
local HiddenMod =   { 212,    238, '#ff79c6',   '#44475a',   false }
local Extra =       { 141,    24,  '#bd93f9',   '#073655',   true }
local ExtraMod =    { 212,    24,  '#ff79c6',   '#073655',   true }
local Special =     { 238,    24,  '#44475a',   '#50fa7b',   true }
local NumSel =      { 238,    84,  '#44475a',   '#50fa7b',   false }
local Num =         { 228,    235, '#f1fa8c',   '#282a36',   false }
local Corner =      { 231,    60,  '#f8f8f2',   '#6272a4',   false }
local Fill =        { 241,    236, '#f1fa8c',   '#282a36',   false }
local FillLight =   { 231,    241, '#f8f8f2',   '#616161',   false }
local SelectDim =   { dtrm,   80,  dgui,        '#6272a4',   false }
local VisibleDim =  { dtrm,   635, dgui,        '#282a36',   false }
local HiddenDim =   { dtrm,   238, dgui,        '#44475a',   false }
local ExtraDim =    { dtrm,   24,  dgui,        '#073655',   false }
local SpecialDim =  { dtrm,   24,  dgui,        '#50fa7b',   false }
local SelectSep =   { 210,    80,  '#f2777a',   '#6272a4',   false }
local VisibleSep =  { dtrm,   635, dgui,        '#282a36',   false }
local HiddenSep =   { dtrm,   238, dgui,        '#44475a',   false }
local ExtraSep =    { dtrm,   24,  dgui,        '#073655',   false }
local SpecialSep =  { dtrm,   24,  dgui,        '#50fa7b',   false }

local function theme()
  return {
    name = 'dracula',

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
