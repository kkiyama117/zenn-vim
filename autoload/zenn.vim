" Vim global plugin for zenn.dev
" Last Change: 20200923
" Maintainer: kkiyama117 <k.kiyama117@gmail.com>

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" Functions

" ------------------------------------------------------------------------
" zenn#init: Install zenn npm package and call initializer {{{1
"   Usage:  :call zenn#init() -- initialize
function! zenn#init() abort
  echo "zenn initialization start ..."
  call zenn#cmd#npm_command(["init", "--yes"])
  " check zenn-cli
  if !filereadable("node_modules/.bin/zenn")
    call zenn#cmd#npm_command(["i","zenn-cli"])
  else
    echo "`zenn-cli` is already installed. zenn-cli installation is passed."
  endif
  if filereadable("node_modules/.bin/zenn")
    call zenn#cmd#zenn_command(["init"])
  else
    call zenn#cmd#echo_err("zenn cli is not found!")
    return false
  endif
    echo "zenn initialization successfully finished!"
endfunction

" ------------------------------------------------------------------------
" zenn#new_article: Create new article. {{{1
"   Usage:  :call zenn#new_article() -- create new article
"           :call zenn#new_article(slug) -- create new article with slug.
"           :call zenn#new_article(slug, title, type, emoji) -- create new article with args.
"
function! zenn#new_article(...) abort
  if (a:0 >= 4)
    call zenn#cmd#echo_err("too much arguments!")
  else
    let l:args_dict = {}
    if exists("a:4")
      let l:args_dict["emoji"] = a:4
    endif
    if exists("a:3")
      let l:args_dict["type"] = a:3
    endif
    if exists("a:2")
      let l:args_dict["title"] = a:2
    endif
    if exists("a:1")
      let l:args_dict["slug"] = a:1
    endif
    " create args from dict
    let l:args_str = ""
    for [key,value] in items(l:args_dict)
      let l:args_str .= " --" . key . " " . value
    endfor
    call zenn#cmd#zenn_command(["new:article", l:args_str])
  endif
endfunction

" ------------------------------------------------------------------------
" zenn#new_book: Create new book. {{{1
"   Usage:  :call zenn#new_book() -- create new book.
function! zenn#new_book(slug) abort
  let l:args_str = ""
  if exists("a:slug")
    let l:args_str .= " --slug " . a:slug
  endif
  call zenn#cmd#zenn_command(["new:book", l:args_str])
    echo "zenn create book"
endfunction

" ------------------------------------------------------------------------
" zenn#update: Update zenn npm package. {{{1
"   Usage:  :call zenn#update() -- update
function! zenn#update() abort
  return s:zenn_update()
endfunction

" ------------------------------------------------------------------------
" zenn#preview: start preview server. {{{1
"   Usage:  :call zenn#preview() -- start server on localhost:8000`
"           :call zenn#preview(port) -- start server on localhost:{port}`
function! zenn#preview(...) abort
  return s:_zenn_preview((empty(a:000) ? [] : [a:1]))
endfunction

" Call Python func(Correspondence for difference vim8 and neovim)
if has('nvim')
  function! s:zenn_update() abort
    call _zenn_update()
  endfunction

  function! s:zenn_preview(args) abort
    call _zenn_preview(a:args)
  endfunction

  function! s:zenn_stop_preview() abort
    call _zenn_stop_preview()
  endfunction
else
  function! s:zenn_update() abort
    call zenn#rplugin#update()
  endfunction

  function! s:zenn_preview(args) abort
    call zenn#rplugin#preview(a:args)
  endfunction

  function! s:zenn_stop_preview() abort
  endfunction
endif

let &cpo = s:save_cpo
unlet s:save_cpo
