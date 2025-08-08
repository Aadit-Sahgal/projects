from fastapi import FastAPI
from pydantic import BaseModel
from recommend import hybrid

app = FastAPI()

class Req(BaseModel):
    user_id: str
    place_ids: list[str]
    k: int = 10

@app.post("/recommend")
def recommend(req: Req):
    return {"recommendations": hybrid(req.user_id, req.place_ids, req.k)}

