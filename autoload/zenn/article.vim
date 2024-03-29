function! s:get_datetime() abort
  if !exists('s:DateTime')
    let s:DateTime = vital#zenn#import('DateTime')
  endif
  return s:DateTime
endfunction

" Check Configfunction! s:get_datetime() abort
function! s:get_config()
  if !exists('s:Config')
    let s:Config = vital#zenn#import('Config')
  endif
  return s:Config
endfunction

" Set template to top if set by setting.
function! s:slug_top() abort
  " Define the following only when the variable is missing
  call s:get_config().define('zenn#article', {
        \'slug':{
        \ 'use_template': v:false,
        \ 'strfttime': v:null,
        \ 'format': v:null,
        \}
        \})
  const l:config = g:zenn#article#slug
  if l:config["use_template"]
    const l:now = s:get_datetime().now()
    if l:config["format"] != v:null
      const l:top = l:now.format(l:config["format"])
      return l:top
    elseif l:config["strfttime"] != v:null
      const l:top = l:now.strfttime(l:config["strfttime"])
      return l:top
    endif
    call zenn#echo#echo_err("`g:zenn#article#slug['use_template']` is v:true,"
          \. " but templates are not found!\n". "Set `g:zenn#article#slug['format']`" 
          \. " or `g:zenn#article#slug#['strfttype']`")
    return v:null
  else
    return v:null
  endif
endfunction

function! s:edit_article(outputs) abort
  let l:name = ''
  if type(a:outputs) == v:t_list && len(a:outputs) == 1
    let l:name = a:outputs[0]
  elseif type(a:outputs) == v:t_string
    let l:name = a:outputs
  endif

  if l:name ==# ''
   " case-1: should not open multiple files at once
   " case-2: if there are no file to process
    return a:outputs
  endif

  call s:get_config().define('zenn#article', {
        \'edit_new_cmd':v:null,
        \})
  let l:command = g:zenn#article#edit_new_cmd

  if l:command != v:null && l:command !=# ''
    execute l:command trim(l:name)
  endif

  return a:outputs
endfunction

function! zenn#article#new_article(args_dict) abort
  let l:args_dict = a:args_dict
  " create args from dict
  let l:args = ["--machine-readable"]
  const l:slug_top = s:slug_top()
  for [key,value] in items(l:args_dict)
    call add(l:args, "--" . key)
    if (key == "slug")
      const l:slug = l:slug_top != v:null ? l:slug_top . "-" . value : value
      call add(l:args, l:slug)
    else
      call add(l:args, value)
    endif
  endfor
  " insert slug if not exists in `l:args_dict`
  if !has_key(l:args_dict, "slug") && l:slug_top != v:null
    call extend(l:args, ['--slug', l:slug_top])
  endif
  return zenn#cmd#zenn_promise(["new:article"] + l:args)
        \.then(
        \  { outputs -> s:edit_article(outputs) } )
endfunction
