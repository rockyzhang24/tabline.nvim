let s:file = fnamemodify(expand('<sfile>'), ':p:h:h') . '/config'

function! tabline#config()
    new
    exe 'read' s:file
    setfiletype lua
    1d _
    silent! delcommand TablineConfig
endfunction
