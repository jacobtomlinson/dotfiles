if command -v vim &> /dev/null && [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
    echo "Vundle could not be found, installing..."
    git clone --depth=1 https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
    echo "Vundle installed, run 'vim +PluginInstall +qall' to install plugins."
fi
