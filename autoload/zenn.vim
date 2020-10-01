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
    let l:args = []
    for [key,value] in items(l:args_dict)
      call add(l:args, "--" . key)
      call add(l:args, value)
    endfor
    call zenn#cmd#zenn_command(["new:article"] + l:args)
      \.then(
      \  { result -> zenn#cmd#echo_msg(result)},
      \  { result -> zenn#cmd#echo_err(result)},
      \ )
      \.finally({ result -> zenn#cmd#echo_msg("zenn#new_article finished")})
  endif
endfunction

" ------------------------------------------------------------------------
" zenn#new_book: Create new book. {{{1
"   Usage:  :call zenn#new_book() -- create new book.
function! zenn#new_book(...) abort
  const l:args = empty(a:000) ? [] : ["--slug", a:1]
  call zenn#cmd#zenn_command(["new:book"] + l:args)
      \.then(
      \  { result -> zenn#cmd#echo_msg(result)},
      \  { result -> zenn#cmd#echo_err(result)},
      \ )
      \.finally({ result -> zenn#cmd#echo_msg("zenn#new_book finished")})
endfunction

" ------------------------------------------------------------------------
" zenn#update: Update zenn npm package. {{{1
"   Usage:  :call zenn#update() -- update
function! zenn#update() abort
  call zenn#cmd#echo_msg( "zenn-cli is updating ...")
  call zenn#cmd#npm_command(["i", "zenn-cli@latest"])
      \.then(
      \  { result -> zenn#cmd#echo_msg(result)},
      \  { result -> zenn#cmd#echo_err(result)},
      \ )
      \.finally({ result -> zenn#cmd#echo_msg("zenn#update finished")})
endfunction

" ------------------------------------------------------------------------
" zenn#preview: start preview server. {{{1
"   Usage:  :call zenn#preview() -- start server on localhost:8000`
"           :call zenn#preview(port) -- start server on localhost:{port}`
function! zenn#preview(...) abort
  const l:port = exists("a.1") ? a:1 : v:null
  const l:port_str = exists("a.1") ? a:1 : "8000"
  call zenn#cmd#echo_msg( "zenn-cli start on localhost:" . l:port_str . "...")
  let l:command = ["preview"]
  if l:port != v:null
    l:command = l:command + ["--port", l:port_str]
  endif
  call zenn#cmd#zenn_command(["preview"] + l:command)
      \.then(
      \  { result -> zenn#cmd#echo_msg(result)},
      \  { result -> zenn#cmd#echo_err(result)},
      \ )
      \.finally({ result -> zenn#cmd#echo_msg("zenn#preview" . "finished")})
"  return s:_zenn_preview((empty(a:000) ? [] : [a:1]))
endfunction


" ------------------------------------------------------------------------
" zenn#stop_preview: start preview server. {{{1
"   Usage:  :call zenn#stop_preview() -- stop server.
function! zenn#stop_preview(job) abort
  call a:job.kill()
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
