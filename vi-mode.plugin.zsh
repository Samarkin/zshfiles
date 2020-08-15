# Enable vi keymap and make it pretty

KEYTIMEOUT=5 # Remove delays when switching modes

function zle-keymap-select zle-line-init {
  if [ $KEYMAP = vicmd ]; then
    echo -ne '\e[2 q' # Block for NORMAL mode
  else
    echo -ne '\e[4 q' # Underscore for INSERT mode
  fi
}
zle -N zle-keymap-select # Execute on each keymap change
zle -N zle-line-init # Execute before reading a new line of input

bindkey -v # Enable Vi Mode
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

_vi_mode_preexec() {
    echo -ne '\e[0 q' # Reset to default before executing any command
}
preexec_functions+=(_vi_mode_preexec)
