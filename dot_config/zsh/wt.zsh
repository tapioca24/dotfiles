# herdr の worktree 操作
#   wt            fzf で選んで開く
#   wt n [branch [base]] 作成して開く (<repo>/.claude/worktrees/<branch-slug>)
#                        branch 省略時は wt/<形容詞>-<名詞>-YYYYMMDD-HHMMSS を自動生成
#                        左に claude、右を上下 2 分割のレイアウトで開く
#                        base 省略時は origin のデフォルトブランチから派生
#                        <repo>/.notes を各 worktree に symlink (全 worktree 共通のメモ置き場)
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

# ブランチ名省略時の自動生成用: wt/<形容詞>-<名詞>-YYYYMMDD-HHMMSS
_wt_adjectives=(happy quick big small red blue green white black brave calm clever cool cute gentle
  good great hot cold kind lucky new old pretty proud quiet rich shiny silent smart soft strong
  sweet tall warm wild young bright fresh funny)
_wt_nouns=(panda tiger apple tea mountain river moon sun cat dog bird fish horse rabbit lion
  monkey bear fox wolf tree flower rain snow wind cloud star sea lake forest island rice bread
  cake orange lemon melon ball book bike train)

function _wt_random_branch() {
  echo "wt/${_wt_adjectives[RANDOM % $#_wt_adjectives + 1]}-${_wt_nouns[RANDOM % $#_wt_nouns + 1]}-$(date +%Y%m%d-%H%M%S)"
}

function _wt_new() {
  local branch=${1:-$(_wt_random_branch)} base=$2 common out
  common=$(git rev-parse --path-format=absolute --git-common-dir) || return 1
  # base 未指定なら origin のデフォルトブランチ (取れなければ main)。fetch はしない
  if [[ -z $base ]]; then
    base=$(git -C "${common:h}" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
    base=${base:-main}
  fi
  # 既存ブランチだと base から派生せず、既存の状態のまま使われるので確認する
  if git -C "${common:h}" show-ref --verify --quiet "refs/heads/$branch"; then
    echo "ブランチ '$branch' は既に存在します。base ($base) からは派生されず、既存の状態で開きます。" >&2
    local ans
    read -k 1 "ans?[Y] 既存で開く / [r] 削除して作り直す / [n] 中止: "
    echo
    case $ans in
      [nN]) return 1 ;;
      [rR])
        # -d なのでマージ済みでないブランチや他の worktree で使用中のブランチは消えない
        git -C "${common:h}" branch -d "$branch" || return 1
        ;;
    esac
  fi
  local wt_path="${common:h}/.claude/worktrees/${branch//\//-}"
  out=$(herdr worktree create --cwd "${common:h}" --branch "$branch" --base "$base" \
    --path "$wt_path" --focus 2>&1) || {
    echo "$out" >&2
    return 1
  }
  # 全 worktree 共通のメモ置き場 (<repo>/.notes) を symlink で共有する
  mkdir -p "${common:h}/.notes"
  ln -s "${common:h}/.notes" "$wt_path/.notes"
  _wt_layout "$(jq -r '.result.root_pane.pane_id' <<<"$out")"
}

# 左: claude / 右: 上下 2 分割。root pane (左) にフォーカスを残す
function _wt_layout() {
  local left=$1 right
  right=$(herdr pane split --pane "$left" --direction right --no-focus | jq -r '.result.pane.pane_id') || return 1
  herdr pane split --pane "$right" --direction down --no-focus >/dev/null
  herdr pane run "$left" claude >/dev/null
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
