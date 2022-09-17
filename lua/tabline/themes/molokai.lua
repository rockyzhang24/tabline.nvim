local fmt = require'tabline.themes'.fmt

local dtrm = 248
local dgui = '#a9a9a9'

local Select =      { 185,    241, '#e6db74',   '#616161',   false }
local SelectMod =   { 9,      241, '#ff0000',   '#616161',   false }
local Visible =     { 180,    238, '#e0b074',   '#444444',   true }
local VisibleMod =  { 9,      238, '#ff0000',   '#444444',   true }
local Hidden =      { 248,    236, '#a9a9a9',   '#333333',   false }
local HiddenMod =   { 9,      236, '#ff0000',   '#333333',   false }
local Extra =       { 197,    235, '#f92672',   '#232526',   true }
local ExtraMod =    { 185,    235, '#e6db74',   '#232526',   true }
local Special =     { 8,      84,  '#808080',   '#50fa7b',   false }
local NumSel =      { 235,    185, '#232526',   '#e6db74',   true }
local Num =         { 185,    235, '#e6db74',   '#232526',   false }
local Corner =      { 185,    238, '#e6db74',   '#444444',   false }
local Fill =        { 248,    235, '#a9a9a9',   '#232526',   false }
local FillLight =   { 231,    241, '#f8f8f2',   '#616161',   false }
local SelectDim =   { dtrm,   241, dgui,        '#616161',   false }
local VisibleDim =  { dtrm,   238, dgui,        '#444444',   false }
local HiddenDim =   { dtrm,   236, dgui,        '#333333',   false }
local ExtraDim =    { dtrm,   235, dgui,        '#232526',   false }
local SpecialDim =  { dtrm,   84,  dgui,        '#50fa7b',   false }
local SelectSep =   { 210,    241, '#f2777a',   '#616161',   false }
local VisibleSep =  { dtrm,   238, dgui,        '#444444',   false }
local HiddenSep =   { dtrm,   236, dgui,        '#333333',   false }
local ExtraSep =    { dtrm,   235, dgui,        '#232526',   false }
local SpecialSep =  { dtrm,   84,  dgui,        '#50fa7b',   false }

local function theme()
  return {
    name = 'molokai',

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
