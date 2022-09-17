local fmt = require'tabline.themes'.fmt

local dtrm = 60
local dgui = '#6272a4'

local Select =      { 239,     110, '#3C4C55',   '#83AFE5',  true }
local SelectMod =   { 160,     110, '#cf0000',   '#83AFE5',  true }
local Visible =     { 39,      234, '#569cd6',   '#1e1e1e',  true }
local VisibleMod =  { 160,     234, '#cf0000',   '#1e1e1e',  true }
local Hidden =      { 110,     239, '#83AFE5',   '#3C4C55',  false }
local HiddenMod =   { 174,     239, '#DF8C8C',   '#3C4C55',  false }
local Extra =       { 252,     24,  '#C5D4DD',   '#073655',  false }
local ExtraMod =    { 174,     24,  '#DF8C8C',   '#073655',  false }
local Special =     { 239,     150, '#3C4C55',   '#A8CE93',  false }
local NumSel =      { 234,     39,  '#1e1e1e',   '#569cd6',  true }
local Num =         { 39,      236, '#569cd6',   '#333333',  true }
local Corner =      { 39,      234, '#569cd6',   '#1e1e1e',  true }
local Fill =        { 248,     236, '#a9a9a9',   '#333333',  false }
local FillLight =   { 231,     241, '#f8f8f2',   '#616161',  false }
local SelectDim =   { dtrm,    110, dgui,        '#83AFE5',  false }
local VisibleDim =  { dtrm,    234, dgui,        '#1e1e1e',  false }
local HiddenDim =   { dtrm,    239, dgui,        '#3C4C55',  false }
local ExtraDim =    { dtrm,    24,  dgui,        '#073655',  false }
local SpecialDim =  { dtrm,    150, dgui,        '#A8CE93',  false }
local SelectSep =   { 24,      110, '#073655',   '#83AFE5',  false }
local VisibleSep =  { dtrm,    234, dgui,        '#1e1e1e',  false }
local HiddenSep =   { dtrm,    239, dgui,        '#3C4C55',  false }
local ExtraSep =    { dtrm,    24,  dgui,        '#073655',  false }
local SpecialSep =  { dtrm,    150, dgui,        '#A8CE93',  false }

local function theme()
  return {
    name = 'codedark',

    settings = {
      colored_icons = false,
    },

    TSelect =     fmt(Select),
    TSelectMod =  fmt(SelectMod),
    TVisible =    fmt(Visible),
    TVisibleMod = fmt(VisibleMod),
    THidden =     vim.o.background == 'light' and fmt(FillLight) or fmt(Hidden),
    THiddenMod =  vim.o.background == 'light' and fmt(FillLight) or fmt(HiddenMod),
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
