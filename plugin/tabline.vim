if !has('nvim') || exists('g:loaded_tabline_nvim')
    finish
endif
let g:loaded_tabline_nvim = 1

if luaeval("require'tabline.setup'.ran_once") == v:false
    command! -bar TablineConfig call tabline#config()
endif

nnoremap <Plug>(TabSelect) <Cmd>call v:lua.require'tabline.cmds'.select_tab_with_char(v:count)<cr>

fun! Buflineclick(nr, clicks, button, mod)
    call v:lua.require'tabline.bufs'.click(a:nr, a:clicks, a:button, a:mod)
endfun
