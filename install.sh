#!/bin/bash
#
# Script to install my dotfiles

BACKUPDIR="$HOME/.dotfiles-backup-$(date +%Y-%m-%d-%H-%M-%S)/"
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )

link_file ()
{
  SRC="$1"
  DEST="${2:-$1}"

  if [ -h "$HOME/$DEST" ]; then
    if [ "$(pwd -P $HOME/$SRC)/$DEST" == $DIR/$DEST ]; then
      echo "Your $SRC is already linked up, good job!"
    else
      echo "Your $SRC is already a symlink to something else, I'll leave you to fix that. Quickest fix is to delete the link and run this script again."
    fi
  else
    if [ -a "$HOME/$DEST" ]; then

      echo "Your $SRC already exists, backing up to $BACKUPDIR and replacing."
      if [ $SRC == .bashrc ] || [ $SRC == .bash_profile ]; then
        echo "You might want to copy it into .bashrc.d if you want to keep it."
      fi
      mkdir $BACKUPDIR
      mv $HOME/$DEST $BACKUPDIR

    fi

    ln -s $DIR/$SRC $HOME/$DEST
    if [ $? -eq 0 ]; then
      echo "$DIR/$SRC successfully linked to $HOME/$DEST."
    else
      echo "$DIR/$SRC failed to link to $HOME/$DEST. Investigate and try again."
      exit 1
    fi

  fi
}

copy_file ()
{
  SRC="$1"
  DEST="${2:-$1}"
  if [ -h "$HOME/$DEST" ]; then
    echo "Your $SRC is already a symlink to $(readlink "$HOME/$DEST"), removing the link."
    rm "$HOME/$DEST"
  fi
  cp $DIR/$SRC $HOME/$DEST
    if [ $? -eq 0 ]; then
      echo "$DIR/$SRC successfully copied to $HOME/$DEST."
    else
      echo "$DIR/$SRC failed to copy to $HOME/$DEST. Investigate and try again."
      exit 1
    fi
}

link_file .bashrc
link_file .bash_profile
link_file .bashrc.d
link_file .zshrc
link_file .zshrc.d
link_file .zsh
link_file .zsh_plugins.txt
link_file .vimrc
link_file .tmux.conf
link_file .k9s
# Git replaces symlinks with copies when updating config files, so we might as well just copy the file
copy_file .gitconfig
link_file .gitignore
link_file .gitignore_global
link_file starship.toml .config/starship.toml
