Brian Gardner's vim config
==========================

Installation
------------

All of the configuration files are held in my ~/.vim folder so the commands here
reflect how I prefer to set up my vim. First clone the repository into the .vim
folder in your home directory. After that a symbolic link is used so vim can
find the ~/.vimrc file.

    $ git clone git@github.com:bgardner7/vim-config.git ~/.vim
    $ ln -s ~/.vim/vimrc ~/.vimrc

After that you need to install all of the bundled plugins so open up vim and type

    :PluginInstall

This command is used by [Vundle](https://github.com/gmarik/vundle) which is a
great package manager for vim and makes adding extra functionality very simple.

File Structure
--------------

The file structure for my vimrc is pretty simple. I tried to keep my vimrc file
pretty basic and split up everything else into other files. The vundle.vim file
is where all of the bundle files are bundled so they are available for vim to
use. The gvimrc file is used to hold the settings for the vim gui. I use macvim
so these settings reflect my personal preference for things such as the size of
the window, the transparency, and the font for the powerline. The bundle
directory is where all of the vundle packages are kept. The config directory is
where various custom vim configurations are kept, often having a separate file
for each package that needs a configuration.

Important Notes
---------------

The leader key is ','
