# dotfiles by Jacob Tomlinson
# https://github.com/jacobtomlinson/dotfiles

# DON'T MODIFY THIS FILE
# Place new config in a separate file within ~/.bashrc.d/

# Source all files in ~/.bashrc.d/
for i in ~/.bashrc.d/* ; do
    if [ -r "$i" ]; then
        source $i
    fi
done