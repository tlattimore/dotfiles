# tlattimore's dotfiles

Personalized macOS development environment based on topical organization.

## Assumptions

- macOS operating system
- Zsh as default shell
- Git version control
- Homebrew installed
- Neovim/Vim available
- Terminal with 256-color support

## Installation

```sh
git clone https://github.com/tlattimore/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

Bootstrap symlinks `.symlink` files to `$HOME` and configures git.

## Dependency Management

- **Antigen**: Zsh plugin management
- **vim-plug**: Vim/Neovim plugin management
- **Homebrew**: macOS package installation
- **Bootstrap script**: Automated symlink creation

## Structure

- `topic/*.zsh`: Auto-loaded shell scripts
- `topic/path.zsh`: Loaded first for `$PATH` setup
- `topic/completion.zsh`: Loaded last for autocomplete
- `topic/*.symlink`: Symlinked to `$HOME` as dotfiles

## Custom Functions

### Shell Navigation
- **md()** - Make directory and cd into it
- **title()** - Set terminal window title

### Git Utilities
- **gl-web()** - Open current branch in GitLab web UI

### Environment
- **virtualenv_info()** - Display active Python virtualenv
- **hg_prompt_info()** - Display Mercurial repository info

## Aliases

### Search & System
- **se** - Recursive grep search
- **reload!** - Reload zsh configuration
- **cppath** - Copy current path to clipboard
- **rand** - Generate 32-char random string

### Tool Shortcuts
- **vi** - Launch vim
- **vim** - Launch nvim
- **mux** - Shortcut for tmuxinator
- **atc** - Attach to tmux session

### Git
- **gpull** - Git pull with rebase from origin
- **gpush** - Git push to origin
