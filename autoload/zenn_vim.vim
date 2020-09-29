" Vim global plugin for zenn.dev
" Last Change: 20200923
" Maintainer: kkiyama117 <k.kiyama117@gmail.com>

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

if has('nvim')
  function! zenn_vim#update() abort
    return _zenn_update()
  endfunction

  function! zenn_vim#preview(...) abort
    return _zenn_preview(a:000)
  endfunction

  function! zenn_vim#stop_preview() abort
    call _zenn_stop_preview()
  endfunction
else
  function! zenn_vim#update() abort
    return zenn_vim#rplugin#update()
  endfunction

  function! zenn_vim#preview() abort
    return zenn_vim#rplugin#preview()
  endfunction

  function! zenn_vim#rplugin#stop_preview() abort
  endfunction
endif

" show error message
function! s:echo_err(msg) abort
  echohl ErrorMsg
  echomsg 'zenn-vim:' a:msg
  echohl None
endfunction

" run command
function! s:run_command(...) abort
  try
    let l:cmd = join(a:000, " ")
    " Todo: verbose or debug mode
    call system(l:cmd)
  catch
    call s:echo_err("Error occured")
  endtry
endfunction

" run npm command
function! s:npm_command(...) abort
  " check node_modules
  if !isdirectory("node_modules")
    echo "node_modules is exists. initialize npm."
    echo call("s:run_command", ["npm" , "init", "--yes"])
  else
    " Todo: verbose mode
  endif
    echo call("s:run_command", ["npm"] + a:000)
endfunction

" run npx zenn command
function! s:zenn_command(...) abort
  return call("s:run_command", ["npx" , "zenn"] + a:000)
endfunction

" ------------------------------------------------------------------------
" zenn_vim#init: Install zenn npm package and call initializer {{{1
"   Usage:  :call zenn_vim#init() -- initialize
function! zenn_vim#init() abort
  echo "zenn initialization start"
  call s:npm_command("init", "--yes")
  " check zenn-cli
  if !filereadable("node_modules/.bin/zenn")
    call s:npm_command("i","zenn-cli")
  else
    echo "`zenn-cli` is already installed. zenn-cli installation is passed."
  endif
  if filereadable("node_modules/.bin/zenn")
    call s:zenn_command("init")
  else
    call s:echo_err("zenn cli is not found!")
    return false
  endif
    echo "zenn initialization successfully finished!"
endfunction

" Create new article.
function! zenn_vim#new_article(...) abort
  if (a:0 >= 4)
    call s:echo_err("too much arguments!")
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
    call s:zenn_command("new:article", l:args_str)
  endif
endfunction

" Create new article.
function! zenn_vim#new_book(slug) abort
  let l:args_str = ""
  if exists("a:slug")
    let l:args_str .= " --slug " . a:slug
  endif
  call s:zenn_command("new:article", l:args_str)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
