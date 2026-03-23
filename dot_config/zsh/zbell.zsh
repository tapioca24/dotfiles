# Notification bell for long-running commands
# Plays different sounds on success/failure for commands exceeding the threshold

ZBELL_THRESHOLD=10  # seconds

ZBELL_SUCCESS_SOUND="/System/Library/Sounds/Glass.aiff"
ZBELL_FAILURE_SOUND="/System/Library/Sounds/Sosumi.aiff"

ZBELL_IGNORE=(vim nvim less more man ssh top htop)

zbell_preexec() {
  zbell_timestamp=$EPOCHSECONDS
  zbell_command="$1"
}

zbell_precmd() {
  local exit_status=$?
  [[ -z "$zbell_timestamp" ]] && return

  local elapsed=$(( EPOCHSECONDS - zbell_timestamp ))
  unset zbell_timestamp

  (( elapsed < ZBELL_THRESHOLD )) && return

  local cmd=${zbell_command%% *}
  for ignore in $ZBELL_IGNORE; do
    [[ "$cmd" == "$ignore" ]] && return
  done

  if (( exit_status == 0 )); then
    (afplay "$ZBELL_SUCCESS_SOUND" &)
  else
    (afplay "$ZBELL_FAILURE_SOUND" &)
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec zbell_preexec
add-zsh-hook precmd zbell_precmd
