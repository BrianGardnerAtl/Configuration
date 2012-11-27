" set <Leader> to ,
let mapleader = ','

" load the vundle file
source ~/.vim/vundle.vim

" load the gvimrc
source ~/.vim/gvimrc

" turn on syntax highlighting
syntax on

" Run the config files
runtime! config/**/*
