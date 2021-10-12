if !has('nvim')
    finish
endif

augroup tabline
    au!
    au ColorScheme * lua require'tabline.render.icons'.icons = {}
    au ColorScheme * call TablineTheme()
augroup END

fun! TablineTheme() abort
  hi! link TSelect         Pmenu
  hi! link TVisible        Special
  hi! link THidden         Normal
  hi! link TExtra          Visual
  hi! link TSpecial        IncSearch
  hi! link TFill           Folded
  hi! link TNumSel         TabLineSel
  hi! link TNum            TabLineSel
  hi! link TCorner         Special

  let pat = has('gui_running') || &termguicolors ? 'guibg=\S\+' : 'ctermbg=\S\+'
  try
    exe 'hi TSelectMod'  matchstr(execute('hi PmenuSel'), pat) 'guifg=#af0000 gui=bold cterm=bold'
  catch
    hi! link TSelectMod PmenuSel
  endtry
  try
    exe 'hi TVisibleMod' matchstr(execute('hi Special'), pat) 'guifg=#af0000 gui=bold cterm=bold'
  catch
    hi! link TVisibleMod Special
  endtry
  try
    exe 'hi THiddenMod'  matchstr(execute('hi TabLine'), pat) 'guifg=#af0000 gui=bold cterm=bold'
  catch
    hi! link THiddenMod TabLine
  endtry
  try
    exe 'hi TExtraMod'   matchstr(execute('hi Visual'), pat) 'guifg=#af0000 gui=bold cterm=bold'
  catch
    hi! link TExtraMod Visual
  endtry
endfun
call TablineTheme()


lua require'tabline.setup'.setup()

set tabline=%!v:lua.require'tabline'.render()

command! TabInfo lua require'tabline.setup'.info()

command! BufLines exe "lua require'tabline.setup'.tabline.v.mode = 'buffers'" | edit
command! Tabline exe "lua require'tabline.setup'.tabline.v.mode = 'tabs'" | edit
