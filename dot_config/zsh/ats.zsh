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

source ~/.config/zsh/ats-feature-toggle.zsh

function _aws_ensure_login() {
    if ! aws sts get-caller-identity --profile apples-bastion &>/dev/null; then
        echo "Not logged in. Running 'aws sso login'..."
        aws sso login --profile apples-bastion || return 1
    fi
}

function ssm() {
  _aws_ensure_login || return
  
  local selected instance_id
  bastion_profile="apples-bastion"

  selected=$(
    aws ec2 describe-instances \
      --profile "$bastion_profile" \
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

  aws ssm start-session --profile "$bastion_profile" --target "$instance_id"
}
