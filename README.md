# zenn-vim
plugin for zenn.dev

## Requirements

- Neovim or Vim8
  - this plugin uses Async Feature (channels, jobs, e.t.c.).
  - include vital.vim (https://github.com/vim-jp/vital.vim).
    this plugin uses
      - Async.Promise
      - System.Job (from https://github.com/lambdalisue/vital-Whisky)
      
    and supports
      - The latest major version (8.2.*)
      - The previous major version (8.1.*)
    now.
    
- Npm(with npx)
  - zenn official doesn't specify nodejs version number,
    but I recommend using its latest lts version.
  - (neo)vim node js support is not needed because it is called as system
    command.

Be careful to set 'zenn' as name of this plugin if you use
plugin manager.
After downloading to your vim runtimepath, configure your vimrc to call functions.
(See examples).

## Examples

```viml
  " same prefix from command in monaqa's article
  const g:zenn#article#slug = {
    \ "use_template": v:true,
    \ "format": "%F"
    \}

  " open the new article after 'zenn#new_article' with the command
  const g:zenn#article#edit_new_cmd = "new"

  " npm install zenn-cli@latest
  command! -nargs=0 ZennUpdate call zenn#update()
  
  " Run npx zenn preview
  " call |:ZennPreview| or |:ZennPreview {port} |
  command! -nargs=* ZennPreview call zenn#preview(<f-args>)

  " Stop zenn preview process 
  command! -nargs=0 ZennStopPreview call zenn#stop_preview()

  " Create zenn new article
  " call |:ZennPreview [{slug},{title},{type}, {emoji}] |
  command! -nargs=* ZennNewArticle call zenn#new_article(<f-args>)

  " Create zenn new book
  " call |:ZennPreview [{slug}] |
  command! -nargs=* ZennNewBook call zenn#new_book(<f-args>)
```

## Features

- Add functions like `zenn#preview()`, `zenn#new_article()`, ...

For details, see [`doc/zenn.txt`](https://github.com/kkiyama117/zenn-vim/blob/master/doc/zenn.txt)
or call `:help zenn_vim` on vim

## Install

Install as vim plugin same as others.
(Tell me how to install with each plugin manager.)

## LICENSE

I use GPLv3 now but give all rights if [zenn official](https://github.com/zenn-dev)
requires.
Contact [kkiyama117](https://github.com/kkiyama117) or make issues on this
repository if there are rights side plobrems.

## TODO

See [issues](https://github.com/kkiyama117/zenn-vim/issues).

