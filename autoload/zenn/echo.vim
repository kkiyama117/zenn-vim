" show message
function! zenn#echo#echo_msg(msg, ...) abort
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
  else
    echo a:msg
  endif
  return v:true
endfunction

" show error message
function! zenn#echo#echo_err(msg, ...) abort
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
  else
    echo a:msg
  endif
  echohl None
  return v:false
endfunction

