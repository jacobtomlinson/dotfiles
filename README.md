# Jacob Tomlinson's dotfiles

These are my dotfiles. They were originally part of my [piperita][1] terminal theme but I have decided to separate them from the theme.

###Features
* Prompt separated by colours
* User identifier changes colour depending on command return code
* Username changes colour based on whether superuser or not
* Displays current branch and status when in a git controlled directory
* Pretty man highlighing
* Grep highlighting
* Vi/Vim syntax highlighting

## bashrc and bashrc.d

When developing my `.bashrc` I found it getting unwieldy and difficult to manage. Therefore I decided to create a `.bashrc.d` directory.

My `.bashrc` is now just a few lines which source all the files included in `.bashrc.d`. This makes it much easier to manage my files and separate them by program or category.

### Private files

Having my `.bashrc` content in separate files also allows me to create private files which may contain things like ssh aliases to private servers etc. This repository is configured to ignore any files in `.bashrc.d` which begin with the word "private".

That way I can keep my private aliases private.

## Installation

### Boxen

This is the way I do it. More details to follow.

### Scripted

Just checkout the repo and run `./install.sh` which will create all the symlinks for you. Easy!

### Manual

You can make use of my dotfiles by forking the repository and cloning it to your local machine. I would then recommend creating symlinks from `~/.bashrc` to `/location/of/dotfiles/repo/.bashrc` for each item in this repo that you want to use. That way when you change things you can still track the changes in git.

## Disclaimer
This is how I like my terminal. Decisions about colours, layout, fonts and features are often influenced by my current project, whatever that may be. Things will change to suit my needs, this repository is to allow me to quickly put my preferred settings on a new machine as well as share it with others.

Features will come and go as I see fit, I will do my best to tag a release before making a major change to allow others to stick with a version they like. I may even make this more modular in future to allow for turning on different options.

####Screenshots

Screenshots using these dotfiles and my [piperita][1] theme in [iTerm2][2].

#####Return code testing
![alt text](http://i.imgur.com/6fr0gB1.png "Return code")

#####Escalating to root
![alt text](http://i.imgur.com/Ag6zNRd.png "Root")

#####Grep a file
![alt text](http://i.imgur.com/XO5JAwB.png "Grep")

#####Man page
![alt text](http://i.imgur.com/gOudKTc.png "Man")

#####Git workflow
![alt text](http://i.imgur.com/0rr9Ulz.png "Git")


[1]: https://github.com/jacobtomlinson/terminal-piperita
[2]: http://iterm2.com/
