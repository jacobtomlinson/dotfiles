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
    if git rev-parse --is-inside-work-tree &>/dev/null && \
       [[ "$(git rev-parse --show-toplevel)" != "$(git worktree list --porcelain | head -1 | sed 's/^worktree //')" ]]; then
        gwm
    fi
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

gwpr() {
  local pr_number="$1"
  if [[ -z "$pr_number" ]]; then
    echo "Usage: gwpr <pr-number>" >&2
    return 1
  fi

  # Get the branch name from the PR
  local branch
  branch="$(gh pr view "$pr_number" --json headRefName --jq .headRefName)" || return 1

  # If the worktree already exists, just cd there
  local toplevel
  toplevel="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1
  local worktree_dir="$toplevel/.worktrees/$branch"

  if [[ -d "$worktree_dir" ]]; then
    cd "$worktree_dir"
    return
  fi

  # Check out the PR to get a local branch
  gh pr checkout "$pr_number" || return 1

  # Switch back to main so the primary repo stays on main
  git checkout "$(gub)" || return 1

  # Use gw to set up a worktree for the PR branch
  gwb "$branch"
}

gwm() {
  local toplevel
  toplevel="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "gwm: not inside a git repository" >&2
    return 1
  }

  # If we're in a worktree, get the path to the main working tree
  local main_worktree
  main_worktree="$(git worktree list --porcelain | head -1 | sed 's/^worktree //')"

  cd "$main_worktree"
}

gwb() {
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

  local worktree_dir="$toplevel/.worktrees/$branch"

  if [[ -d "$worktree_dir" ]]; then
    cd "$worktree_dir"
    return
  fi

  mkdir -p "$(dirname "$worktree_dir")"
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$worktree_dir" "$branch" || return 1
  else
    git worktree add -b "$branch" "$worktree_dir" || return 1
  fi
  cd "$worktree_dir"
}
