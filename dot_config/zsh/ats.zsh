function export-schema() {
  local CONN_BASE='mysql://root:password@127.0.0.1:33306'
  local DATABASES=(
    "common"
    "customer_01KE5T5FVWZM81C2N4XKFGQFRG"
  )

  mkdir -p temp

  local SUCCESS=()
  local FAILED=()

  for db in "${DATABASES[@]}"; do
    local out="temp/schema_${db}.dbml"
    echo "→ $db を処理中..."
    if pnpm --package=@dbml/cli dlx db2dbml mysql "${CONN_BASE}/${db}" -o "$out"; then
      SUCCESS+=("$out")
    else
      FAILED+=("$out")
    fi
  done

  echo ""
  echo "生成完了:"
  for f in "${SUCCESS[@]}"; do echo "  ✓ $f"; done
  for f in "${FAILED[@]}"; do echo "  ✗ $f（失敗）"; done
}

function recruitment-flow() {
  # 引数チェック
  if [[ "$1" != "0" && "$1" != "1" ]]; then
    echo "❌ エラー: 引数に 1（有効化）または 0（無効化）を指定してください"
    return 1
  fi

  # プロジェクトルートチェック
  if [[ ! -f "docker-compose.yml" && ! -f "compose.yml" && ! -f "docker-compose.yaml" ]]; then
    echo "❌ エラー: docker-compose.yml が見つかりません。プロジェクトルートで実行してください"
    return 1
  fi

  # コンテナ起動チェック
  local running_services
  running_services=$(docker compose ps --services --filter status=running 2>/dev/null)

  if ! echo "$running_services" | grep -q "^mysql$"; then
    echo "❌ エラー: mysql コンテナが起動していません"
    return 1
  fi

  if ! echo "$running_services" | grep -q "^api$"; then
    echo "❌ エラー: api コンテナが起動していません"
    return 1
  fi

  if [[ "$1" == "1" ]]; then
    echo "🔄 選考フロー Toggle を有効化しています..."
    docker compose exec -T mysql mysql -uroot -ppassword common < backend/build/toggles/recruitment_flow_toggle_local_on.sql || {
      echo "❌ エラー: MySQL への SQL 実行に失敗しました"
      return 1
    }
    docker compose exec -T api make operation_role_seeding || {
      echo "❌ エラー: operation_role_seeding の実行に失敗しました"
      return 1
    }
    echo "✅ 選考フロー Toggle を有効化しました"
  else
    echo "🔄 選考フロー Toggle を無効化しています..."
    docker compose exec -T mysql mysql -uroot -ppassword common < backend/build/toggles/recruitment_flow_toggle_off.sql || {
      echo "❌ エラー: MySQL への SQL 実行に失敗しました"
      return 1
    }
    docker compose exec -T api make operation_role_seeding || {
      echo "❌ エラー: operation_role_seeding の実行に失敗しました"
      return 1
    }
    echo "✅ 選考フロー Toggle を無効化しました"
  fi
}

function manage-flow() {
  # 引数チェック
  if [[ "$1" != "0" && "$1" != "1" ]]; then
    echo "❌ エラー: 引数に 1（有効化）または 0（無効化）を指定してください"
    return 1
  fi

  # プロジェクトルートチェック
  if [[ ! -f "docker-compose.yml" && ! -f "compose.yml" && ! -f "docker-compose.yaml" ]]; then
    echo "❌ エラー: docker-compose.yml が見つかりません。プロジェクトルートで実行してください"
    return 1
  fi

  # コンテナ起動チェック
  local running_services
  running_services=$(docker compose ps --services --filter status=running 2>/dev/null)

  if ! echo "$running_services" | grep -q "^mysql$"; then
    echo "❌ エラー: mysql コンテナが起動していません"
    return 1
  fi

  if [[ "$1" == "1" ]]; then
    echo "🔄 選考フロー管理 Toggle を有効化しています..."
    docker compose exec -T mysql mysql -uroot -ppassword common < backend/build/toggles/manage_flow_toggle_local_on.sql || {
      echo "❌ エラー: MySQL への SQL 実行に失敗しました"
      return 1
    }
    echo "✅ 選考フロー管理 Toggle を有効化しました"
  else
    echo "🔄 選考フロー管理 Toggle を無効化しています..."
    docker compose exec -T mysql mysql -uroot -ppassword common < backend/build/toggles/manage_flow_toggle_off.sql || {
      echo "❌ エラー: MySQL への SQL 実行に失敗しました"
      return 1
    }
    echo "✅ 選考フロー管理 Toggle を無効化しました"
  fi
}

function ssm() {
  local selected instance_id

  selected=$(
    aws ec2 describe-instances \
      --filters \
        "Name=tag:Name,Values=*apples*" \
        "Name=instance-state-name,Values=running" \
      --query "Reservations[].Instances[].[Tags[?Key=='Name'].Value | [0], InstanceId]" \
      --output text \
      2>/dev/null \
    | awk '{printf "%-50s %s\n", $1, $2}' \
    | fzf --reverse --prompt "SSM target> "
  )

  [[ -z "$selected" ]] && return

  instance_id=$(awk '{print $NF}' <<< "$selected")

  aws ssm start-session --target "$instance_id"
}
