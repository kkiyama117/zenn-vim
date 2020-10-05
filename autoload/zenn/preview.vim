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
function s:on_receive(buffer, data) abort dict
  " Remove trailing CRs
  call map(a:data, 'v:val[-1:] ==# "\r" ? v:val[:-2] : v:val')
  call extend (a:buffer, a:data)
endfunction
function s:on_exit(out, err) abort
  return {e -> e
        \ ? zenn#echo#echo_err( "preview server is killed!" . join(a:err, "\n"))
        \ : zenn#echo#echo_msg(join(a:out, "\n"))}
endfunction
function s:server(out,err)
  return s:get_job().start(["npx", "zenn", "preview"],{
        \ 'on_stdout': function('s:on_receive', [a:out]),
        \ 'on_stderr': function('s:on_receive', [a:err]),
        \ 'on_exit': s:on_exit(a:out,a:err)
        \})
endfunction

function s:server_promise()
  let l:stdout = ['']
  let l:stderr = ['']
  return s:get_promise().new({rv,rj ->
        \ rv(s:server(l:stdout,l:stderr))
        \})
endfunction

function s:set_server(arg) abort
  let s:preview_job = a:arg
  return a:arg
endfunction

function! s:wait(ms)
  return s:Promise.new({resolve -> timer_start(a:ms, resolve)})
endfunction

function! zenn#preview#preview(port) abort
  " parse args
  const l:command = exists("a:port") ? ["preview", "--port", a:port]
    \: ["preview"]
  " check if preview is already running
  if exists("s:preview_job") && type(s:preview_job) == v:t_dict
    call zenn#echo#echo_msg("preview is already running")
    return
  else
    call zenn#echo#echo_msg("zenn-cli try starting preview server on"
        \. " localhost: " . a:port . " ...")
  endif
  " run server
  return zenn#cmd#initZenn()
        \.then({ -> s:server_promise()
            \.then({result -> s:set_server(result)})
            \.then({ result -> zenn#echo#echo_msg("preview is started!")})
        \})
endfunction

function! zenn#preview#stop_preview() abort
  if exists("s:preview_job") && type(s:preview_job) == v:t_dict
    call s:preview_job.stop()
    let s:preview_job = v:null
  else
    call zenn#echo#echo_msg("preview is not running")
  endif
endfunction

