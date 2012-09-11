" Limit number of matches displayed
let g:CommandTMaxHeight=25

" Allow the searching of dotfiles/dotdirectories
let g:CommandTAlwaysShowDotFiles = 1
let g:CommandTScanDotDirectories = 1

map <Leader>t :CommandT<CR>
map <Leader>T :CommandTFlush<CR>
