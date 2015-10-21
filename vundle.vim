set nocompatible
filetype off  " required by vundle

set rtp+=~/.vim/bundle/vundle
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" File Navigation
Plugin 'scrooloose/nerdtree.git'
Plugin 'wincent/command-t'
Plugin 'mileszs/ack.vim'

" Window looks
Plugin 'bgardner7/vim-irblack'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'Lokaltog/vim-powerline'
Plugin 'altercation/vim-colors-solarized'
Plugin 'molokai'
Plugin 'chriskempson/base16-vim'

" Miscellaneous
Plugin 'jeffkreeftmeijer/vim-numbertoggle'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rails'
Plugin 'airblade/vim-gitgutter'

Plugin 'The-NERD-Commenter'
Plugin 'tpope/vim-endwise'

Plugin 'VimClojure'

call vundle#end()

filetype plugin indent on  " required by vundle
