function hello-mitani() {
  if [[ -z "$SLACK_MY_WORKFLOW_WEBHOOK_URL" ]]; then
    echo "SLACK_MY_WORKFLOW_WEBHOOK_URL が未設定です" >&2
    return 1
  fi
  if [[ $# -eq 0 ]]; then
    echo "usage: hello-mitani <message>" >&2
    return 1
  fi
  curl -sS -X POST -H 'Content-Type: application/json' \
    --data "$(jq -n --arg m "$*" '{message: $m}')" \
    "$SLACK_MY_WORKFLOW_WEBHOOK_URL"
}
