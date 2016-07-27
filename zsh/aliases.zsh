alias se='grep -rin'
alias reload!='. ~/.zshrc'
alias cppath='pwd | pbcopy'
alias mux="tmuxinator"

# Create a new directory and enter it
function md() {
	mkdir -p "$@" && cd "$@"
}
