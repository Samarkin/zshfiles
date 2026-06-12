if which eza > /dev/null 2>&1; then
  alias ls='eza --classify=auto'
elif ls --version 2>&1 | grep -q 'GNU\|BusyBox'; then
  alias ls='ls -F --color=auto'
else
  alias ls='ls -FG'
fi

alias grep='grep --color=auto'
alias cd..='cd ..'
