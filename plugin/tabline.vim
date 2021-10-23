if !has('nvim')
    finish
endif

augroup tabline
    au!
    au ColorScheme * lua require'tabline.render.icons'.icons = {}
    au ColorScheme * lua require'tabline.setup'.load_theme(true)
    au TabNew      * lua require'tabline.tabs'.init_tabs()
    au BufAdd      * lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
    au BufEnter    * lua require'tabline.bufs'.recent_buf(tonumber(vim.fn.expand('<abuf>')))
    au BufUnload   * lua require'tabline.bufs'.remove_buf(tonumber(vim.fn.expand('<abuf>')))
    au OptionSet buf lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
    au FileType    * lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
    au TermEnter   * lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
    au TabLeave    * lua require'tabline.tabs'.store()
    au TabClosed   * lua require'tabline.tabs'.save()
augroup END

nnoremap <expr><silent> <Plug>(TabSelect) v:lua.require'tabline.cmds'.select_tab(v:count)

fun! Buflineclick(nr, clicks, button, mod)
    call v:lua.buflineclick(a:nr, a:clicks, a:button, a:mod)
endfun
