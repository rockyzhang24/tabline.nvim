let s:file = fnamemodify(expand('<sfile>'), ':p:h:h') . '/config'

function! tabline#config()
    lua require'tabline.setup'.setup()
    -tabnew
    exe 'read' s:file
    setfiletype lua
    1d _
    try
        help tnv-settings
        wincmd L
        normal! zt
        wincmd p
    catch
    endtry
endfunction

function! tabline#init() abort
    augroup tabline
        au!
        au OptionSet termguicolors lua require'tabline.setup'.load_theme(true)
        au OptionSet background lua require'tabline.setup'.load_theme(true)
        au ColorScheme *  lua require'tabline.setup'.load_theme(true)
        au TabNew      *  lua require'tabline.tabs'.init_tabs()
        au BufAdd      *  lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
        au BufFilePost *  lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
        au BufEnter    *  lua require'tabline.bufs'.recent_buf(tonumber(vim.fn.expand('<abuf>')))
        au BufUnload   *  lua require'tabline.bufs'.remove_buf(tonumber(vim.fn.expand('<abuf>')))
        au BufDelete   *  lua require'tabline.bufs'.remove_buf(tonumber(vim.fn.expand('<abuf>')))
        au OptionSet buf* lua require'tabline.bufs'.add_file(vim.fn.expand('<afile>'))
        au FileType    *  lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
        au TermEnter   *  lua require'tabline.bufs'.add_buf(tonumber(vim.fn.expand('<abuf>')))
        au TabLeave    *  lua require'tabline.tabs'.store()
        au TabClosed   *  lua require'tabline.tabs'.save()
        au VimLeave    *  lua require'tabline.persist'.update_persistance()
        au SessionLoadPost * lua require'tabline.bufs'.session_post_clean_up()
    augroup END
    if !v:vim_did_enter
        au tabline VimEnter * ++once exe 'lua require"tabline.bufs".init_bufs()'
                    \|               exe 'lua require"tabline.tabs".init_tabs()'
                    \|               silent! delcommand TablineConfig
    endif
    set tabline=%!v:lua.require'tabline.tabline'.render()
endfunction
