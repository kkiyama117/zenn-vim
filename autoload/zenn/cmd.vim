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
" {{{1
function! s:echo_promise(msg) abort
  return s:get_promise().resolve({resolve -> resolve(zenn#echo#echo_msg(a:msg)) })
endfunction
" {{{1
function! s:on_receive(buffer, data) abort dict
  " Remove trailing CRs
  call map(a:data, 'v:val[-1:] ==# "\r" ? v:val[:-2] : v:val')
  call extend (a:buffer, a:data)
endfunction

function! s:on_exit(rv, rj, out, err) abort
  return {e -> e ? a:rj(join(a:err, "\n")) : a:rv(join(a:out, "\n"))}
endfunction

" get command as promice of job {{{1
" Usage
" call zenn#cmd#job('https://github.com/lambdalisue/gina.vim')
"	      \.then({ result -> execute('echo ' . string(result), '') })
"	      \.catch({ result -> execute('echo ' . string(result), '') })
function zenn#cmd#sh(commands) abort
  let l:stdout = ['']
  let l:stderr = ['']
  return s:get_promise().new({
        \ rv, rj -> s:get_job().start(a:commands, {
        \   'on_stdout': function('s:on_receive', [l:stdout]),
        \   'on_stderr': function('s:on_receive', [l:stderr]),
        \   'on_exit': s:on_exit(rv, rj, l:stdout, l:stderr)
        \ })
        \})
endfunction

function! s:initNpm() abort
  return zenn#cmd#sh(["npm", "init", "--yes"])
        \.then({ -> zenn#echo#echo_msg("npm init finished")})
        \.catch({ -> zenn#echo#echo_err("npm initialization was failed")})
endfunction

function! s:installNpm() abort
  let l:jobs = []
  if !filereadable("package.json")
    call add(l:jobs, { -> s:echo_promise("package.json is not found! start initialization ...")})
    call add(l:jobs, { -> s:initNpm()})
  endif
  return s:get_promise().chain(l:jobs)
endfunction

" run npm command {{{1
function! zenn#cmd#npm_promise(args) abort
  let l:jobs = []
  if !isdirectory("node_modules")
    call add(l:jobs, { -> s:echo_promise("node_modules are not found! start installing ...")})
    call add(l:jobs, { -> s:installNpm()})
  endif
  call add(l:jobs, { -> zenn#cmd#sh(["npm"] + a:args)})
  return s:get_promise().chain(l:jobs)
endfunction

function s:installZenn() abort
  let l:jobs = []
  " check node_modules
  if !isdirectory("node_modules")
    call add(l:jobs, { -> s:echo_promise("node_modules are not found! start installing ...")})
    call add(l:jobs, { -> s:installNpm()})
  endif
  if !filereadable("node_modules/.bin/zenn")
    call add({ -> s:echo_promise("zenn_cli is not found! start installing ...")})
    call add(l:jobs, zenn#cmd#sh(["npm", "i", "zenn-cli@latest"])
          \.then({ out -> zenn#echo#echo_msg("zenn-cli is installed!")})
          \.catch({ out -> zenn#echo#echo_err("instaiilng zenn-cli failed")})
          \)
  endif
  return s:get_promise().chain(l:jobs)
endfunction

" Initialize process
function s:initZenn() abort
  let l:jobs = []
  if !filereadable("node_modules/.bin/zenn")
    call add({ -> s:echo_promise("zenn_cli is not found! start installing")})
    call add(l:jobs, zenn#cmd#sh(["npm", "i", "zenn-cli@latest"])
          \.then({ out -> zenn#echo#echo_msg("zenn-cli is installed!")})
          \.catch({ out -> zenn#echo#echo_err("instaiilng zenn-cli failed")})
          \)
    call s:installZenn()
  endif
  if !isdirectory("articles") || !isdirectory("books")
    call zenn#cmd#sh(["npx", "zenn", "init"]).then(out ->zenn#echo#echo_msg(
          \ "zenn cli initialization finished."
          \))
  endif
endfunction

" run npx zenn command {{{1
function! zenn#cmd#zenn_promise(args) abort
  let l:jobs = s:initZennPromiseList()
  s:get_promise().new({re, rv ->
        \ []
        \})
  call add(l:jobs, { -> s:sh(["npx", "zenn"] + a:args)})
  return s:get_promise().chain(l:jobs)
endfunction

" run npx zenn command {{{1
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
