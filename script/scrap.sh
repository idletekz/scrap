#!/bin/bash
set -euo pipefail

# === Config ===
SSH_KEY="/path/to/sshkey.pem"
SRC_FILE="/target/path/file"
DEST_DIR="/target/path"
USER="user"
PRIMARY_HOST="hostA"
HOSTS=("hostB" "hostC" "hostD" "hostE" "hostF" "hostG")

MAX_PARALLEL=5
pids=()
hostnames=()

# === Pre-check ===
command -v rsync >/dev/null || { echo "[ERROR] rsync not found"; exit 1; }
command -v ssh >/dev/null || { echo "[ERROR] ssh not found"; exit 1; }

# === Rsync replication in parallel with limit ===
for host in "${HOSTS[@]}"; do
  {
    echo "[INFO] Starting rsync to $host..."
    if output=$(rsync -azvc -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no" "$SRC_FILE" "$USER@$host:$DEST_DIR" 2>&1); then
      echo "[SUCCESS] Rsync to $host completed."
      echo "$output"
    else
      echo "[ERROR] Rsync to $host failed!" >&2
      echo "$output" >&2
      return 1  # This will fail inside the subshell but is detected via wait later
    fi
  } &

  pid=$!
  echo "[DEBUG] Started rsync to $host with PID $pid"
  pids+=("$pid")
  hostnames+=("$host")

  # === Limit concurrent background jobs ===
  if (( ${#pids[@]} >= MAX_PARALLEL )); then
    echo "[DEBUG] Max parallel ($MAX_PARALLEL) reached. Waiting for a job to finish..."

    if wait -n 2>/dev/null; then
      echo "[DEBUG] A background job finished (using wait -n)."
    else
      echo "[DEBUG] Bash < 5 detected. Waiting for oldest PID: ${pids[0]} (host: ${hostnames[0]})"
      wait "${pids[0]}"
      echo "[DEBUG] Finished waiting on PID: ${pids[0]} (host: ${hostnames[0]})"
      unset 'pids[0]'
      unset 'hostnames[0]'
      pids=("${pids[@]}")           # reindex array
      hostnames=("${hostnames[@]}") # reindex array
    fi
  fi
done

# === Wait for remaining jobs ===
fail=0
for i in "${!pids[@]}"; do
  pid=${pids[i]}
  host=${hostnames[i]}
  if ! wait "$pid"; then
    echo "[ERROR] Rsync task failed (PID $pid, host $host)." >&2
    fail=1
  fi
done

if [[ $fail -ne 0 ]]; then
  echo "[FATAL] One or more rsync tasks failed." >&2
  exit 1
fi

echo "[INFO] All rsync tasks completed successfully."
