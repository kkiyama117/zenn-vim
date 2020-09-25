" Vim global plugin for zenn.dev
" Last Change: 20200923
" Maintainer: kkiyama117 <k.kiyama117@gmail.com>

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" Install zenn-cli and create templates.
function! zenn_vim#init() abort
  echo "zenn initialization start"
  " check node_modules
  if !finddir("node_modules")
    s:npm_command("init", "--yes")
  else
    echo "node_modules already exists. npm initialization is passed."
  endif
  " check zenn-cli
  if !findfile("node_modules/.bin/zenn")
    s:npm_command("i","zenn-cli")
  else
    echo "`zenn-cli` is already installed. zenn-cli installation is passed."
  endif
  if findfile("node_modules/.bin/zenn")
    s:zenn_command("init")
  else
    s:echo_err("zenn cli is not found!")
  endif
endfunction

" Update zenn-cli with fetching new one from npm.
function! zenn_vim#cli_update() abort
  return s:npm_command("install", "zenn-cli@latest")
endfunction

" Update zenn-cli with fetching new one from npm.
function! zenn_vim#preview(...) abort
  return s:zenn_command("preview", join(a:000))
endfunction

" run npm command
function! s:npm_command(...) abort
    return s:run_command("npm", join(a:000))
endfunction

" run npx zenn command
function! s:zenn_command(...) abort
    return s:run_command("npx", "zenn", join(a:000))
endfunction

function! s:run_command(...) abort
  try
    return execute(a:000)
  catch
    echo_err("Invalid arguments type")
    finish
  endtry
endfunction

function! s:echo_err(msg) abort
  echohl ErrorMsg
  echomsg 'zenn-vim:' a:msg
  echohl None
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
