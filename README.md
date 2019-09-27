# Computer Configuration

This folder includes the various configurations I have for my computer, such as my keyboard configurations, as well as my vim and zsh files.

## Vim Setup

All of the configuration files are held in the vim/ folder so the commands here
reflect how I prefer to set up my vim. First clone the repository into the
home directory. After that a symbolic link is used so vim can find the ~/.vimrc file.

    $ git clone git@github.com:BrianGardnerAtl/Configuration.git ~/Dev
	
Next, install the vim package manager Vundle to the correct place

	$git clone https://github.com/VundleVim/Vundle.vim.git ~/Dev/Configuration/vim/bundle/Vundle.vim
	

After that you need to install all of the bundled plugins so open up vim and type

    :PluginInstall

This command is used by [Vundle](https://github.com/gmarik/vundle) which is a
great package manager for vim and makes adding extra functionality very simple.

### File Structure

The file structure for my vimrc is pretty simple. I tried to keep my vimrc file
pretty basic and split up everything else into other files. The vundle.vim file
is where all of the bundle files are bundled so they are available for vim to
use. The gvimrc file is used to hold the settings for the vim gui. I use macvim
so these settings reflect my personal preference for things such as the size of
the window, the transparency, and the font for the powerline. The bundle
directory is where all of the vundle packages are kept. The config directory is
where various custom vim configurations are kept, often having a separate file
for each package that needs a configuration.

### Important Notes


The leader key is ','


## ZSH Setup

ZSH setup also uses a symlink to setup the .zshrc file.

    $ ln -s ~/Configuration/zsh_config ~/.zshrc
