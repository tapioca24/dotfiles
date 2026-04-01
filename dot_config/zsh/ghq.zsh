function _ghq_fzf() {
  local repo
  repo=$(ghq list -p | fzf --preview "ls -la {}")
  [[ -n "$repo" ]] && cd "$repo"
  zle reset-prompt
}
zle -N _ghq_fzf
bindkey '^g' _ghq_fzf
