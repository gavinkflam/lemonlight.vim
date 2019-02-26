lemonlight.vim
==============

Hyperfocus-writing in Vim.

![](https://raw.github.com/junegunn/i/master/limelight.gif)

Works on 256-color terminal or on GVim.

Usage
-----

- `Lemonlight [0.0 ~ 1.0]`
    - Turn Lemonlight on
- `Lemonlight!`
    - Turn Lemonlight off
- `Lemonlight!! [0.0 ~ 1.0]`
    - Toggle Lemonlight

### Lemonlight for a selected range

You can invoke `:Lemonlight` for a visual range. There are also `<Plug>`
mappings for normal and visual mode for the purpose.

```vim
nmap <Leader>l <Plug>(Lemonlight)
xmap <Leader>l <Plug>(Lemonlight)
```

### Options

```vim
" Color name (:help cterm-colors) or ANSI code. (default: 'gray')
let g:lemonlight_conceal_ctermfg = 'gray'
let g:lemonlight_conceal_ctermfg = 240

" Color name (:help gui-colors) or RGB color. (default: 'DarkGray')
let g:lemonlight_conceal_guifg = 'DarkGray'
let g:lemonlight_conceal_guifg = '#777777'

" The motion to select the auto-focus area. (default: 'ip')
let g:lemonlight_autofocus_motion = 'ip'

" Highlighting priority. (default: 10)
" Set it to -1 not to overrule hlsearch.
let g:lemonlight_priority = -1
```

Acknowledgement
---------------

Thanks to [@Cutuchiqueno](https://github.com/Cutuchiqueno) for [suggesting
the idea](https://github.com/junegunn/goyo.vim/issues/34).

License
-------

MIT
