function! zenn#cmd#init() abort
endfunction

" show error message
function! zenn#cmd#echo_err(msg) abort
  echohl ErrorMsg
  echomsg 'zenn-vim:' a:msg
  echohl None
endfunction

" run command
function! zenn#cmd#run_command(args) abort
  echohl ErrorMsg
  try
    let l:cmd = join(a:000, " ")
    " Todo: verbose or debug mode
    call system(l:cmd)
  catch
    call zenn#cmd#echo_err("Error occured")
  endtry
endfunction

" run npm command
function! zenn#cmd#npm_command(...) abort
  " check node_modules
  if !isdirectory("node_modules")
    echo "node_modules is exists. initialize npm."
    call zenn#cmd#run_command(["npm", "init", "--yes"])
  else
    " Todo: verbose mode
  endif
    return zenn#cmd#run_command(["npm"] + a:000)
endfunction

" run npx zenn command
function! zenn#cmd#zenn_command(...) abort
  return zenn#cmd#run_command(["npx", "zenn"] + a:000)
endfunction
