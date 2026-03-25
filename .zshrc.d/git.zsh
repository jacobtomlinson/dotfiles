# Set git email based on username
if [ "$(whoami)" = "jacob" ]; then
    email="jacob@tomlinson.email"
elif [ "$(whoami)" = "jtomlinson" ]; then
    email="jtomlinson@nvidia.com"
fi

if [ -n "$email" ]; then
    sed -i.bak "s/^\([[:space:]]*email[[:space:]]*=[[:space:]]*\).*/\1$email/" ~/.gitconfig
fi

function gupstream () {
    if git remote | grep -q '^upstream$'; then
        echo upstream
    else
        echo origin
    fi
}

function gub () {
	REMOTE=${1:-$(gupstream)}
	git fetch $REMOTE
	git remote show $REMOTE | grep "HEAD branch" | sed 's/.*: //'
}

unalias gcm
function gcm () {
    REMOTE=$(gupstream)
    BRANCH=$(gub $REMOTE)
    echo "Checking out $REMOTE/$BRANCH"
    git checkout $BRANCH
}

unalias glum
function glum () {
    REMOTE=$(gupstream)
    BRANCH=$(gub $REMOTE)
    if [[ "$REMOTE" == "origin" ]]; then
        echo "Warning: No remote 'upstream' found, pulling from $REMOTE/$BRANCH instead." >&2
    fi
	git pull $REMOTE $BRANCH
}

alias pr="gh pr checkout"

gw() {
  local branch="$1"
  if [[ -z "$branch" ]]; then
    echo "Usage: gw <branch-name>" >&2
    return 1
  fi

  local toplevel
  toplevel="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "gw: not inside a git repository" >&2
    return 1
  }

  local projects_dir="$HOME/Projects"
  local suffix="${toplevel#"$projects_dir"/}"
  if [[ "$suffix" == "$toplevel" ]]; then
    echo "gw: repo is not under ~/Projects/<org>/<repo>" >&2
    return 1
  fi

  local worktree_dir="$HOME/Worktrees/$suffix/$branch"
  mkdir -p "$(dirname "$worktree_dir")"
  git worktree add -b "$branch" "$worktree_dir" || return 1
  cd "$worktree_dir"
}
