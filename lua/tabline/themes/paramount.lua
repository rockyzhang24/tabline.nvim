local fmt = require'tabline.themes'.fmt

local dtrm = 60
local dgui = '#6272a4'

local Select =      { 251,     140, '#000000',   '#a790d5',  true }
local SelectMod =   { 251,     140, '#cf0000',   '#a790d5',  true }
local Visible =     { 243,     0,   '#767676',   '#000000',  true }
local VisibleMod =  { 160,     234, '#cf0000',   '#000000',  true }
local Hidden =      { 251,     236, '#C6C6C6',   '#303030',  false }
local HiddenMod =   { 251,     236, '#cf0000',   '#303030',  false }
local Extra =       { 251,     140, '#C6C6C6',   '#a790d5',  false }
local ExtraMod =    { 174,     24,  '#cf0000',   '#a790d5',  false }
local Special =     { 235,     228, '#262626',   '#ffff87',  false }
local NumSel =      { 140,     239, '#a790d5',   '#4E4E4E',  true }
local Num =         { 140,     239, '#a790d5',   '#4E4E4E',  true }
local Corner =      { 243,     0,   '#767676',   '#000000',  true }
local Fill =        { 243,     0,   '#767676',   '#000000',  false }
local SelectDim =   { dtrm,    140, dgui,        '#a790d5',  false }
local VisibleDim =  { dtrm,    0,   dgui,        '#000000',  false }
local HiddenDim =   { dtrm,    236, dgui,        '#303030',  false }
local ExtraDim =    { dtrm,    140, dgui,        '#a790d5',  false }
local SpecialDim =  { dtrm,    228, dgui,        '#ffff87',  false }
local SelectSep =   { 24,      140, '#073655',   '#a790d5',  false }
local VisibleSep =  { dtrm,    0,   dgui,        '#000000',  false }
local HiddenSep =   { dtrm,    236, dgui,        '#303030',  false }
local ExtraSep =    { dtrm,    140, dgui,        '#a790d5',  false }
local SpecialSep =  { dtrm,    228, dgui,        '#ffff87',  false }

local function theme()
  return {
    name = 'paramount',

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
    TFill =       fmt(Fill),
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
