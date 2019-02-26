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

function! s:getpos()
  let bop = get(g:, 'lemonlight_bop', '^\s*$\n\zs')
  let eop = get(g:, 'lemonlight_eop', '^\s*$')
  let span = max([0, get(g:, 'lemonlight_paragraph_span', 0) - s:empty(getline('.'))])
  let pos = getpos('.')
  for i in range(0, span)
    let start = searchpos(bop, i == 0 ? 'cbW' : 'bW')[0]
  endfor
  call setpos('.', pos)
  for _ in range(0, span)
    let end = searchpos(eop, 'W')[0]
  endfor
  call setpos('.', pos)
  return [start, end]
endfunction

function! s:empty(line)
  return (a:line =~# '^\s*$')
endfunction

function! s:lemonlight()
  if !empty(get(w:, 'lemonlight_range', []))
    return
  endif
  if !exists('w:lemonlight_prev')
    let w:lemonlight_prev = [0, 0, 0, 0]
  endif

  let curr = [line('.'), line('$')]
  if curr ==# w:lemonlight_prev[0 : 1]
    return
  endif

  let paragraph = s:getpos()
  if paragraph ==# w:lemonlight_prev[2 : 3]
    return
  endif

  call s:clear_hl()
  call call('s:hl', paragraph)
  let w:lemonlight_prev = extend(curr, paragraph)
endfunction

function! s:hl(startline, endline)
  let w:lemonlight_match_ids = get(w:, 'lemonlight_match_ids', [])
  let priority = get(g:, 'lemonlight_priority', 10)
  call add(w:lemonlight_match_ids, matchadd('LemonlightDim', '\%<'.a:startline.'l', priority))
  if a:endline > 0
    call add(w:lemonlight_match_ids, matchadd('LemonlightDim', '\%>'.a:endline.'l', priority))
  endif
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

function! s:on(range, ...)
  call s:dim()

  let w:lemonlight_range = a:range
  if !empty(a:range)
    call s:clear_hl()
    call call('s:hl', a:range)
  endif

  augroup lemonlight
    let was_on = exists('#lemonlight#CursorMoved')
    autocmd!
    if empty(a:range) || was_on
      autocmd CursorMoved,CursorMovedI * call s:lemonlight()
    endif
    autocmd ColorScheme * try
                       \|   call s:dim()
                       \| catch
                       \|   call s:off()
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

function! s:off()
  call s:clear_hl()
  augroup lemonlight
    autocmd!
  augroup END
  augroup! lemonlight
  unlet! w:lemonlight_prev w:lemonlight_match_ids w:lemonlight_range
endfunction

function! s:is_on()
  return exists('#lemonlight')
endfunction

function! s:cleanup()
  if !s:is_on()
    call s:clear_hl()
  end
endfunction

function! lemonlight#execute(bang, visual, ...) range
  let range = a:visual ? [a:firstline, a:lastline] : []
  if a:bang
    if a:0 > 0 && a:1 =~ '^!' && !s:is_on()
      if len(a:1) > 1
        call s:on(range, a:1[1:-1])
      else
        call s:on(range)
      endif
    else
      call s:off()
    endif
  elseif a:0 > 0
    call s:on(range, a:1)
  else
    call s:on(range)
  endif
endfunction

function! lemonlight#operator(...)
  '[,']call lemonlight#execute(0, 1)
endfunction
