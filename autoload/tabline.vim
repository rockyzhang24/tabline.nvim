
let s:file = fnamemodify(expand('<sfile>'), ':p:h:h') . '/config'

function! tabline#config() abort
    new
    exe 'read' s:file
    setfiletype lua
    1d _
endfunction
