import os
import pprint
from typing import List, cast

import torch
from datasets import Dataset, load_dataset
from torch.utils.data import DataLoader
from tqdm import tqdm
from pdf2image import convert_from_path


from colpali_engine.models import ColPali
from colpali_engine.models.paligemma.colpali.processing_colpali import ColPaliProcessor
from colpali_engine.utils.processing_utils import BaseVisualRetrieverProcessor
from colpali_engine.utils.torch_utils import ListDataset, get_torch_device
import pickle
import transformers
import logging
from transformers import logging as transformers_logging
HF_TOKEN = "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"
print(transformers.__version__)
device = get_torch_device("auto")
print(f"Device used: {device}")

    # Model name

images = []
files = ['CVMicheleMenabeni1309.pdf']
for file in files:
        print(f"Indexing now: {file}")
        images.extend(convert_from_path(file))
    # Load model
from transformers import AutoModel
model_name = "vidore/colpali-v1.2"
#transformers_logging.set_verbosity_debug()
#logging.basicConfig(level=logging.DEBUG)

# Tenta di scaricare nuovamente il modello
model = ColPali.from_pretrained(
    model_name,
    trust_remote_code=True,
    torch_dtype=torch.bfloat16,
    device_map=None,
).eval()

    # Load processor
processor = cast(ColPaliProcessor, ColPaliProcessor.from_pretrained(model_name))
if not isinstance(processor, BaseVisualRetrieverProcessor):
        raise ValueError("Processor should be a BaseVisualRetrieverProcessor")
queries = ["chi è michele menabeni?",'di che colore sono i capelli di Michele Menabeni?']
with open("C:/Users/rikyt/Desktop/Github_Uploads/ASSIST/embeddings_prova.pkl", 'rb') as f:
        document_embeddings = pickle.load(f)
dataloader = DataLoader(
        queries,
        batch_size=1,
        shuffle=False,
        collate_fn=lambda x: processor.process_queries(x),
    )

qs = []
for batch_query in dataloader:
        with torch.no_grad():
            batch_query = {k: v.to(model.device) for k, v in batch_query.items()}
            embeddings_query = model(**batch_query)
        qs.extend(list(torch.unbind(embeddings_query.to("cpu"))))

    # Run scoring
scores = processor.score(qs, document_embeddings).cpu().numpy()
scores = processor.score(qs, document_embeddings).cpu().numpy()
print("Scores:", scores)
print("Indices of the top-1 retrieved documents for each query:", scores.argmax(axis=1))

generation_config = {
  "temperature": 0.0,
  "top_p": 0.95,
  "top_k": 64,
  "max_output_tokens": 1024,
  "response_mime_type": "text/plain",
}
import google.generativeai as genai

genai.configure(api_key='AIzaSyBLGHniJE-TUoRHPhAB1RoC7suLfmQff9Q')

model = genai.GenerativeModel(model_name="gemini-1.5-flash" , generation_config=generation_config)
best_indexes = scores.argmax(axis=1)
count=0
print(best_indexes)
print(len(images))
for x in best_indexes:
    print()
    print(images[x])
    response = model.generate_content([queries[count], images[x]])
    count+=1
    print(response.text)