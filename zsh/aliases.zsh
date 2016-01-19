alias se='grep -rin'
alias reload!='. ~/.zshrc'
alias cppath='pwd | pbcopy'

# Create a new directory and enter it
function md() {
	mkdir -p "$@" && cd "$@"
}
