# GitLab Merge Request Status for Zsh Prompt
# Displays MR indicator and pipeline status for the current branch

# Configuration
ZSH_GITLAB_CACHE_TTL=${ZSH_GITLAB_CACHE_TTL:-120}  # Cache TTL in seconds (default: 120)
ZSH_GITLAB_CACHE_DIR="${TMPDIR:-/tmp}/zsh-gitlab-cache"
ZSH_GITLAB_MR_ICON="${ZSH_GITLAB_MR_ICON:-󰊢}"      # Merge request icon

# Generate unique cache key from repo path + branch name
_gitlab_cache_key() {
  local repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return 1
  # Use md5 to hash repo path for shorter, filesystem-safe key
  echo "$(echo -n "$repo_root" | md5).$branch"
}

# Check if cache file exists and is fresh
_gitlab_is_cache_valid() {
  local cache_file="$1"
  [[ -f "$cache_file" ]] || return 1

  # Get cache age in seconds
  local cache_age=$(( $(date +%s) - $(stat -f%m "$cache_file" 2>/dev/null || echo 0) ))
  [[ $cache_age -lt $ZSH_GITLAB_CACHE_TTL ]]
}

# Background worker: Fetch MR and pipeline status from GitLab API
_gitlab_fetch_mr_status() {
  local cache_key="$1"
  local cache_dir="$2"

  # Ensure cache directory exists
  mkdir -p "$cache_dir" 2>/dev/null

  # Get current branch
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return

  # Check if glab is available
  command -v glab >/dev/null 2>&1 || return

  # Fetch MR data from GitLab API and parse with jq
  # Using :id placeholder which glab resolves to current project
  # Pipe directly to jq to avoid shell variable escaping issues
  local mr_count=$(glab api "projects/:id/merge_requests?source_branch=$branch&state=opened" 2>/dev/null | jq 'length' 2>/dev/null || echo "0")

  if [[ "$mr_count" -gt 0 ]]; then
    # MR exists
    echo "true" > "$cache_dir/$cache_key.mr"

    # Extract pipeline status from MR data
    local pipeline_status=$(glab api "projects/:id/merge_requests?source_branch=$branch&state=opened" 2>/dev/null | jq -r '.[0].head_pipeline.status // "none"' 2>/dev/null || echo "none")

    # If MR has no pipeline, fall back to commit pipeline
    if [[ "$pipeline_status" == "none" ]]; then
      local commit_sha=$(git rev-parse HEAD 2>/dev/null)
      if [[ -n "$commit_sha" ]]; then
        pipeline_status=$(glab api "projects/:id/repository/commits/$commit_sha" 2>/dev/null | jq -r '.last_pipeline.status // "none"' 2>/dev/null || echo "none")
      fi
    fi

    echo "$pipeline_status" > "$cache_dir/$cache_key.pipeline"
  else
    # No MR found
    echo "false" > "$cache_dir/$cache_key.mr"
    echo "none" > "$cache_dir/$cache_key.pipeline"
  fi

  # Signal parent shell that update is complete
  kill -USR1 $$ 2>/dev/null
}

# Trigger async fetch if cache is stale (called by precmd hook)
_gitlab_trigger_async_fetch() {
  # Only run if we're in a git repository
  git rev-parse --git-dir &>/dev/null || return

  # Get cache key
  local cache_key=$(_gitlab_cache_key) || return
  local mr_cache="$ZSH_GITLAB_CACHE_DIR/$cache_key.mr"

  # If cache is valid, skip fetch
  _gitlab_is_cache_valid "$mr_cache" && return

  # Spawn background job to fetch fresh data
  # Using &! to disown the job (run in background without job control)
  (
    _gitlab_fetch_mr_status "$cache_key" "$ZSH_GITLAB_CACHE_DIR" &
  ) &!
}

# Main function: Return formatted GitLab MR status for prompt
gitlab_mr_prompt_info() {
  # Return empty if not in git repo
  git rev-parse --git-dir &>/dev/null || return

  # Get cache key
  local cache_key=$(_gitlab_cache_key) || return

  # Read from cache
  local mr_cache="$ZSH_GITLAB_CACHE_DIR/$cache_key.mr"
  local pipeline_cache="$ZSH_GITLAB_CACHE_DIR/$cache_key.pipeline"

  # If no cache exists, return empty (async fetch will populate it)
  [[ -f "$mr_cache" ]] || return

  # Check if MR exists
  local has_mr=$(cat "$mr_cache" 2>/dev/null)
  [[ "$has_mr" == "true" ]] || return

  # MR exists, show icon
  local output=" $ZSH_GITLAB_MR_ICON"

  # Add pipeline status if available
  if [[ -f "$pipeline_cache" ]]; then
    local pipeline_status=$(cat "$pipeline_cache" 2>/dev/null)
    case "$pipeline_status" in
      success)
        output="$output %{$fg[green]%}✓%{$reset_color%}"
        ;;
      failed)
        output="$output %{$fg[red]%}✗%{$reset_color%}"
        ;;
      running)
        output="$output %{$fg[yellow]%}●%{$reset_color%}"
        ;;
      pending)
        output="$output %{$fg[yellow]%}◷%{$reset_color%}"
        ;;
      canceled)
        output="$output ○"
        ;;
      skipped)
        output="$output -"
        ;;
      # If pipeline_status is "none" or unknown, just show MR icon without status
    esac
  fi

  echo "$output"
}

# Set up hooks
autoload -U add-zsh-hook
add-zsh-hook precmd _gitlab_trigger_async_fetch

# Handle async completion signal
TRAPUSR1() {
  # Redraw prompt when background job completes
  zle && zle reset-prompt
}
