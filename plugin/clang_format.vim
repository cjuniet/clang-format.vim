" File: plugin/clang_format.vim
" Description: clang-format support for VIM
" Author: Christophe Juniet
" Repository: https://github.com/cjuniet/clang-format.vim
" License: http://creativecommons.org/licenses/by/4.0/

if exists("g:loaded_clang_format")
  finish
endif
let g:loaded_clang_format = 1

command! ClangFormat call clang_format#Reformat(0)

nmap <silent> <C-K> :call clang_format#Reformat(0)<CR>
vmap <silent> <C-K> :call clang_format#Reformat(1)<CR>
