" set <Leader> to ,
let mapleader = ','

" load the vundle file
source ~/.vim/vundle.vim

" turn on syntax highlighting
syntax on

" Run the config files
runtime! config/**/*
