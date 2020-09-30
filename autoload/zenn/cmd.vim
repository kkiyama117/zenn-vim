function! s:get_job() abort
  if !exists('s:Job')
    let s:Job = vital#zenn#import('System.Job')
  endif
  return s:Job
endfunction

function! s:get_promise() abort
  if !exists('s:Promise')
    let s:Promise = vital#zenn#import('Async.Promise')
  endif
  return s:Promise
endfunction

" show error message
function! zenn#cmd#echo_msg(msg, ...) abort
  if a:0 >= 1
    const l:debug = a:1
  else
    const l:debug = v:false
  endif
  echohl None
  if type(a:msg) == v:t_string
    if l:debug
      echomsg "zenn-vim: " . a:msg
    else
      echo "zenn-vim: " . a:msg
    endif
  elseif type(a:msg) == v:t_list
    const l:msg = l:debug ? join(a:msg) : join(a:msg, "\n")
    if l:debug
      echomsg "zenn-vim: " . l:msg
    else
      echo "zenn-vim:\n" . l:msg
    endif
  endif
endfunction

" show error message
function! zenn#cmd#echo_err(msg, ...) abort
  if a:0 >= 1
    const l:debug = a:1
  else
    const l:debug = v:false
  endif
  echohl ErrorMsg
  if type(a:msg) == v:t_string
    if l:debug
      echomsg "zenn-vim: " . a:msg
    else
      echo "zenn-vim: " . a:msg
    endif
  elseif type(a:msg) == v:t_list
    const l:msg = l:debug ? join(a:msg) : join(a:msg, "\n")
    if l:debug
      echomsg "zenn-vim: " . l:msg
    else
      echo "zenn-vim:\n" . l:msg
    endif
  endif
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

" test
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

" for async + job
function! s:on_receive(buffer, data) abort dict
  let a:buffer[-1] .= a:data[0]
  call extend(a:buffer, a:data[1:])
endfunction

function! s:on_exit_promise(rv, rj, code) abort dict
  return code ? rj(join(stderr, "\n")) : rv(join(stdout, "\n"))
endfunction

" run command as job
function zenn#cmd#run_job(commands) abort
  return s:get_job().start(a:commands, {
        \ 'stdout': ['hoge'],
        \ 'stderr': [''],
        \ 'on_stdout': function('s:on_stdout'),
        \ 'on_stderr': function('s:on_stderr'),
        \ 'on_exit': function('s:on_exit'),
        \})
        " \ 'exit_status': -1,
endfunction

" get command as promice of job
function zenn#cmd#get_job_promise(commands, ...) abort
  const l:chain = exists("a:1") ? a:1 : v:false
  let l:stdout = exists("a:2") ? a:2 : ['']
  let l:stderr = exists("a:3") ? a:3 : ['']
  return s:get_promise().new({
        \ rv, rj -> s:get_job().start(a:commands, {
        \   'on_stdout': function('s:on_receive', [l:stdout]),
        \   'on_stderr': function('s:on_receive', [l:stderr]),
        \   'on_exit': { e ->
        \     e ? rj(join(l:stderr, "\n")) : rv(join(l:stdout, "\n"))
        \   }
        \ })
        \})
endfunction

" run npm command
function! zenn#cmd#npm_command(args) abort
  let l:jobs = []
  " check node_modules
  if !isdirectory("node_modules")
    call zenn#cmd#echo_msg("node_modules does not exist. initializing npm.")
    call add(l:jobs, { -> zenn#cmd#get_job_promise(["npm", "init", "--yes"])})
  else
    " Todo: verbose mode
  endif
  call add(l:jobs, { -> zenn#cmd#get_job_promise(["npm"] + a:args)})
  return s:get_promise().chain(l:jobs)
endfunction

" run npx zenn command
function! zenn#cmd#zenn_command(args) abort
  let l:jobs = []
  " check zenn-cli
  if !filereadable("node_modules/.bin/zenn")
    call zenn#cmd#echo_err("zenn cli is not found! Start installing ...")
    if !isdirectory("node_modules")
      call zenn#cmd#echo_msg("node_modules does not exist. initializing npm ...")
      call add(l:jobs, { -> zenn#cmd#get_job_promise(["npm", "init", "--yes"])})
    endif
    call add(l:jobs, { -> zenn#cmd#get_job_promise(["npm", "i", "zenn-cli"])})
    call add(l:jobs, { -> zenn#cmd#get_job_promise(["npx", "zenn", "init"])})
  endif
  call add(l:jobs, { -> zenn#cmd#get_job_promise(["npx", "zenn"] + a:args)})
  return s:get_promise().chain(l:jobs)
endfunction
