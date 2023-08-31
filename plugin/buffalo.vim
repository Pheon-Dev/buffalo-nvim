if exists('g:loaded_buffalo') | finish | endif

function! s:complete(...)
  return "buffers"
endfunction

command! -nargs=1 -complete=custom,s:complete Buffalo lua require'buffalo'.<args>()

let g:loaded_buffalo = 1

