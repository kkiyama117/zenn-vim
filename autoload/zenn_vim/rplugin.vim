let s:rep = expand('<sfile>:p:h:h:h')

function! zenn_vim#rplugin#init() abort
  if exists('s:supported')
    return s:supported
  endif
  try
    let result = rplugin#init(s:rep, {
          \ 'python': 0,
          \ 'python3': has('python3'),
          \})
    let s:supported = result.python3
    if !s:supported
      echoerr 'It requires a Neovim or Vim with Python3 support (+python3)'
    endif
  catch /^Vim\%((\a\+)\)\=:E117/
    echoerr 'It requires a lambdalisue/vim-rplugin in Vim8.'
    echoerr 'https://github.com/lambdalisue/vim-rplugin'
    let s:supported = 0
  endtry
  return s:supported
endfunction


function! zenn_vim#rplugin#update() abort
  if !zenn_vim#rplugin#init()
    return
  endif
  let result = ['']
  python3 << EOC
def _temporary_scope():
    from zenn_vim import zenn_update

    # Decorate vim instance with Neovim proxy class
    nvim = rplugin.Neovim(vim)
    zenn_update(nvim, [])
_temporary_scope()
del _temporary_scope
EOC
endfunction

function! zenn_vim#rplugin#preview(...) abort
  if !zenn_vim#rplugin#init()
    return
  endif
  let result = ['']
  python3 << EOC
def _temporary_scope():
    from zenn_vim import zenn_preview

    # Decorate vim instance with Neovim proxy class
    nvim = rplugin.Neovim(vim)
    zenn_preview(nvim, [nvim.eval('a:000')])
_temporary_scope()
del _temporary_scope
EOC
endfunction

