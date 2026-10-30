# herdr の worktree 操作
#   wt            fzf で選んで開く
#   wt n [branch [base]] 作成して開く (<repo>/.claude/worktrees/<branch-slug>)
#                        base 省略時は origin のデフォルトブランチから派生
#   wt d          fzf (複数選択可) で選んで削除 (今いる worktree は除く)
#   wt d .        今いる worktree を削除 (main に移動してから)

# TSV: mark, branch, path, open_workspace_id, is_linked_worktree
function _wt_list() {
  herdr worktree list | jq -r '.result.worktrees[]
    | [(if .open_workspace_id then "*" else " " end), (.branch // "(detached)"), .path, (.open_workspace_id // ""), (.is_linked_worktree | tostring)]
    | @tsv'
}

# $1 == linked: linked worktree のみ・複数選択 / それ以外: すべて (どちらも現在地は除く)
function _wt_pick() {
  local lines cur
  cur=$(git rev-parse --show-toplevel 2>/dev/null)
  lines=$(_wt_list | awk -F'\t' -v cur="$cur" '$3 != cur') || return 1
  [[ $1 == linked ]] && lines=$(awk -F'\t' '$5 == "true"' <<<"$lines")
  if [[ -z $lines ]]; then
    echo "対象の worktree がありません" >&2
    return 1
  fi
  local opts=(--reverse --delimiter=$'\t' --with-nth=1,2,3
    --preview 'git -C {3} log --oneline -10; echo; git -C {3} status -sb')
  [[ $1 == linked ]] && opts+=(--multi)
  fzf "${opts[@]}" <<<"$lines"
}

function _wt_open() {
  local sel wt_path main
  sel=$(_wt_pick) || return 1
  wt_path=$(cut -f3 <<<"$sel")
  main=$(_wt_list | awk -F'\t' '$5 == "false" { print $3; exit }')
  # linked worktree の workspace からは開けないので、親 repo を起点にする
  herdr worktree open --cwd "$main" --path "$wt_path" --focus >/dev/null
}

function _wt_new() {
  local branch=$1 base=$2 common out
  if [[ -z $branch ]]; then
    read "branch?ブランチ名: "
  fi
  [[ -z $branch ]] && return 1
  common=$(git rev-parse --path-format=absolute --git-common-dir) || return 1
  # base 未指定なら origin のデフォルトブランチ (取れなければ main)。fetch はしない
  if [[ -z $base ]]; then
    base=$(git -C "${common:h}" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
    base=${base:-main}
  fi
  out=$(herdr worktree create --cwd "${common:h}" --branch "$branch" --base "$base" \
    --path "${common:h}/.claude/worktrees/${branch//\//-}" --focus 2>&1) || {
    echo "$out" >&2
    return 1
  }
}

function _wt_remove_one() {
  local wt_path=$1 ws=$2 main=$3
  if [[ -n $ws ]]; then
    herdr worktree remove --workspace "$ws" >/dev/null
  else
    git -C "$main" worktree remove "$wt_path"
  fi
}

function _wt_remove() {
  local all main line
  all=$(_wt_list) || return 1
  main=$(awk -F'\t' '$5 == "false" { print $3; exit }' <<<"$all")

  if [[ $1 == . ]]; then
    local cur
    cur=$(git rev-parse --show-toplevel 2>/dev/null)
    line=$(awk -F'\t' -v cur="$cur" '$3 == cur && $5 == "true"' <<<"$all")
    if [[ -z $line ]]; then
      echo "今いる場所は削除できる worktree ではありません" >&2
      return 1
    fi
    # 消える場所に残らないよう、先に main へ移動してフォーカスも移す
    cd "$main" || return 1
    herdr worktree open --cwd "$main" --path "$main" --focus >/dev/null
    _wt_remove_one "$(cut -f3 <<<"$line")" "$(cut -f4 <<<"$line")" "$main"
    return
  fi

  local sel
  sel=$(_wt_pick linked) || return 1
  while IFS= read -r line; do
    _wt_remove_one "$(cut -f3 <<<"$line")" "$(cut -f4 <<<"$line")" "$main"
  done <<<"$sel"
}

function wt() {
  if [[ -z $HERDR_ENV ]]; then
    echo "herdr がない環境では使えません" >&2
    return 1
  fi
  case $1 in
    "") _wt_open ;;
    n) shift; _wt_new "$@" ;;
    d) shift; _wt_remove "$@" ;;
    *) echo "usage: wt [n [branch [base]] | d [.]]" >&2; return 1 ;;
  esac
}
