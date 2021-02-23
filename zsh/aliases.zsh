alias se='grep -rin'
alias reload!='. ~/.zshrc'
alias cppath='pwd | pbcopy'
alias mux="tmuxinator"
alias rand="env LC_CTYPE=C tr -dc \"A-Za-z0-9_\!\@#\$%^&*()-+=\" < /dev/urandom | head -c 32 | xargs"

# Create a new directory and enter it
function md() {
	mkdir -p "$@" && cd "$@"
}
