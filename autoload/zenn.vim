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
      \  { result -> zenn#echo#echo_msg(result)},
      \  { result -> zenn#echo#echo_err(result)},
      \ )
      \.finally({ result -> zenn#echo#echo_msg("zenn#new_article finished")})
  endif
endfunction

" ------------------------------------------------------------------------
" zenn#new_book: Create new book. {{{1
"   Usage:  :call zenn#new_book() -- create new book.
function! zenn#new_book(...) abort
  const l:args = empty(a:000) ? [] : ["--slug", a:1]
  call zenn#cmd#zenn_promise(["new:book"] + l:args)
      \.then(
      \  { result -> zenn#echo#echo_msg(result)},
      \  { result -> zenn#echo#echo_err(result)},
      \ )
      \.finally({ result -> zenn#echo#echo_msg("zenn#new_book finished")})
endfunction

" ------------------------------------------------------------------------
" zenn#update: Update zenn npm package. {{{1
"   Usage:  :call zenn#update() -- update
function! zenn#update() abort
  call zenn#echo#echo_msg( "zenn-cli is updating ...")
  return zenn#cmd#npm_promise(["i", "zenn-cli@latest"])
      \.then(
      \  { arr -> zenn#echo#echo_msg(arr)},
      \  { arr -> zenn#echo#echo_err(arr)}
      \ )
      \.finally({ result -> zenn#echo#echo_msg("zenn#update finished")})
endfunction

function s:server(command)
  let l:preview_job = zenn#cmd#zenn_job(a:command)
  " wait
  call l:preview_job.wait(3000)
  if l:preview_job.status() == "run" && !empty(l:preview_job.stdout)
      call zenn#echo#echo_msg(l:preview_job.stdout)
  else
      call zenn#echo#echo_err("preview failed:")
      call zenn#echo#echo_err(l:preview_job.stderr)
      call l:preview_job.stop()
      let l:preview_job = v:null
  endif
  return l:preview_job
endfunction

" ------------------------------------------------------------------------
" zenn#preview: start preview server. {{{1
"   Usage:  :call zenn#preview() -- start server on localhost:8000`
"           :call zenn#preview(port) -- start server on localhost:{port}`
function! zenn#preview(...) abort
  const l:port = exists("a:1") ? type(a:1) == v:t_string ? a:1 
        \: string(a:1) : v:null
  const l:command = exists("a:1") ? ["preview", "--port", l:port]
    \: ["preview"]
  const l:port_str = exists("a:1") ? a:1 : "8000"
  if exists("s:preview_job") && !empty(s:preview_job)
    call zenn#echo#echo_msg("preview is already running")
    return
  else
    call zenn#echo#echo_msg("zenn-cli try starting preview server on"
        \. " localhost: " . l:port_str . "...")
  endif
  let s:preview_job = zenn#cmd#zenn_promise(s:server(l:command))
  if type(s:preview_job) == v:null
    call zenn#echo#echo_msg("preview job is not created")
    return
  endif
endfunction

" ------------------------------------------------------------------------
" zenn#stop_preview: start preview server. {{{1
"   Usage:  :call zenn#stop_preview() -- stop server.
function! zenn#stop_preview() abort
  if exists("s:preview_job") && !empty(s:preview_job)
    call s:preview_job.stop()
    let s:preview_job = {}
    call zenn#echo#echo_msg("preview is stopped!")
  else
    call zenn#echo#echo_msg("preview is not running")
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
