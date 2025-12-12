for d in "$HOME/miniconda3" "$HOME/mambaforge" "$HOME/miniforge3"; do 
  if [ -d "$d" ]; then
    CONDA_PREFIX="$d"
    break
  fi
done

__conda_setup="$($CONDA_PREFIX/bin/conda 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$CONDA_PREFIX/etc/profile.d/conda.sh" ]; then
        . "$CONDA_PREFIX/etc/profile.d/conda.sh"
    else
        export PATH="$CONDA_PREFIX/bin:$PATH"
    fi
fi
unset __conda_setup
alias ca="conda activate"

function cfstatus {
  if command -v xq >/dev/null 2>&1; then
    echo "Conda Forge CDN last updated: $(curl -sSL https://conda.anaconda.org/conda-forge/rss.xml | xq '.rss.channel.lastBuildDate')"
  else
    echo "cannot find yq/xq, you can install it with 'uv tool add yq' (yes that adds both yq and xq)"
  fi
}
