scriptencoding utf-8

if exists('g:loaded_zenn_vim')
  finish
endif
let g:loaded_zenn_vim = 1

let s:save_cpo = &cpo
set cpo&vim

" pynvim function
" npx zenn init
command! -nargs=0 ZennInit call zenn_vim#init()
" npm install zenn-cli@latest
command! -nargs=0 ZennUpdate call zenn_vim#update()
" npx zenn preview
command! -nargs=* ZennPreview call zenn_vim#preview(<f-args>)
" npx zenn preview
command! -nargs=0 ZennStopPreview call zenn_vim#stop_preview()

" normal vim function
" npx zenn new article
command! -nargs=* ZennNewArticle call zenn_vim#new_article(<f-args>)
" npx zenn new book
command! -nargs=* ZennNewArticle call zenn_vim#new_book(<f-args>)

let s:save_cpo = &cpo
set cpo&vim
