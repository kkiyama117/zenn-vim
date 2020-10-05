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
function s:echo_promise(msg) abort
  return s:get_promise().resolve({resolve -> resolve(zenn#echo#echo_msg(a:msg)) })
endfunction
" {{{1
function s:on_receive(buffer, data) abort dict
  " Remove trailing CRs
  call map(a:data, 'v:val[-1:] ==# "\r" ? v:val[:-2] : v:val')
  call extend (a:buffer, a:data)
endfunction

function s:on_exit(rv, rj, out, err) abort
  return {e -> e ? a:rj(join(a:err, "\n")) : a:rv(join(a:out, "\n"))}
endfunction

" get command as promice of job {{{1
" Usage
" call zenn#cmd#job('https://github.com/lambdalisue/gina.vim')
"	      \.then({ result -> execute('echo ' . string(result), '') })
"	      \.catch({ result -> execute('echo ' . string(result), '') })
function! zenn#cmd#sh(commands) abort
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

function s:initNpm() abort
  let l:jobs = []
  if !filereadable("package.json")
    call add(l:jobs, { -> s:echo_promise("package.json is not found! start initialization ...")})
    call add(l:jobs, { -> zenn#cmd#sh(["npm", "init", "--yes"])
          \.then({ -> zenn#echo#echo_msg("npm init finished")})
          \.catch({ -> zenn#echo#echo_err("npm initialization was failed")})
          \})
  else
    call add(l:jobs, { -> s:echo_promise("package.json is found! Initialization passed.")})
  endif
  return s:get_promise().chain(l:jobs)
endfunction

" run npm command {{{1
"function! zenn#cmd#npm_promise(args) abort
"  return s:initNpm().then({ -> zenn#cmd#sh(["npm"] + a:args)})
"endfunction

" Force update {{{1
function! zenn#cmd#zenn_update() abort
  return s:initNpm().then({ -> zenn#cmd#sh(["npm", "i", "zenn-cli@latest"])})
endfunction

" init npm 
function s:installZennFromNpm() abort
  call s:initNpm()
  if !isdirectory("node_modules") || !filereadable("node_modules/.bin/zenn") 
    call zenn#echo#echo_msg("zenn-cli is not found! start installing ...")
    return zenn#cmd#sh(["npm", "i", "zenn-cli@latest"])
          \.then({ out -> zenn#echo#echo_msg("zenn-cli is installed!")})
          \.catch({ out -> zenn#echo#echo_err("instaiilng zenn-cli failed")})
  else
    return s:echo_promise("node_modules are found! Install passed.")
  endif
endfunction

" Initialize process
function zenn#cmd#initZenn() abort
  " check node_modules
  if !filereadable(".gitignore") || !filereadable("README.md") || !isdirectory("articles") || !isdirectory("books")
    return s:installZennFromNpm().then({ -> zenn#cmd#sh(["npx", "zenn", "init"])
          \.then({ -> zenn#echo#echo_msg("zenn-cli init command finished")})})
  else
    return s:installZennFromNpm()
  endif
endfunction

" run npx zenn command {{{1
function! zenn#cmd#zenn_promise(args) abort
  return zenn#cmd#initZenn().then({ -> zenn#cmd#sh(["npx", "zenn"] + a:args)})
endfunction


