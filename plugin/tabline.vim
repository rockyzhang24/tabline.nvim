if !has('nvim') || exists('g:loaded_tabline_nvim')
    finish
endif
let g:loaded_tabline_nvim = 1

if luaeval("require'tabline.setup'.run_once") == v:false
    command! -bar TablineConfig call tabline#config()
endif

augroup tabline
    au!
    au ColorScheme *  lua require'tabline.setup'.load_theme(true)
    au TabNew      *  lua require'tabline.tabs'.init_tabs()
    au BufAdd      *  lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
    au BufEnter    *  lua require'tabline.bufs'.recent_buf(tonumber(vim.fn.expand('<abuf>')))
    au BufUnload   *  lua require'tabline.bufs'.remove_buf(tonumber(vim.fn.expand('<abuf>')))
    au BufDelete   *  lua require'tabline.bufs'.remove_buf(tonumber(vim.fn.expand('<abuf>')))
    au OptionSet buf* lua require'tabline.bufs'.add_file(vim.fn.expand('<afile>'))
    au FileType    *  lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
    au TermEnter   *  lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
    au TabLeave    *  lua require'tabline.tabs'.store()
    au TabClosed   *  lua require'tabline.tabs'.save()
augroup END

nnoremap <Plug>(TabSelect) <Cmd>call v:lua.require'tabline.cmds'.select_tab_with_char(v:count)<cr>

fun! Buflineclick(nr, clicks, button, mod)
    call v:lua.buflineclick(a:nr, a:clicks, a:button, a:mod)
endfun
