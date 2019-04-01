# Jacob Tomlinson's dotfiles

These are my dotfiles. There are many like them, but these are mine.

## zshrc and zshrc.d (or bashrc and bashrc.d)

When developing my `.zshrc` I found it getting unwieldy and difficult to manage. Therefore I decided to create a `.zshrc.d` directory.

My `.zshrc` is now just package management and a few lines which source all the files included in `.zshrc.d`. This makes it much easier to manage my files and separate them by program or category.

_I originally did this for my `.bashrc` but have now switched to zsh as my daily driver. However my `.bashrc` and `.bashrc.d` are still here for use on servers and lesser systems.

### Private files

Having my `.zshrc` content in separate files also allows me to create private files which may contain things like ssh aliases to private servers etc. This repository is configured to ignore any files in `.zshrc.d` which begin with the word "private", see [.zshrc.d/private_example.zsh](.zshrc.d/private_example.zsh) for an example.

This way I can keep my private aliases private.

## Installation

### Scripted

Just checkout the repo and run `./install.sh` which will create all the symlinks for you. Easy!

### Manual

Clone the repo and create symlinks for each item in this repo that you want to use to your home directory. This way when you change things you can still track the changes in git.

## Updates

If you want to update your scripts in the future when I make changes simply do a git pull on the repository.

## Disclaimer
This is how I like my terminal. Decisions about colours, layout, fonts and features are often influenced by my current project, whatever that may be. Things will change to suit my needs, this repository is to allow me to quickly put my preferred settings on a new machine as well as share it with others.

Features will come and go as I see fit, I will do my best to tag a release before making a major change to allow others to stick with a version they like. I may even make this more modular in future to allow for turning on different options.


[1]: https://github.com/jacobtomlinson/terminal-piperita
