local fmt = require'tabline.themes'.fmt

local dtrm = 60
local dgui = '#6272a4'

local Select =      { 16,      255, '#000000',   '#F0ECDD',  true }
local SelectMod =   { 160,     255, '#cf0000',   '#F0ECDD',  true }
local Visible =     { 16,      252, '#555555',   '#F0ECDD',  true }
local VisibleMod =  { 160,     252, '#cf0000',   '#F0ECDD',  true }
local Hidden =      { 240,     252, '#555555',   '#D4D2C9',  false }
local HiddenMod =   { 174,     252, '#DF8C8C',   '#D4D2C9',  false }
local Extra =       { 16,      249, '#000000',   '#B3B2AE',  false }
local ExtraMod =    { 174,     249, '#DF8C8C',   '#B3B2AE',  false }
local Special =     { 252,     245, '#D4D2C9',   '#8D8C86',  false }
local NumSel =      { 252,     245, '#F0ECDD',   '#8D8C86',  true }
local Num =         { 252,     245, '#D4D2C9',   '#B3B2AE',  true }
local Corner =      { 16,      252, '#000000',   '#D4D2C9',  true }
local Fill =        { 16,      252, '#000000',   '#D4D2C9',  false }
local SelectDim =   { dtrm,    255, dgui,        '#F0ECDD',  false }
local VisibleDim =  { dtrm,    252, dgui,        '#F0ECDD',  false }
local HiddenDim =   { dtrm,    252, dgui,        '#D4D2C9',  false }
local ExtraDim =    { dtrm,    249, dgui,        '#B3B2AE',  false }
local SpecialDim =  { dtrm,    245, dgui,        '#8D8C86',  false }
local SelectSep =   { 24,      255, '#073655',   '#F0ECDD',  false }
local VisibleSep =  { dtrm,    252, dgui,        '#F0ECDD',  false }
local HiddenSep =   { dtrm,    252, dgui,        '#D4D2C9',  false }
local ExtraSep =    { dtrm,    249, dgui,        '#B3B2AE',  false }
local SpecialSep =  { dtrm,    245, dgui,        '#8D8C86',  false }

local function theme()
  return {
    name = 'paper',

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
