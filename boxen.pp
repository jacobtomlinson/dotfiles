# Dotfiles GitHub repository to install, if you've forked then change
# this to be your repo.
$dotfiles_repo = "jacobtomlinson/dotfiles"

# Directory to clone the dotfiles repo into, they will be symlinked
# from here so it doesn't really matter where you choose.
$dotfiles_dir = "${boxen::config::srcdir}/dotfiles"

# Clone the dotfiles repo.
repository { $dotfiles_dir:
  source => $dotfiles_repo
}

# Execute the dotfiles installer unless .bashrc already exists, which it
# will not on a Mac by default. If you want to run the installer again
# just delete your .bashrc and run boxen.
exec { "install dotfiles":
  cwd      => $dotfiles_dir,
  command  => "./install.sh",
  provider => shell,
  creates  => "${home}/.bashrc",
  require  => Repository[$dotfiles_dir]
}
