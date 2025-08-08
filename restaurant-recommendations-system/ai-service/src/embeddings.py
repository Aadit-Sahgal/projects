import os, numpy as np, faiss
from sentence_transformers import SentenceTransformer

EMB_PATH = os.getenv('EMB_PATH', '/data/embeddings.npy')
IDS_PATH = os.getenv('IDS_PATH', '/data/place_ids.npy')

embeddings = np.load(EMB_PATH)
place_ids  = np.load(IDS_PATH, allow_pickle=True)
id_to_idx  = {pid: i for i, pid in enumerate(place_ids)}

D = embeddings.shape[1]
faiss.normalize_L2(embeddings)
index = faiss.IndexFlatIP(D)
index.add(embeddings)

