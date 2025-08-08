import numpy as np, pickle
from embeddings import embeddings, id_to_idx
from redis_client import get_upv
from lightfm import LightFM

lfm = pickle.load(open('/data/lightfm_model.pkl','rb'))
with open('/data/lfm_mappings.pkl','rb') as f:
    user_to_idx, item_to_idx, item_features = pickle.load(f)

def hybrid(user_id: str, candidate_ids: list[str], k: int = 10, alpha: float = 0.7):
    upv = np.zeros(embeddings.shape[1], dtype=float)
    for pid, score in get_upv(user_id).items():
        upv += score * embeddings[id_to_idx[pid]]
    norm = np.linalg.norm(upv)
    if norm > 0: upv /= norm

    idxs = [id_to_idx[pid] for pid in candidate_ids]
    cont = embeddings[idxs].dot(upv)

    cf = np.zeros_like(cont)
    uidx = user_to_idx.get(user_id)
    if uidx is not None:
        item_idxs = [item_to_idx[pid] for pid in candidate_ids]
        cf = lfm.predict(uidx, np.array(item_idxs), item_features=item_features)

    scores = alpha*cont + (1-alpha)*cf
    order = np.argsort(-scores)[:k]
    return [{"place_id": candidate_ids[i], "score": float(scores[i])} for i in order]

