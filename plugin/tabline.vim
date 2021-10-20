if !has('nvim')
    finish
endif

lua require'tabline.setup'.setup()

augroup tabline
    au!
    au ColorScheme * lua require'tabline.render.icons'.icons = {}
    au ColorScheme * call TablineTheme()
    au TabNew      * lua require'tabline.tabs'.init_tabs()
    au BufAdd      * lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
    au BufUnload   * lua require'tabline.setup'.tabline.buffers[tonumber(vim.fn.expand('<abuf>'))] = nil
    au OptionSet buf lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
    au FileType    * lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
    au TabLeave    * lua require'tabline.tabs'.store()
    au TabClosed   * lua require'tabline.tabs'.save()
augroup END

fun! TablineTheme() abort   " {{{1
  hi! link TSelect         Pmenu
  hi! link TVisible        Special
  hi! link THidden         Comment
  hi! link TExtra          Title
  hi! link TSpecial        PmenuSel
  hi! link TFill           Folded
  hi! link TNumSel         TabLineSel
  hi! link TNum            TabLineSel
  hi! link TCorner         Special

  let pat = has('gui_running') || &termguicolors ? 'guibg=\S\+' : 'ctermbg=\S\+'
  let bg = matchstr(execute('hi Normal'), pat)
  exe "lua require'tabline.render.icons'.normalbg = " .. string(bg[1:])
  exe "lua require'tabline.render.icons'.dimfg = " .. string(&bg == 'dark' ? '6c6c6c' : 'a9a9a9')
  try
    exe 'hi TSelectMod'  matchstr(execute('hi Pmenu'), pat) 'guifg=#af0000 gui=bold cterm=bold'
  catch
    hi! link TSelectMod Pmenu
  endtry
  try
    exe 'hi TVisibleMod' matchstr(execute('hi Special'), pat) 'guifg=#af0000 gui=bold cterm=bold'
  catch
    hi! link TVisibleMod Special
  endtry
  try
    exe 'hi THiddenMod'  matchstr(execute('hi Comment'), pat) 'guifg=#af0000 gui=bold cterm=bold'
  catch
    hi! link THiddenMod Comment
  endtry
  try
    exe 'hi TExtraMod'   matchstr(execute('hi Title'), pat) 'guifg=#af0000 gui=bold cterm=bold'
  catch
    hi! link TExtraMod Title
  endtry
endfun "}}}
call TablineTheme()

nnoremap <expr><silent> <Plug>(TabSelect) v:lua.require'tabline.cmds'.select_tab(v:count)

set tabline=%!v:lua.require'tabline'.render()
