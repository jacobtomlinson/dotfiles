export PATH="$HOME/.pixi/bin:$PATH"

export PIXI_GLOBAL_ENVS="$HOME/.pixi-envs"
if [ ! -d "$PIXI_GLOBAL_ENVS" ]; then
  mkdir -p "$PIXI_GLOBAL_ENVS"
fi

unset pa
function pa {
    pixi shell --manifest-path "$PIXI_GLOBAL_ENVS/$1"
}
unset pl
function pl {
    ls "$PIXI_GLOBAL_ENVS"
}
unset pc
function pc {
    pixi init "$PIXI_GLOBAL_ENVS/$1"
}
unset pe
function pe {
    if [ -n "$1" ]; then
        $EDITOR "$PIXI_GLOBAL_ENVS/$1/pixi.toml"
    elif [ -n "$PIXI_PROJECT_MANIFEST" ]; then
        $EDITOR "$PIXI_PROJECT_MANIFEST"
    else
        echo "No active shell and noenvironment name provided."
        echo "See 'pl' to list available environments or 'pc' to create a new environment"
        return 1
    fi
}
