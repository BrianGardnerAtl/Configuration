" General settings for the vim config

" Completion settings
"""""""""""""""""""""
set wildmenu
set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git,*.class

set timeoutlen=500 " 1/2 second

" Display settings
""""""""""""""""""
colorscheme base16-default
set background=dark
set t_Co=256

set number
set ruler
set showcmd
set showmatch
set showmode
set title
set scrolloff=10
set laststatus=2

set hidden
set history=100
set noeb vb  " Get rid of error bells

set winheight=5
set winminheight=5  " minimum height of a window
set winheight=999
set winwidth=80

" Search settings
"""""""""""""""""
set ignorecase    " Ignore case by default
set smartcase     " Ignore case if all lower, else pay attention to case
set incsearch     " Incremental search
set hlsearch

" Editing settings
""""""""""""""""""
set autoindent    " automatically indent lines
set smartindent   " try to indent intelligently
" Backspace over all the things
set backspace=indent,eol,start
" custom characters for tabs and trailing whitespace
set list listchars=tab:>-,trail:-

" use spaces instead of tabs
set softtabstop=2
set tabstop=2
set shiftwidth=2
set expandtab

" automatically reload a file if it is changed
set autoread

" wrap settings
set nowrap
set linebreak
set textwidth=80
set nojoinspaces

" Miscellaneous settings
""""""""""""""""""""""""
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

set mouse-=a    " disable the use of the mouse
set mousehide
