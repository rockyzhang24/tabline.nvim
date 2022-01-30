let s:file = fnamemodify(expand('<sfile>'), ':p:h:h') . '/config'

function! tabline#config()
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
    silent! delcommand TablineConfig
endfunction
