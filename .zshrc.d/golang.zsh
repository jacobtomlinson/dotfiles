export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
if hash goenv 2>/dev/null; then
    eval "$(goenv init -)"
fi
export PATH="$GOROOT/bin:$PATH"
export PATH="$PATH:$GOPATH/bin"
