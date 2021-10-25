function theme()
  return {
    name = 'apprentice',

    TSelect =     '%s cterm=NONE gui=NONE ctermfg=250 ctermbg=238 guifg=#bcbcbc guibg=#444444',
    TVisible =    '%s cterm=NONE gui=NONE ctermfg=65  ctermbg=235  guifg=#5f875f guibg=#262626',
    THidden =     '%s cterm=NONE gui=NONE ctermfg=242 ctermbg=235  guifg=#6c6c6c guibg=#262626',
    TExtra =      '%s cterm=NONE gui=NONE ctermfg=108 ctermbg=238 guifg=#87af87 guibg=#444444',
    TSpecial =    '%s cterm=NONE gui=NONE ctermfg=235 ctermbg=66  guifg=#262626 guibg=#5f8787',
    TFill =       '%s cterm=NONE gui=NONE ctermfg=242 ctermbg=235 guifg=#6c6c6c guibg=#222222',
    TNumSel =     '%s cterm=NONE gui=NONE ctermfg=101 ctermbg=237 guifg=#87875f guibg=#363636',
    TNum =        '%s cterm=bold gui=bold ctermfg=101 ctermbg=237 guifg=#87875f guibg=#363636',
    TCorner =     '%s cterm=NONE gui=NONE ctermfg=65  ctermbg=235  guifg=#5f875f guibg=#262626',
    TSelectMod =  '%s cterm=bold gui=bold ctermfg=124 ctermbg=238 guifg=#ff6666 guibg=#444444',
    TVisibleMod = '%s cterm=bold gui=bold ctermfg=124 ctermbg=235  guifg=#ff6666 guibg=#262626',
    THiddenMod =  '%s cterm=bold gui=bold ctermfg=124 ctermbg=235  guifg=#ff6666 guibg=#262626',
    TExtraMod =   '%s cterm=bold gui=bold ctermfg=124 ctermbg=235  guifg=#ff6666 guibg=#262626',
    TSelectDim =  '%s cterm=bold gui=bold ctermfg=242 ctermbg=238 guifg=#6c6c6c guibg=#444444',
    TSpecialDim = '%s cterm=NONE gui=NONE ctermfg=242 ctermbg=238 guifg=#6c6c6c guibg=#444444',
    TVisibleDim = '%s cterm=NONE gui=NONE ctermfg=242 ctermbg=235  guifg=#6c6c6c guibg=#262626',
    THiddenDim =  '%s cterm=NONE gui=NONE ctermfg=242 ctermbg=235  guifg=#6c6c6c guibg=#262626',
    TExtraDim =   '%s cterm=NONE gui=NONE ctermfg=242 ctermbg=235  guifg=#6c6c6c guibg=#262626',
    TSelectSep =  '%s cterm=bold gui=bold ctermfg=108 ctermbg=238 guifg=#87af87 guibg=#444444',
    TSpecialSep = '%s cterm=NONE gui=NONE ctermfg=108 ctermbg=238 guifg=#87af87 guibg=#444444',
    TVisibleSep = '%s cterm=NONE gui=NONE ctermfg=242 ctermbg=235  guifg=#6c6c6c guibg=#262626',
    THiddenSep =  '%s cterm=NONE gui=NONE ctermfg=242 ctermbg=235  guifg=#6c6c6c guibg=#262626',
    TExtraSep =   '%s cterm=NONE gui=NONE ctermfg=242 ctermbg=235  guifg=#6c6c6c guibg=#262626',
  }
end

return { theme = theme }
