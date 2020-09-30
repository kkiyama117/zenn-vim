function! zenn#cmd#init() abort
  let s:V = vital#zenn#new()
  let s:Job = s:V.import('System.Job')
	let s:Promise = vital#vital#import('Async.Promise')
endfunction

" show error message
function! zenn#cmd#echo_err(msg) abort
  echohl ErrorMsg
  echomsg 'zenn-vim:' a:msg
  echohl None
endfunction

" run command
function! zenn#cmd#run_command(args) abort
  try
    let l:cmd = join(a:args, " ")
    " Todo: verbose or debug mode
    echomsg system(l:cmd)
  catch
    call zenn#cmd#echo_err("Error occured")
  endtry
endfunction

" run command as job
function zenn#cmd#run_job(args) abort
  return call(s:V.system, a:args, s:V)
endfunction

function! s:on_stdout(data) abort dict
  let self.stdout[-1] .= a:data[0]
  call extend(self.stdout, a:data[1:])
endfunction
function! s:on_stderr(data) abort dict
  let self.stderr[-1] .= a:data[0]
  call extend(self.stderr, a:data[1:])
endfunction
function! s:on_exit(exitval) abort dict
  let self.exit_status = a:exitval
endfunction


" run npm command
function! zenn#cmd#npm_command(args) abort
  " check node_modules
  if !isdirectory("node_modules")
    echo "node_modules is exists. initialize npm."
    call zenn#cmd#run_command(["npm", "init", "--yes"])
  else
    " Todo: verbose mode
  endif
    return zenn#cmd#run_command(["npm"] + a:args)
endfunction

" run npx zenn command
function! zenn#cmd#zenn_command(args) abort
  return zenn#cmd#run_command(["npx", "zenn"] + a:args)
endfunction
