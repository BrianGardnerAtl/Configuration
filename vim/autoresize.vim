let g:auto_resize_width = 40
function! s:AutoResize()
  let win_width = winwidth(winnr())
  if win_width < g:auto_resize_width + 1
    let &columns += g:auto_resize_width + 1
  elseif win_width > g:auto_resize_width
    let &columns -= g:auto_resize_width + 1
  endif
  wincmd =
endfunction

augroup AutoResize
  autocmd!
  autocmd WinEnter * call <sid>AutoResize()
augroup END
