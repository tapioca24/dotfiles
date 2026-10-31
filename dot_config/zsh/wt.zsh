# herdr の worktree 操作
#   wt            fzf で選んで開く (今いる worktree は除く)
#   wt n [branch [base]]
#                 作成して開く (<repo>/.claude/worktrees/<branch>)
#                 branch : ブランチ名 (ASCII のみ)。Workspace 表示名 (herdr の --label) にも同じ値を使う
#                          省略 / "" なら "<形容詞>-<名詞>-YYYYMMDD-HHMMSS" を自動生成
#                 base   : 派生元。省略 / "" なら origin のデフォルトブランチ (origin/HEAD)
#                          "." なら今いるブランチ (detached HEAD ではエラー)
#                 左に claude、右を上下 2 分割のレイアウトで開く
#                 <repo>/.notes を各 worktree に symlink (全 worktree 共通のメモ置き場)
#   wt d          fzf (複数選択可) で選んで削除。今いる worktree は "@" 付きで候補に入る
#                 今いる worktree を選んだ場合は、他を消した後に main へ移動してから消す
#   wt d .        今いる worktree を削除 (main に移動してから)

_wt_usage="usage: wt [n [branch [base]] | d [.]]"

# TSV: mark, branch, path, open_workspace_id, is_linked_worktree
function _wt_list() {
  # herdr が失敗したら jq の成功で上書きせず、非 0 で返す
  setopt local_options pipefail
  herdr worktree list | jq -r '.result.worktrees[]
    | [(if .open_workspace_id then "*" else " " end), (.branch // "(detached)"), .path, (.open_workspace_id // ""), (.is_linked_worktree | tostring)]
    | @tsv'
}

# $1: _wt_list の出力。main worktree のパスを返す
function _wt_main() {
  awk -F'\t' '$5 == "false" { print $3; exit }' <<<"$1"
}

# $1: _wt_list の 1 行。各列を配列 $reply に入れる
# read + IFS=$'\t' だとタブが連続する空列 (open_workspace_id なし) が潰れるので (@ps:\t:) で分割する
function _wt_fields() {
  reply=("${(@ps:\t:)1}")
}

# $1: _wt_list の出力
# $2 == linked: linked worktree のみ・複数選択。現在地も含め、mark 列を "@" にして区別する
# それ以外    : すべて。現在地は除く
function _wt_pick() {
  local lines cur
  cur=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ $2 == linked ]]; then
    lines=$(awk -F'\t' -v OFS='\t' -v cur="$cur" '$5 == "true" { if ($3 == cur) $1 = "@"; print }' <<<"$1")
  else
    lines=$(awk -F'\t' -v cur="$cur" '$3 != cur' <<<"$1")
  fi
  if [[ -z $lines ]]; then
    echo "対象の worktree がありません" >&2
    return 1
  fi
  local opts=(--reverse --delimiter=$'\t' --with-nth=1,2,3
    --preview 'git -C {3} log --oneline -10; echo; git -C {3} status -sb')
  [[ $2 == linked ]] && opts+=(--multi --header '@: 今いる worktree')
  fzf "${opts[@]}" <<<"$lines"
}

function _wt_open() {
  local all sel main
  all=$(_wt_list) || return 1
  sel=$(_wt_pick "$all") || return 1
  main=$(_wt_main "$all")
  _wt_fields "$sel"
  # linked worktree の workspace からは開けないので、親 repo を起点にする
  herdr worktree open --cwd "$main" --path "${reply[3]}" --focus >/dev/null
}

# 結果は $REPLY に入れる。$(...) で呼ぶとサブシェルで RANDOM が進まず、毎回同じ名前になる
# 形式: <形容詞>-<名詞>-YYYYMMDD-HHMMSS
function _wt_random_name() {
  local adjectives=(happy quick big small red blue green white black brave calm clever cool cute gentle
    good great hot cold kind lucky new old pretty proud quiet rich shiny silent smart soft strong
    sweet tall warm wild young bright fresh funny)
  local nouns=(panda tiger apple tea mountain river moon sun cat dog bird fish horse rabbit lion
    monkey bear fox wolf tree flower rain snow wind cloud star sea lake forest island rice bread
    cake orange lemon melon ball book bike train)
  # ${(%):-%D{...}} と直接書くと内側の } で展開が閉じるので、書式は変数に分ける
  local ts_fmt='%D{%Y%m%d-%H%M%S}'
  REPLY="${adjectives[RANDOM % $#adjectives + 1]}-${nouns[RANDOM % $#nouns + 1]}-${(%)ts_fmt}"
}

function _wt_new() {
  if (( $# > 2 )); then
    echo "引数が多すぎます" >&2
    echo "$_wt_usage" >&2
    return 1
  fi
  local branch=$1 base=$2 common repo out
  # 空白や制御文字は後の check-ref-format で弾かれるので、ここでは非 ASCII だけ見る
  if [[ $branch == *[^[:ascii:]]* ]]; then
    echo "ブランチ名は ASCII のみ使えます: $branch" >&2
    return 1
  fi
  common=$(git rev-parse --path-format=absolute --git-common-dir) || return 1
  repo=${common:h}
  if [[ -z $branch ]]; then
    _wt_random_name
    branch=$REPLY
  fi
  git check-ref-format --branch "$branch" >/dev/null 2>&1 || {
    echo "ブランチ名として使えません: $branch" >&2
    return 1
  }
  # base が "." なら今いるブランチから派生する
  if [[ $base == . ]]; then
    base=$(git branch --show-current)
    if [[ -z $base ]]; then
      echo "detached HEAD のため base に . は使えません。base に ref を指定してください" >&2
      return 1
    fi
  fi
  # base 未指定なら origin/HEAD (origin のデフォルトブランチ)。fetch はしない
  if [[ -z $base ]]; then
    base=$(git -C "$repo" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
    if [[ -z $base ]]; then
      echo "origin/HEAD を解決できません。'git remote set-head origin -a' で設定するか、base を指定してください" >&2
      return 1
    fi
  fi
  # 既存ブランチだと base から派生せず、既存の状態のまま使われるので確認する
  if git -C "$repo" show-ref --verify --quiet "refs/heads/$branch"; then
    echo "ブランチ '$branch' は既に存在します。base ($base) からは派生されず、既存の状態で開きます。" >&2
    local ans
    read -k 1 "ans?[Y] 既存で開く / [r] 削除して作り直す / [n] 中止: "
    echo
    case $ans in
      [nN]) return 1 ;;
      [rR])
        # -d なのでマージ済みでないブランチや他の worktree で使用中のブランチは消えない
        git -C "$repo" branch -d "$branch" || return 1
        ;;
    esac
  fi
  local wt_path="$repo/.claude/worktrees/${branch//\//-}"
  # stdout (JSON) だけを捕まえる。stderr は端末にそのまま流し、jq に混ぜない
  out=$(herdr worktree create --cwd "$repo" --branch "$branch" --base "$base" \
    --path "$wt_path" --label "$branch" --focus) || return 1
  # 全 worktree 共通のメモ置き場 (<repo>/.notes) を symlink で共有する
  mkdir -p "$repo/.notes"
  ln -sfn "$repo/.notes" "$wt_path/.notes"
  _wt_layout "$(jq -r '.result.root_pane.pane_id' <<<"$out")"
}

# 左: claude / 右: 上下 2 分割。root pane (左) にフォーカスを残す
function _wt_layout() {
  local left=$1 right
  right=$(herdr pane split --pane "$left" --direction right --no-focus | jq -r '.result.pane.pane_id') || return 1
  herdr pane split --pane "$right" --direction down --no-focus >/dev/null
  herdr pane run "$left" claude >/dev/null
}

# $1: _wt_list の 1 行 / $2: main worktree のパス
function _wt_remove_one() {
  local main=$2
  _wt_fields "$1"
  local wt_path=${reply[3]} ws=${reply[4]}
  if [[ -n $ws ]]; then
    herdr worktree remove --workspace "$ws" >/dev/null
  else
    git -C "$main" worktree remove "$wt_path"
  fi
}

# 今いる worktree を消す前に呼ぶ。消える場所に残らないよう、main へ移動してフォーカスも移す
function _wt_leave_to_main() {
  local main=$1
  cd "$main" || return 1
  herdr worktree open --cwd "$main" --path "$main" --focus >/dev/null
}

function _wt_remove() {
  local all main line
  all=$(_wt_list) || return 1
  main=$(_wt_main "$all")

  if [[ $1 == . ]]; then
    local cur
    cur=$(git rev-parse --show-toplevel 2>/dev/null)
    line=$(awk -F'\t' -v cur="$cur" '$3 == cur && $5 == "true"' <<<"$all")
    if [[ -z $line ]]; then
      echo "今いる場所は削除できる worktree ではありません" >&2
      return 1
    fi
    _wt_leave_to_main "$main" || return 1
    _wt_remove_one "$line" "$main"
    return
  fi

  local sel cur_line
  sel=$(_wt_pick "$all" linked) || return 1
  while IFS= read -r line; do
    _wt_fields "$line"
    # 今いる worktree は、自分のいる workspace ごと消えるので最後に回す
    if [[ ${reply[1]} == @ ]]; then
      cur_line=$line
      continue
    fi
    _wt_remove_one "$line" "$main"
  done <<<"$sel"
  if [[ -n $cur_line ]]; then
    _wt_leave_to_main "$main" || return 1
    _wt_remove_one "$cur_line" "$main"
  fi
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
    *) echo "$_wt_usage" >&2; return 1 ;;
  esac
}
