local d = require'tabline.themes.default'

local function theme()
  return {
    name = 'themer',

    TSelect =     "link %s ThemerSelected",
    TVisible =    "link %s ThemerAccent",
    THidden =     "link %s ThemerComment",
    TExtra =      "link %s ThemerConstant",
    TSpecial =    "link %s ThemerSearchResult",
    TFill =       "link %s ThemerFloat",
    TNumSel =     "link %s CursorLine",
    TNum =        "link %s CursorLine",
    TCorner =     "link %s ThemerNormal",
    TSelectMod =  d.mod("ThemerSelected"),
    TVisibleMod = d.mod("ThemerAccent"),
    THiddenMod =  d.mod("ThemerComment"),
    TExtraMod =   d.mod("ThemerConstant"),
    TSelectDim =  d.dim("ThemerSelected"),
    TSpecialDim = d.dim("ThemerSearchResult"),
    TVisibleDim = d.dim("ThemerAccent"),
    THiddenDim =  d.dim("ThemerComment"),
    TExtraDim =   d.dim("ThemerConstant"),
    TSelectSep =  d.sep("ThemerSelected"),
    TSpecialSep = d.dim("ThemerSearchResult"),
    TVisibleSep = d.dim("ThemerAccent"),
    THiddenSep =  d.dim("ThemerComment"),
    TExtraSep =   d.dim("ThemerConstant"),
  }
end

return { theme = theme }
