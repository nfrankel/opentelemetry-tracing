from typing import List

from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Recommendation(BaseModel):
    product_id: int
    recommendations: List[int]


@app.get("/recommendations/{product_id}")
def recommendations(product_id: int):
    match product_id:
        case 1:
            return Recommendation(product_id=product_id, recommendations=[2])
        case 2:
            return Recommendation(product_id=product_id, recommendations=[1])
        case _:
            return Recommendation(product_id=product_id, recommendations=[])
