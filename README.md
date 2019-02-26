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

For some color schemes, Lemonlight may not be able to calculate the color for
dimming down the surrounding paragraphs. In that case, you need to define
`g:lemonlight_conceal_ctermfg` or `g:lemonlight_conceal_guifg`.

```vim
" Color name (:help cterm-colors) or ANSI code
let g:lemonlight_conceal_ctermfg = 'gray'
let g:lemonlight_conceal_ctermfg = 240

" Color name (:help gui-colors) or RGB color
let g:lemonlight_conceal_guifg = 'DarkGray'
let g:lemonlight_conceal_guifg = '#777777'

" Default: 0.5
let g:lemonlight_default_coefficient = 0.7

" Number of preceding/following paragraphs to include (default: 0)
let g:lemonlight_paragraph_span = 1

" Beginning/end of paragraph
"   When there's no empty line between the paragraphs
"   and each paragraph starts with indentation
let g:lemonlight_bop = '^\s'
let g:lemonlight_eop = '\ze\n^\s'

" Highlighting priority (default: 10)
"   Set it to -1 not to overrule hlsearch
let g:lemonlight_priority = -1
```

Acknowledgement
---------------

Thanks to [@Cutuchiqueno](https://github.com/Cutuchiqueno) for [suggesting
the idea](https://github.com/junegunn/goyo.vim/issues/34).

License
-------

MIT
