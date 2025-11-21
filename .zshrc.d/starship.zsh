if ! command -v starship &> /dev/null; then
    echo "Starship could not be found, installing..."
    curl -fsSL https://starship.rs/install.sh | sh
fi

eval "$(starship init zsh)"

# Ensure conda and pixi prompt modifications are disabled
if command -v conda &> /dev/null; then
    conda config --set changeps1 False > /dev/null 2>&1
fi
if command -v pixi &> /dev/null; then
    pixi config set shell.change-ps1 false > /dev/null 2>&1
fi
