# Enable vi keymap and make it pretty

KEYTIMEOUT=5 # Remove delays when switching modes

# Linux console uses private cursor codes (ESC[?Nc); GUI terminals use DECSCUSR (ESC[N q)
if [[ $TERM == linux ]]; then
  _vi_mode_block='\e[?6c' # Full block for NORMAL mode
  _vi_mode_under='\e[?2c' # Underscore for INSERT mode
  _vi_mode_reset='\e[?0c' # Default cursor before executing any command
else
  _vi_mode_block='\e[2 q' # Steady block for NORMAL mode
  _vi_mode_under='\e[4 q' # Steady underscore for INSERT mode
  _vi_mode_reset='\e[0 q' # Default cursor before executing any command
fi

function zle-keymap-select zle-line-init {
  if [ $KEYMAP = vicmd ]; then
    echo -ne $_vi_mode_block
  else
    echo -ne $_vi_mode_under
  fi
}
zle -N zle-keymap-select # Execute on each keymap change
zle -N zle-line-init # Execute before reading a new line of input

bindkey -v # Enable Vi Mode
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

_vi_mode_preexec() {
    echo -ne $_vi_mode_reset # Reset to default before executing any command
}
preexec_functions+=(_vi_mode_preexec)
