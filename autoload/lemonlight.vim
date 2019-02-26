" Copyright (c) 2015 Junegunn Choi
" Copyright (c) 2018 Gavin Lam
"
" MIT License
"
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the
" "Software"), to deal in the Software without restriction, including
" without limitation the rights to use, copy, modify, merge, publish,
" distribute, sublicense, and/or sell copies of the Software, and to
" permit persons to whom the Software is furnished to do so, subject to
" the following conditions:
"
" The above copyright notice and this permission notice shall be
" included in all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
" NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
" LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
" OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
" WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

" Exit when loaded already or compatible mode was set
if exists('g:loaded_lemonlight') || &cp
  finish
endif

let g:loaded_lemonlight = 1

function! s:empty(line)
  return (a:line =~# '^\s*$')
endfunction

function! s:lemonlight(range)
  echo a:range
  call s:clear_hl()
  call s:hl(a:range)
endfunction

function! s:hl(range)
  let w:lemonlight_match_ids = get(w:, 'lemonlight_match_ids', [])
  let priority = get(g:, 'lemonlight_priority', 10)

  let bytes =
    \ (line2byte(a:range[2]) + a:range[3] - 1) -
    \ (line2byte(a:range[0]) + a:range[1] - 1)

  call add(
    \ w:lemonlight_match_ids,
    \ matchaddpos('LemonlightDim', [[a:range[0], a:range[1], bytes]], priority)
  \ )
endfunction

function! s:clear_hl()
  while exists('w:lemonlight_match_ids') && !empty(w:lemonlight_match_ids)
    silent! call matchdelete(remove(w:lemonlight_match_ids, -1))
  endwhile
endfunction

function! s:dim()
  if has('gui_running') || has('termguicolors') && &termguicolors || has('nvim') && $NVIM_TUI_ENABLE_TRUE_COLOR
    if exists('g:lemonlight_conceal_guifg')
      let dimColor = g:lemonlight_conceal_guifg
    else
      let dimColor = 'gray'
    endif
    execute printf('hi LemonlightDim guifg=%s guisp=bg', dimColor)
  elseif &t_Co == 256
    if exists('g:lemonlight_conceal_ctermfg')
      let dimColor = g:lemonlight_conceal_ctermfg
    else
      let dimColor = 'DarkGray'
    endif

    if type(dimColor) == 1
      execute printf('hi LemonlightDim ctermfg=%s', dimColor)
    else
      execute printf('hi LemonlightDim ctermfg=%d', dimColor)
    endif
  else
    throw 'Unsupported terminal. Sorry.'
  endif
endfunction

function! s:is_on()
  return exists('#lemonlight')
endfunction

function! s:cleanup()
  if !s:is_on()
    call s:clear_hl()
  end
endfunction

function! lemonlight#on()
  call s:dim()

  augroup lemonlight
    autocmd!

    autocmd CursorMoved,CursorMovedI *
      \ silent execute "normal \<Plug>(Lemonlight_hl_op)ip"
    autocmd ColorScheme * try
                       \|   call s:dim()
                       \| catch
                       \|   call lemonlight#off()
                       \|   throw v:exception
                       \| endtry
  augroup END

  " FIXME: We cannot safely remove this group once Lemonlight started
  augroup lemonlight_cleanup
    autocmd!
    autocmd WinEnter * call s:cleanup()
  augroup END

  doautocmd CursorMoved
endfunction

function! lemonlight#off()
  call s:clear_hl()

  augroup lemonlight
    autocmd!
  augroup END
  augroup! lemonlight

  unlet! w:lemonlight_match_ids
endfunction

function! lemonlight#hl_op(type, ...)
  " Save selection and register state
  let sel_save = &selection
  let &selection = "inclusive"

  if a:0
    " Invoked from Visual mode, use gv command
    silent exe "normal! gv"
  elseif a:type == 'line'
    silent exe "normal! '[V']"
  else
    silent exe "normal! `[v`]"
  endif

  let start = getpos('`<')
  let end   = getpos('`>')

  silent exe "normal! \<esc>"

  " Highlight range
  call s:dim()
  call s:lemonlight([start[1], start[2], end[1], end[2]])

  " Restore saved state
  let &selection = sel_save

  return 1
endfunction

" Dispatch content under the current line
function! lemonlight#hl_line()
  call lemonlight#hl()
  return 1
endfunction

" Dispatch visual mode selection via operation mode
function! lemonlight#hl_visual()
  call lemonlight#hl_op(visualmode())
  return 1
endfunction
