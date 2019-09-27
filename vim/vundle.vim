set nocompatible
filetype off  " required by vundle

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" File Navigation
Plugin 'scrooloose/nerdtree.git'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'wincent/command-t'
Plugin 'mileszs/ack.vim'

" Window looks
Plugin 'kaicataldo/material.vim'
Plugin 'bgardner7/vim-irblack'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'Lokaltog/vim-powerline'
Plugin 'altercation/vim-colors-solarized'
Plugin 'molokai'
Plugin 'chriskempson/base16-vim'
Plugin 'dracula/vim'

" Miscellaneous
Plugin 'jeffkreeftmeijer/vim-numbertoggle'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rails'
Plugin 'airblade/vim-gitgutter'

Plugin 'The-NERD-Commenter'
Plugin 'tpope/vim-endwise'

Plugin 'VimClojure'

Plugin 'udalov/kotlin-vim'

call vundle#end()

filetype plugin indent on  " required by vundle
