local fmt = require'tabline.themes'.fmt

local dtrm = 'grey'
local dgui = 'grey'

local green, black, red, magenta = 'green', 'black', 'red', 'magenta'
local grey, cyan, white = 'grey', 'darkcyan', 'white'

local Select =      { black,   green,   black,       green,      true }
local SelectMod =   { red,     green,   red,         green,      true }
local Visible =     { cyan,    black,   cyan,        black,      true }
local VisibleMod =  { red,     black,   red,         black,      true }
local Hidden =      { grey,    black,   grey,        black,      false }
local HiddenMod =   { red,     black,   red,         black,      false }
local Extra =       { green,   black,   green,       black,      false }
local ExtraMod =    { red,     black,   red,         black,      false }
local Special =     { black,   magenta, black,       magenta,    false }
local NumSel =      { black,   green,   black,       green,      true }
local Num =         { green,   black,   green,       black,      true }
local Corner =      { green,   black,   green,       black,      true }
local Fill =        { green,   black,   green,       black,      false }
local SelectDim =   { dtrm,    green,   black,       green,      false }
local VisibleDim =  { dtrm,    black,   cyan,        black,      false }
local HiddenDim =   { dtrm,    black,   grey,        black,      false }
local ExtraDim =    { dtrm,    black,   green,       black,      false }
local SpecialDim =  { dtrm,    black,   black,       magenta,    false }
local SelectSep =   { red,     green,   black,       green,      false }
local VisibleSep =  { dtrm,    black,   cyan,        black,      false }
local HiddenSep =   { dtrm,    black,   grey,        black,      false }
local ExtraSep =    { dtrm,    black,   green,       black,      false }
local SpecialSep =  { dtrm,    black,   black,       magenta,    false }

local function theme()
  return {
    name = 'eightbit',

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
