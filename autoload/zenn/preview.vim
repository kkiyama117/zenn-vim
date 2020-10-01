
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

function! zenn#preview#preview(...) abort
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

function! zenn#preview#stop_preview() abort
  if exists("s:preview_job") && !empty(s:preview_job)
    call s:preview_job.stop()
    let s:preview_job = {}
    call zenn#echo#echo_msg("preview is stopped!")
  else
    call zenn#echo#echo_msg("preview is not running")
  endif
endfunction

