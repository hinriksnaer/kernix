# kernix-sessionizer -- fuzzy-find a project and open it as a tmux session.
#
# Scans project directories for subdirectories, presents them via fzf,
# and either switches to an existing session or creates a new one with
# a standard 3-window layout (nvim, opencode, shell).

# ── Search paths ──
search_paths=(
  "$HOME/workspace/repos"
  "$HOME/kernix"
)

# ── Build candidate list ──
candidates=""
for dir in "${search_paths[@]}"; do
  if [ -d "$dir" ]; then
    # Add the directory itself if it's a project root (has .git)
    if [ -d "$dir/.git" ]; then
      candidates+="$dir"$'\n'
    fi
    # Add immediate subdirectories
    for sub in "$dir"/*/; do
      [ -d "$sub" ] && candidates+="$sub"$'\n'
    done
  fi
done

# Remove trailing slashes and empty lines
candidates=$(echo "$candidates" | sed 's:/$::' | grep -v '^$' | sort -u)

if [ -z "$candidates" ]; then
  echo "No project directories found"
  exit 0
fi

# ── fzf picker ──
selected=$(echo "$candidates" | fzf --prompt="project: " --layout=reverse --border \
  --delimiter=/ --with-nth=-1)

if [ -z "$selected" ]; then
  exit 0
fi

# ── Session name from directory basename (replace dots with underscores) ──
session_name=$(basename "$selected" | tr '.' '_')

# ── Switch to existing session or create new one ──
if tmux has-session -t="$session_name" 2>/dev/null; then
  tmux switch-client -t "$session_name"
else
  # Create session with 3 named windows
  tmux new-session -ds "$session_name" -c "$selected" -n "nvim"
  tmux send-keys -t "$session_name:nvim" "nvim" Enter

  tmux new-window -t "$session_name" -c "$selected" -n "opencode"
  tmux send-keys -t "$session_name:opencode" "opencode" Enter

  tmux new-window -t "$session_name" -c "$selected" -n "shell"

  # Focus first window (nvim)
  tmux select-window -t "$session_name:1"
  tmux switch-client -t "$session_name"
fi
