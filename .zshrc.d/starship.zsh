if ! command -v starship &> /dev/null; then
    echo "Starship could not be found, installing..."
    curl -fsSL https://starship.rs/install.sh | sh
fi

eval "$(starship init zsh)"
