function! s:get_datetime() abort
  if !exists('s:DateTime')
    let s:DateTime = vital#zenn#import('DateTime')
  endif
  return s:DateTime
endfunction

" Check Configfunction! s:get_datetime() abort
function! s:get_config()
  if !exists('s:DateTime')
    let s:Config = vital#zenn#import('Config')
  endif
  return s:Config
endfunction

" Set template to top if set by setting.
function! s:slug_top() abort
  " Define the following only when the variable is missing
  call s:get_config().define('zenn#book', {
        \'slug':{
        \ 'use_template': v:false,
        \ 'strfttime': v:null,
        \ 'format': v:null,
        \}
        \})
  const l:config = g:zenn#book#slug
  if l:config["use_template"]
    const l:now = s:get_datetime().now()
    if l:config["format"] != v:null
      const l:top = l:now.format(l:config["format"])
      return l:top
    elseif l:config["strfttime"] != v:null
      const l:top = l:now.strfttime(l:config["strfttime"])
      return l:top
    endif
    call zenn#echo#echo_err("`g:zenn#book#slug['use_template']` is v:true,"
          \. " but templates are not found!\n". "Set `g:zenn#book#slug['format']`" 
          \. " or `g:zenn#book#slug#['strfttype']`")
    return v:null
  else
    return v:null
  endif
endfunction

function! zenn#book#new_book(slug) abort
  const l:slug_top = s:slug_top()
  if a:slug == v:null 
    const l:slug = l:slug_top != v:null ? l:slug_top : v:null
  else
    const l:slug = l:slug_top != v:null ? l:slug_top . "-" . a:slug : a:slug
  endif
  const l:args = l:slug ==v:null ? [] : ["--slug", l:slug]
  return zenn#cmd#zenn_promise(["new:book"] + l:args)
endfunction
