let s:rep = expand('<sfile>:p:h:h:h')

function! zenn_vim#rplugin#init() abort
  if exists('s:result')
    return s:result
  endif
  let s:result = rplugin#init(s:rep, {
        \ 'python': 0,
        \ 'python3': 1,
        \})
  return s:result
endfunction


function! zenn_vim#rplugin#start() abort
  if !zenn_vim#rplugin#init().python3
    return
  endif
  let result = ['']
  python3 << EOC
def _temporary_scope():
    import vim
    import rplugin
    import demo

    # Decorate vim instance with Neovim proxy class
    nvim = rplugin.Neovim(vim)

    regname = nvim.eval('a:args')
    result = nvim.bindeval('result')

    registry = zenn_vim.Registry(nvim)
    result[0] = registry.test()
_temporary_scope()
del _temporary_scope
EOC
  return result[0]
endfunction


function! demo#rplugin#regset(regname, value) abort
  if !demo#rplugin#init().python3
    return
  endif
  let result = ['']
  python3 << EOC
def _temporary_scope():
    import vim
    import rplugin
    import demo

    # Decorate vim instance with Neovim proxy class
    nvim = rplugin.Neovim(vim)

    regname = nvim.eval('a:args')

    registry = zenn_vim.Registry(nvim)
    result[0] = registry.test()
_temporary_scope()
del _temporary_scope
EOC
endfunction
