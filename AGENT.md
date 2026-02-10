# Claude Code Guidelines

## Project Architecture

**Type**: Personal dotfiles repository
**Structure**: Topic-based organization with auto-loading

### Directory Layout
```
.dotfiles/
├── git/              # Git configs and aliases
├── vim/              # Vim/Neovim configuration
├── tmux/             # Tmux configuration
├── zsh/              # Zsh shell configuration
└── script/           # Installation scripts
```

### Loading Order
1. `topic/path.zsh` - Path configuration
2. `topic/*.zsh` - General shell scripts
3. `topic/completion.zsh` - Completion configs

### Key Mechanisms
- **Symlinks**: `*.symlink` files → `$HOME/.filename`
- **Auto-loading**: All `.zsh` files sourced at shell init
- **Bootstrap**: `script/bootstrap` handles initial setup

## Commit Message Guidelines

**IMPORTANT**: Do not include AI attribution in commit messages.

### Prohibited Patterns
- ❌ Co-Authored-By: Claude <noreply@anthropic.com>
- ❌ Generated with Claude Code
- ❌ AI-assisted commit
- ❌ Any AI attribution or signatures

### Preferred Style
- Use imperative mood ("Add feature" not "Added feature")
- Be concise and descriptive
- Focus on what changed and why
- Example: "Add gl-web function for GitLab branch URLs"

### Commit Format
```
Short summary (50 chars or less)

Detailed explanation if needed. Focus on motivation
and context rather than implementation details.
```

## Development Notes

- Avoid platform-specific dependencies outside macOS
- Test shell functions before committing
- Keep aliases short and memorable
- Document complex functions inline
- Maintain backward compatibility with existing configs
