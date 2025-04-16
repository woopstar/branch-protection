#!/bin/bash

CONFIG_FILE=".github/branch-protection.yml"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ Configuration file not found: $CONFIG_FILE"
  exit 1
fi

BRANCHES=$(yq eval '.branches | keys | .[]' "$CONFIG_FILE")

for BRANCH in $BRANCHES; do
  echo "🔐 Applying rules for branch: $BRANCH"

  PAYLOAD="{"

  # enforce_admins
  if yq e ".branches.\"$BRANCH\".enforce_admins" "$CONFIG_FILE" >/dev/null; then
    VALUE=$(yq e ".branches.\"$BRANCH\".enforce_admins" "$CONFIG_FILE")
    PAYLOAD+="\"enforce_admins\": $VALUE,"
  fi

  # required_status_checks
  if yq e ".branches.\"$BRANCH\".required_status_checks" "$CONFIG_FILE" >/dev/null; then
    STRICT=$(yq e ".branches.\"$BRANCH\".required_status_checks.strict" "$CONFIG_FILE")
    CONTEXTS=$(yq e ".branches.\"$BRANCH\".required_status_checks.contexts[]" "$CONFIG_FILE" 2>/dev/null | jq -R . | jq -sc .)
    PAYLOAD+="\"required_status_checks\": {\"strict\": $STRICT, \"contexts\": $CONTEXTS},"
  fi

  # required_pull_request_reviews
  if yq e ".branches.\"$BRANCH\".required_pull_request_reviews" "$CONFIG_FILE" >/dev/null; then
    DISMISS=$(yq e ".branches.\"$BRANCH\".required_pull_request_reviews.dismiss_stale_reviews" "$CONFIG_FILE")
    APPROVALS=$(yq e ".branches.\"$BRANCH\".required_pull_request_reviews.required_approving_review_count" "$CONFIG_FILE")
    CODEOWNERS=$(yq e ".branches.\"$BRANCH\".required_pull_request_reviews.require_code_owner_reviews" "$CONFIG_FILE")
    LAST_PUSH=$(yq e ".branches.\"$BRANCH\".required_pull_request_reviews.require_last_push_approval" "$CONFIG_FILE" 2>/dev/null || echo "false")
    PAYLOAD+="\"required_pull_request_reviews\": {\"dismiss_stale_reviews\": $DISMISS, \"required_approving_review_count\": $APPROVALS, \"require_code_owner_reviews\": $CODEOWNERS, \"require_last_push_approval\": $LAST_PUSH},"
  fi

  # Additional boolean flags
  for key in required_linear_history allow_force_pushes allow_deletions block_creations required_conversation_resolution lock_branch allow_fork_syncing required_signatures; do
    if yq e ".branches.\"$BRANCH\".$key" "$CONFIG_FILE" >/dev/null; then
      VALUE=$(yq e ".branches.\"$BRANCH\".$key" "$CONFIG_FILE")
      PAYLOAD+="\"$key\": $VALUE,"
    fi
  done

  # Clean and close the JSON payload
  PAYLOAD="${PAYLOAD%,}}"

  echo "📦 Final payload for $BRANCH:"
  echo "$PAYLOAD" | jq .

  gh api \
    -X PUT \
    "repos/${GITHUB_REPOSITORY}/branches/$BRANCH/protection" \
    -H "Accept: application/vnd.github+json" \
    -F "$(echo "$PAYLOAD" | jq -r 'to_entries|map("\(.key)=\(.value|tojson)")|.[]')"
done
echo "✅ Branch protection rules applied successfully."
