# Display execution time after commands that take longer than the threshold (default: 3 seconds)

_execution_time_preexec() {
  timer=$(($(print -P %D{%s%6.})/1000)) # Remember current time in msec before executing any command
  # Next prompt could be displayed even before the command is finished (e.g. background execution with '&')
  RPS1="" # reset the prompt
}

_execution_time_precmd() {
  if [ $timer ]; then
    # `local` is important here to not leak the variables outside of the function
    local now=$(($(print -P %D{%s%6.})/1000))
    local elapsed=$(($now-$timer))
    if [ $elapsed -ge ${ZSH_EXECUTION_TIME_THRESHOLD:-3000} ]; then
      RPS1=$(format_time $elapsed) # Set right prompt
    fi
    unset timer
  else
    # Next prompt could be displayed even if no command was entered (e.g. Ctrl+C or Enter on an empty line)
    RPS1="" # reset the prompt
  fi
}

format_time() {
  # Highlight numbers in bold and choose colors based on the command duration
  local hours=$(($1/3600000))
  local min=$(($1/60000))
  local sec=$((($1%60000)/1000))
  local msec=$(($1%1000))
  if [ "$1" -lt 10000 ]; then
    echo "%F{green}%B$1%b%f %F{green}ms.%f"
  elif [ "$1" -le 60000 ]; then
    echo "%F{green}%B$sec%b%f %F{green}s. %B$msec%b%f %F{green}ms.%f"
  elif [ "$1" -gt 60000 ] && [ "$1" -le 180000 ]; then
    echo "%F{yellow}%B$min%b%f %F{yellow}min. %B$sec%b%f %F{yellow}s.%f"
  else
    if [ "$hours" -gt 0 ]; then
      min=$(($min%60))
      echo "%F{red}%B$hours%b%f %F{red}h. %B$min%b%f %F{red}min. %B$sec%b%f %F{red}s.%f"
    else
      echo "%F{red}%B$min%b%f %F{red}min. %B$sec%b%f %F{red}s.%f"
    fi
  fi
}

precmd_functions+=(_execution_time_precmd)
preexec_functions+=(_execution_time_preexec)
