import redis
import sys

def set_key(host, port, password, key, value, timeout=60) -> tuple[str, str]:
    try:
        r = redis.Redis(host=host, port=port, password=password, decode_responses=True, socket_timeout=timeout)
        # attempt to set key atomically if it does not exist
        was_set = r.set(name=key, value=value, nx=True)
        if was_set:
            print(f"setting {key}:{value}")
            return value, None
        print(f"exist {key}: {value}")
        return value, None
    except redis.RedisError as e:
        return None, e

# redis_write
if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("usage: python redis_key.py <host> <port> <password> <key> <value>")
        print(f"{len(sys.argv)}: {sys.argv}")
        sys.exit(1)

    redis_host = sys.argv[1]
    redis_port = int(sys.argv[2])
    redis_password = sys.argv[3]
    redis_key = sys.argv[4]
    redis_value = sys.argv[5]

    data, err = set_key(redis_host, redis_port, redis_password, redis_key, redis_value)
    if err:
        print(f"error: {err}")
        sys.exit(1)
    print(data)
