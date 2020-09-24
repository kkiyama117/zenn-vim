scriptencoding utf-8

if exists('g:loaded_zenn_vim')
  finish
endif
let g:loaded_zenn_vim = 1

let s:save_cpo = &cpo
set cpo&vim

" npx zenn init
command! -nargs=0 ZennInit call ZennVim#zenn_init()
" npx zenn preview
command! -nargs=* ZennPreview call ZennVim#zenn_preview(<args>)
" npm install zenn-cli@latest
command! -nargs=0 ZennUpdate call ZennVim#zenn_update()

let s:save_cpo = &cpo
set cpo&vim
