function ask() {
  if ! command -v claude &> /dev/null; then
    echo "Error: claude is not installed. See https://docs.anthropic.com/en/docs/claude-code" >&2
    return 1
  fi

  if command -v glow &> /dev/null; then
    claude -p "$@" | glow
  else
    echo "Warning: glow is not installed. Install with: brew install glow" >&2
    claude -p "$@"
  fi
}
