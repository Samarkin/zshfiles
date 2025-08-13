# Set prompt to current date and time, colored full path in the scp-compatible format, and last exitcode on the new line

PS1="(%D %*) %F{green}%n%f@%F{${ZSH_PROMPT_COLOR:-yellow}}%m%f:%F{magenta}%0~%f
%(?.%F{green}√.%F{red}<%?>)%f %(!.#.$) "
