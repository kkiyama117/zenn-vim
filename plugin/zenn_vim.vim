scriptencoding utf-8

if exists('g:loaded_zenn_vim')
  finish
endif
let g:loaded_zenn_vim = 1

let s:save_cpo = &cpo
set cpo&vim

" npx zenn init
command! -nargs=0 ZennInit call zenn_vim#init()
" npx zenn preview
command! -nargs=* ZennPreview call zenn_vim#preview(<args>)
" npm install zenn-cli@latest
command! -nargs=0 ZennUpdate call zenn_vim#cli_update()

let s:save_cpo = &cpo
set cpo&vim
