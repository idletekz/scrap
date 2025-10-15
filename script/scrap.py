# pip install redis==5.*  (Python 3.9+)
import os, time, uuid, random
from contextlib import contextmanager
from redis import Redis

r = Redis.from_url(os.getenv("REDIS_URL", "redis://localhost:6379/0"), decode_responses=True)

# atomic unlock (compare-and-del) to avoid releasing someone else's lock
UNLOCK_LUA = """
if redis.call("GET", KEYS[1]) == ARGV[1] then
  return redis.call("DEL", KEYS[1])
else
  return 0
end
"""

def try_lock(task_id: str, ttl_ms: int = 30000) -> tuple[bool, str]:
    key = f"lock:{task_id}"
    token = str(uuid.uuid4())
    # nx: set only if the key does not exist
    # px: ttl in milliseconds so lock expired if the holder crashes
    ok = r.set(name=key, value=token, nx=True, px=ttl_ms)
    return (bool(ok), token if ok else "")

def unlock(task_id: str, token: str) -> None:
    key = f"lock:{task_id}"
    r.eval(UNLOCK_LUA, 1, key, token)

@contextmanager
def acquire_lock(task_id: str, ttl_ms: int = 30000, max_wait_s: float = 5.0):
    """Retries with jitter until max_wait_s; yields (acquired: bool, token: str)."""
    deadline = time.time() + max_wait_s
    token = ""
    while time.time() < deadline:
        ok, token = try_lock(task_id, ttl_ms=ttl_ms)
        if ok:
            try:
                yield True, token
            finally:
                try:
                    unlock(task_id, token)
                except Exception:
                    # Best effort; lock will also expire by TTL.
                    pass
            return
        # backoff + jitter
        time.sleep(0.025 + random.random() * 0.125)
    # failed to acquire within budget
    yield False, ""

# EXAMPLE: ensure only one worker runs a task once
def run_task_once(task_id: str):
    with acquire_lock(task_id, ttl_ms=60000, max_wait_s=2.0) as (ok, _token):
        if not ok:
            print(f"[{task_id}] another worker is already running; skipping")
            return False
        print(f"[{task_id}] I got the lock; doing the work...")
        # ... do your work here ...
        time.sleep(2)  # simulate work
        print(f"[{task_id}] done")
        return True

if __name__ == "__main__":
    # Simulate many workers contending for the same task-id
    task_id = "<serviceID>-<pipelineID>-<buildID>"
    run_task_once(task_id)
