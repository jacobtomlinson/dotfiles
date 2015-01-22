  $dotfiles_dir = "${boxen::config::srcdir}/dotfiles"

  repository { $dotfiles_dir:
    source => "jacobtomlinson/dotfiles"
  }

  exec { "install dotfiles":
    cwd      => $dotfiles_dir,
    command  => "./install.sh",
    provider => shell,
    creates  => "${home}/.bashrc",
    require  => Repository[$dotfiles_dir]
  }
