# pip install redis==5.*  (Python 3.9+)
import os, time, uuid, random
from dataclasses import dataclass
from typing import Callable, Literal, Optional, Tuple
from redis import Redis

# Connect (configure via REDIS_URL env like redis://localhost:6379/0)
r = Redis.from_url(os.getenv("REDIS_URL", "redis://localhost:6379/0"), decode_responses=True)

# ---- Lua scripts ----
# Atomically: if done -> return "done"
# else try to acquire lock (NX PX ttl); returns "locked" with token if successful, else "busy"
CLAIM_LUA = r.register_script("""
-- KEYS[1] = done_key, KEYS[2] = lock_key
-- ARGV[1] = token, ARGV[2] = ttl_ms
if redis.call('EXISTS', KEYS[1]) == 1 then
  return {'done'}
end
local ok = redis.call('SET', KEYS[2], ARGV[1], 'NX', 'PX', ARGV[2])
if ok then
  return {'locked', ARGV[1]}
else
  return {'busy'}
end
""")

# Safe unlock: only delete lock if we still own it (compare-and-del)
UNLOCK_LUA = r.register_script("""
-- KEYS[1] = lock_key ; ARGV[1] = token
if redis.call('GET', KEYS[1]) == ARGV[1] then
  return redis.call('DEL', KEYS[1])
else
  return 0
end
""")

# Complete with TTL on the "done" marker: only the lock owner can mark done and release the lock
COMPLETE_LUA = r.register_script("""
-- KEYS[1] = lock_key, KEYS[2] = done_key
-- ARGV[1] = token, ARGV[2] = done_ttl_s
if redis.call('GET', KEYS[1]) == ARGV[1] then
  redis.call('SET', KEYS[2], '1', 'EX', tonumber(ARGV[2]))
  redis.call('DEL', KEYS[1])
  return 1
else
  return 0
end
""")

@dataclass
class Claim:
    state: Literal["done", "locked", "busy"]
    token: str = ""  # present only when state=="locked"

def _keys(task_id: str) -> Tuple[str, str]:
    return (f"done:{task_id}", f"lock:{task_id}")

def try_claim(task_id: str, ttl_ms: int = 30_000) -> Claim:
    done_key, lock_key = _keys(task_id)
    token = str(uuid.uuid4())
    res = CLAIM_LUA(keys=[done_key, lock_key], args=[token, str(ttl_ms)])
    state = res[0]
    if state == "locked":
        return Claim(state="locked", token=res[1])
    elif state == "done":
        return Claim(state="done")
    else:
        return Claim(state="busy")

def unlock(task_id: str, token: str) -> bool:
    _, lock_key = _keys(task_id)
    return bool(UNLOCK_LUA(keys=[lock_key], args=[token]))

def complete(task_id: str, token: str, done_ttl_s: int) -> bool:
    done_key, lock_key = _keys(task_id)
    return bool(COMPLETE_LUA(keys=[lock_key, done_key], args=[token, str(done_ttl_s)]))

def is_done(task_id: str) -> bool:
    done_key, _ = _keys(task_id)
    return r.exists(done_key) == 1

# Convenience wrapper: run work once across N workers.
def run_once(
    task_id: str,
    work_fn: Callable[[], None],
    lock_ttl_ms: int = 30_000,
    done_ttl_s: int = 7 * 24 * 3600,   # default: keep "done" for 7 days
    max_wait_s: float = 60.0,
    backoff_range_s: Tuple[float, float] = (0.1, 0.5),
) -> Optional[str]:
    """
    Returns:
      "done"   – task already completed by someone else (done key exists)
      "ran"    – we claimed the lock, ran work, and marked done (with TTL)
      None     – we didn't run it (others are working or time limit hit)
    """
    deadline = time.time() + max_wait_s
    while time.time() < deadline:
        c = try_claim(task_id, ttl_ms=lock_ttl_ms)
        if c.state == "done":
            return "done"
        if c.state == "locked":
            try:
                work_fn()
                # Mark completion atomically (only if we still own the lock)
                complete(task_id, c.token, done_ttl_s)
                return "ran"
            except Exception:
                # On failure, release the lock so others may retry
                unlock(task_id, c.token)
                raise
        # Someone else is doing it
        time.sleep(random.uniform(*backoff_range_s))
    return None

# ---------------- Example usage ----------------
if __name__ == "__main__":
    TASK = "email_batch_2025-10-29"

    def do_work():
        # your actual task here
        print("Doing the expensive thing once...")

    result = run_once(TASK, do_work, lock_ttl_ms=45_000, done_ttl_s=14 * 24 * 3600, max_wait_s=10)
    print("result:", result)
