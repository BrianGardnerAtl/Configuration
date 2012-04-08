set nocompatible
filetype off  " required by vundle

set rtp+=~/.vim/bundle/vundle
call vundle#rc()

Bundle 'gmarik/vundle'

" File Navigation
Bundle "scrooloose/nerdtree.git"
Bundle "git://git.wincent.com/command-t.git"
Bundle "mileszs/ack.vim"

" Window looks
Bundle "bgardner7/vim-irblack"

" Miscellaneous
Bundle "jeffkreeftmeijer/vim-numbertoggle"

filetype plugin indent on  " required by vundle
