alias se='grep -rin'
alias reload!='. ~/.zshrc'
alias cppath='pwd | pbcopy'
alias mux="smug"
alias rand="env LC_CTYPE=C tr -dc \"A-Za-z0-9_\!\@#\$%^&*()-+=\" < /dev/urandom | head -c 32 | xargs"

# Create a new directory and enter it
function md() {
  mkdir -p "$@" && cd "$@"
}

gl-web() {
  # Get the current branch name
  local BRANCH=$(git branch --show-current 2>/dev/null)

  if [ -z "$BRANCH" ]; then
    echo "Error: Not in a git repository or no branch checked out"
    return 1
  fi

  # Get the origin remote URL
  local ORIGIN_URL=$(git remote get-url origin 2>/dev/null)

  if [ -z "$ORIGIN_URL" ]; then
    echo "Error: No 'origin' remote found"
    return 1
  fi

  # Parse the remote URL to extract GitLab instance, group, and project
  # Handle both SSH and HTTPS URLs

  if [[ $ORIGIN_URL =~ ^git@([^:]+):(.+)\.git$ ]]; then
    # SSH format: git@gitlab.example.com:group/project.git
    local GITLAB_INSTANCE="https://${match[1]}"
    local PROJECT_PATH="${match[2]}"
  elif [[ $ORIGIN_URL =~ ^https?://([^/]+)/(.+)\.git$ ]]; then
    # HTTPS format: https://gitlab.example.com/group/project.git
    local GITLAB_INSTANCE="https://${match[1]}"
    local PROJECT_PATH="${match[2]}"
  elif [[ $ORIGIN_URL =~ ^https?://([^/]+)/(.+)$ ]]; then
    # HTTPS format without .git: https://gitlab.example.com/group/project
    local GITLAB_INSTANCE="https://${match[1]}"
    local PROJECT_PATH="${match[2]}"
  else
    echo "Error: Unable to parse origin URL: $ORIGIN_URL"
    return 1
  fi

  # Construct the GitLab URL
  local GITLAB_URL="${GITLAB_INSTANCE}/${PROJECT_PATH}/-/tree/${BRANCH}"

  echo "Opening: $GITLAB_URL"

  # Open the URL in the default browser
  # Use 'open' on macOS, 'xdg-open' on Linux
  if command -v open &> /dev/null; then
    open "$GITLAB_URL"
  elif command -v xdg-open &> /dev/null; then
    xdg-open "$GITLAB_URL"
  else
    echo "Error: Cannot find a command to open the browser"
    echo "Please manually open: $GITLAB_URL"
    return 1
  fi
}
