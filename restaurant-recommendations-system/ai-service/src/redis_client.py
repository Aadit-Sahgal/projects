import os, redis
from dotenv import load_dotenv

load_dotenv()
r = redis.Redis.from_url(os.getenv("REDIS_URL"), decode_responses=False)

def get_upv(user_id: str) -> dict[str, float]:
    raw = r.hgetall(f"upv:{user_id}")
    return { k.decode(): float(v) for k, v in raw.items() }

