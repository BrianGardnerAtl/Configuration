" set <Leader> to ,
let mapleader = ','

" load the vundle file
source ~/.vim/vundle.vim

" load the gvimrc
source ~/.vim/gvimrc

source ~/.vim/bundle/vim-gradle/ftdetect/gradle.vim

" turn on syntax highlighting
syntax on
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" Run the config files
runtime! config/**/*

highlight clear SignColumn
