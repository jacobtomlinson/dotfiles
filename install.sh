#!/bin/bash
#
# Script to install my dotfiles

BACKUPDIR="$HOME/dotfiles-backup/"
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )

link_file ()
{ 

  if [ -h "$HOME/$1" ]; then
    if [ "$(pwd -P $HOME/$1)/$1" == $DIR/$1 ]; then
      echo "Your $1 is already linked up, good job!"
    else
      echo "Your $1 is already a symlink to something else, I'll leave you to fix that. Quickest fix is to delete the link and run this script again."
    fi
  else
    if [ -a "$HOME/$1" ]; then

      echo "Your $1 already exists, backing up to $BACKUPDIR and replacing."
      if [ $1 == .bashrc ] || [ $1 == .bash_profile ]; then
        echo "You might want to copy it into .bashrc.d if you want to keep it."
      fi
      mkdir $BACKUPDIR
      mv $HOME/$1 $BACKUPDIR

    fi

    ln -s $DIR/$1 $HOME/$1
    if [ $? -eq 0 ]; then
      echo "$DIR/$1 successfully linked to $HOME/$1."
    else
      echo "$DIR/$1 failed to link to $HOME/$1. Investigate and try again."
      exit 1
    fi 

  fi
} 

link_file .bashrc
link_file .bashrc.d
link_file .vimrc
link_file .bash_profile
