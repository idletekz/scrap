
#!/bin/bash

set -euo pipefail

# === Configurable Variables ===
KEY_CONTENT="-----BEGIN PRIVATE KEY-----
...your private key here...
-----END PRIVATE KEY-----"
USER="user"
PRIMARY_HOST="hostA"
TARGET_PATH="/target/path/file"
DEST_PATH="/target/path"
HOSTS_CSV="hostA,hostB,hostC,hostD"  # Example includes primary host to demonstrate exclusion
SSH_OPTS="-o StrictHostKeyChecking=no"
PARALLEL_JOBS=3

# === Validate required commands ===
for cmd in ssh rsync parallel; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[ERROR] Required command '$cmd' not found." >&2
    exit 1
  fi
done

# === Generate temporary key file ===
TMP_KEY=$(mktemp /tmp/tmp_key.XXXXXX.pem)
chmod 600 "$TMP_KEY"
printf '%s\n' "$KEY_CONTENT" > "$TMP_KEY"

# === Cleanup on exit ===
cleanup() {
  echo "[INFO] Cleaning up temporary SSH key..."

  if ssh -i "$TMP_KEY" $SSH_OPTS "$USER@$PRIMARY_HOST" "[[ -f '$TMP_KEY' ]]" 2>/dev/null; then
    ssh -i "$TMP_KEY" $SSH_OPTS "$USER@$PRIMARY_HOST" "rm -f '$TMP_KEY'" || \
      echo "[WARN] Remote key cleanup failed"
  else
    echo "[INFO] Remote key already removed or not present"
  fi

  if [[ -f "$TMP_KEY" ]]; then
    rm -f "$TMP_KEY"
  else
    echo "[INFO] Local key already removed or not present"
  fi
}
trap cleanup EXIT

# === Transfer temp SSH key to Primary Host ===
echo "[INFO] Transferring temporary SSH key to $PRIMARY_HOST..."
ssh -i "$TMP_KEY" $SSH_OPTS "$USER@$PRIMARY_HOST" \
  "cat > '$TMP_KEY' && chmod 600 '$TMP_KEY'" < "$TMP_KEY"

# === Parse HOSTS_CSV and exclude primary host ===
IFS=',' read -r -a ALL_HOSTS <<< "$HOSTS_CSV"
HOSTS=()
for h in "${ALL_HOSTS[@]}"; do
  [[ "$h" != "$PRIMARY_HOST" ]] && HOSTS+=("$h")
done

# === Sanity check: no target hosts ===
if [[ ${#HOSTS[@]} -eq 0 ]]; then
  echo "[ERROR] No valid target hosts found after excluding primary host." >&2
  exit 1
fi

# === Run rsync in parallel from Primary Host to other hosts ===
echo "[INFO] Starting parallel rsync from $PRIMARY_HOST to: ${HOSTS[*]}"
parallel -j "$PARALLEL_JOBS" ssh -i "$TMP_KEY" $SSH_OPTS "$USER@$PRIMARY_HOST" \
  "rsync -az -e 'ssh -i $TMP_KEY $SSH_OPTS' '$TARGET_PATH' '$USER@{}:$DEST_PATH'" ::: "${HOSTS[@]}"