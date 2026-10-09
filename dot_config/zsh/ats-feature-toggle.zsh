# feature toggle 切り替え関数
# 使い方: recruitment-flow 1|0 / manage-flow 1|0 / applicant-search 1|0

# _apply_feature_toggle <表示名> <SQLファイルのプレフィックス> <有効化: 1 / 無効化: 0> [追加で起動を要求するサービス...]
# 事前チェック（引数・プロジェクトルート・コンテナ起動）の後、common DB に toggle の SQL を流す
function _apply_feature_toggle() {
  local label="$1" prefix="$2" state="$3"
  shift 3
  local required_services=(mysql "$@")
  local sql_dir="backend/build/toggles"

  # 引数チェック
  if [[ "$state" != "0" && "$state" != "1" ]]; then
    echo "❌ エラー: 引数に 1（有効化）または 0（無効化）を指定してください"
    return 1
  fi

  # プロジェクトルートチェック
  if [[ ! -f "docker-compose.yml" && ! -f "compose.yml" && ! -f "docker-compose.yaml" ]]; then
    echo "❌ エラー: docker-compose.yml が見つかりません。プロジェクトルートで実行してください"
    return 1
  fi

  # コンテナ起動チェック
  local running_services svc
  running_services=$(docker compose ps --services --filter status=running 2>/dev/null)
  for svc in "${required_services[@]}"; do
    if ! echo "$running_services" | grep -q "^${svc}$"; then
      echo "❌ エラー: ${svc} コンテナが起動していません"
      return 1
    fi
  done

  local action sql
  if [[ "$state" == "1" ]]; then
    action="有効化"
    sql="${sql_dir}/${prefix}_toggle_local_on.sql"
  else
    action="無効化"
    sql="${sql_dir}/${prefix}_toggle_off.sql"
  fi

  echo "🔄 ${label} Toggle を${action}しています..."
  docker compose exec -T mysql mysql -uroot -ppassword common < "$sql" || {
    echo "❌ エラー: MySQL への SQL 実行に失敗しました"
    return 1
  }
  echo "✅ ${label} Toggle を${action}しました"
}

# 選考フロー（toggle 切り替え後に operation_role_seeding も実行）
function recruitment-flow() {
  _apply_feature_toggle "選考フロー" "recruitment_flow" "$1" api || return 1

  echo "🔄 operation_role_seeding を実行しています..."
  docker compose exec -T api make operation_role_seeding || {
    echo "❌ エラー: operation_role_seeding の実行に失敗しました"
    return 1
  }
}

# 選考フロー管理
function manage-flow() {
  _apply_feature_toggle "選考フロー管理" "manage_flow" "$1"
}

# 応募者検索
function applicant-search() {
  _apply_feature_toggle "応募者検索" "applicant_search" "$1"
}
