" Vim global plugin for zenn.dev
" Last Change: 20200923
" Maintainer: kkiyama117 <k.kiyama117@gmail.com>

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" Functions
" ------------------------------------------------------------------------
" zenn#new_article: Create new article. {{{1
"   Usage:  :call zenn#new_article() -- create new article
"           :call zenn#new_article(slug) -- create new article with slug.
"           :call zenn#new_article(slug, title, type, emoji) -- create new article with args.
function! zenn#new_article(...) abort
  if (a:0 >= 4)
    call zenn#echo#echo_err("too much arguments!")
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
    let l:args = []
    for [key,value] in items(l:args_dict)
      call add(l:args, "--" . key)
      call add(l:args, value)
    endfor
    call zenn#cmd#zenn_promise(["new:article"] + l:args)
      \.then(
      \  { arr -> zenn#echo#echo_msg(arr)})
      \.catch(
      \  { arr -> zenn#echo#echo_err(arr)}
      \ )
  endif
endfunction

" ------------------------------------------------------------------------
" zenn#new_book: Create new book. {{{1
"   Usage:  :call zenn#new_book() -- create new book.
function! zenn#new_book(...) abort
  const l:args = empty(a:000) ? [] : ["--slug", a:1]
  call zenn#cmd#zenn_promise(["new:book"] + l:args)
      \.then(
      \  { arr -> zenn#echo#echo_msg(arr)})
      \.catch(
      \  { arr -> zenn#echo#echo_err(arr)}
      \ )
endfunction

" ------------------------------------------------------------------------
" zenn#update: Update zenn npm package. {{{1
"   Usage:  :call zenn#update() -- update
function! zenn#update() abort
  call zenn#echo#echo_msg( "zenn-cli is updating ...")
  return zenn#cmd#zenn_update()
      \.then(
      \  { arr -> zenn#echo#echo_msg(arr)})
      \.catch(
      \  { arr -> zenn#echo#echo_err(arr)}
      \ )
      \.finally({ -> zenn#echo#echo_msg("zenn#update finished")})
endfunction

function! zenn#help() abort
  call zenn#cmd#zenn_promise(["help"])
      \.then(
      \  { arr -> zenn#echo#echo_msg(arr)})
      \.catch(
      \  { arr -> zenn#echo#echo_err(arr)}
      \ )
endfunction


" ------------------------------------------------------------------------
" zenn#preview: start preview server. {{{1
"   Usage:  :call zenn#preview() -- start server on localhost:8000`
"           :call zenn#preview(port) -- start server on localhost:{port}`
function! zenn#preview(...) abort
  return zenn#preview#preview(exists("a:1") ? a:1 : "8000")
endfunction

" ------------------------------------------------------------------------
" zenn#stop_preview: start preview server. {{{1
"   Usage:  :call zenn#stop_preview() -- stop server.
function! zenn#stop_preview() abort
  return zenn#preview#stop_preview()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
