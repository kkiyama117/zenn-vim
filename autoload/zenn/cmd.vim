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

" =============================================================================
function! s:echo_promise(msg)
  return s:get_promise().new({_ -> zenn#echo#echo_msg(a:msg)})
endfunction

function! s:echo_err_promise(msg)
  return s:get_promise().new({_ -> zenn#echo#echo_err(a:msg)})
endfunction

function! s:on_receive(buffer, data) abort dict
  call extend(a:buffer, a:data)
endfunction

function! s:on_exit_promise(rv, rj, code) abort dict
  return code ? rj(join(stderr, "\n")) : rv(join(stdout, "\n"))
endfunction

" get command as promice of job
function s:sh(commands, ...) abort
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

function s:initNpmPromiseList() abort
  let l:jobs = []
  " check node_modules
    if !isdirectory("node_modules")
      call add(l:jobs, { -> s:echo_promise("node_modules does not exist." 
            \." initializing npm ...")})
      call add(l:jobs, { -> s:sh(["npm", "init", "--yes"])})
      call add(l:jobs, { -> s:echo_promise("npm initialized.")})
    endif
  return l:jobs
endfunction

" run npm command
function! zenn#cmd#npm_promise(args) abort
  let l:jobs = s:initNpmPromiseList()
  call add(l:jobs, { -> s:sh(["npm"] + a:args)})
  return s:get_promise().chain(l:jobs)
endfunction

" Initialize process
function s:initZennPromiseList() abort
  let l:jobs = s:initNpmPromiseList()
  " check zenn-cli
  if !filereadable("node_modules/.bin/zenn")
    call add(l:jobs, { -> s:echo_promise("zenn cli is not found!" . 
          \" Start installing ...")})
    call add(l:jobs, { -> s:sh(["npm", "i", "zenn-cli@latest"])})
    call add(l:jobs, { -> s:echo_promise("zenn cli is installed!")})
    call add(l:jobs, { -> s:sh(["npx", "zenn", "init"])})
  elseif !isdirectory("articles") || !isdirectory("books")
    call add(l:jobs, { -> s:sh(["npx", "zenn", "init"])})
  endif
  call add(l:jobs, { -> s:echo_promise("zenn cli initialization finished.")})
  return l:jobs
endfunction

" run npx zenn command
function! zenn#cmd#zenn_promise(args) abort
  let l:jobs = s:initZennPromiseList()
  call add(l:jobs, { -> s:sh(["npx", "zenn"] + a:args)})
  return s:get_promise().chain(l:jobs)
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

  " run npx zenn command
function! zenn#cmd#zenn_job(args) abort
  let l:jobs = s:initZennPromiseList()
  if empty(l:jobs)
    let l:chain =s:get_promise().chain(l:jobs)
    let [result, error] = s:get_promise().wait(l:chain)
    if error isnot# v:null
      echoerr "Init Failed:" . string(error)
      return v:null
    endif
  endif
  return s:get_job().start(['npx', 'zenn'] + a:args, {
          \ 'stdout': [''],
          \ 'stderr': [''],
          \ 'on_stdout': function('s:on_stdout'),
          \ 'on_stderr': function('s:on_stderr'),
          \ 'on_exit': function('s:on_exit'),
          \})
endfunction
