if !has('nvim') || exists('g:loaded_tabline_nvim')
    finish
endif
let g:loaded_tabline_nvim = 1

command! -bar TablineConfig call tabline#config()

nnoremap <Plug>(TabSelect) <Cmd>call v:lua.require'tabline.cmds'.select_tab_with_char(v:count)<cr>

fun! BuflineClick(nr, clicks, button, mod)
    call v:lua.require'tabline.bufs'.click(a:nr, a:clicks, a:button, a:mod)
endfun

fun! CloseButtonClick(nr, clicks, button, mod)
    call v:lua.require'tabline.bufs'.close(a:nr, a:clicks, a:button, a:mod)
endfun
