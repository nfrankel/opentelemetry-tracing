from contextlib import asynccontextmanager
from os import getenv
from typing import List

from databases import Database
from databases.interfaces import Record
from fastapi import FastAPI
from pydantic import BaseModel
from sqlalchemy import MetaData, Table, Column, Integer, PrimaryKeyConstraint
from sqlalchemy.orm import declarative_base

database_url = getenv('DATABASE_URL')
schema = getenv('POSTGRES_SCHEMA')

database = Database(database_url)
metadata = MetaData(schema=schema)

recommendations_table = Table(
    'product',
    metadata,
    Column('product_id', Integer, nullable=False),
    Column('recommended_id', Integer, nullable=False),
    PrimaryKeyConstraint('product_id', 'recommended_id')
)

Base = declarative_base()


class RecommendationResponse(BaseModel):
    product_id: int
    recommendations: List[int]


@asynccontextmanager
async def lifespan(_: FastAPI):
    await database.connect()
    yield
    await database.disconnect()


app = FastAPI(lifespan=lifespan)


@app.get('/recommendations/{product_id}', response_model=RecommendationResponse)
async def recommendations(product_id: int):
    query = recommendations_table.select().where(recommendations_table.c.product_id == product_id)
    result: list[Record] = await database.fetch_all(query)
    recommended_ids: list[int] = [int(record['recommended_id']) for record in result]
    return RecommendationResponse(product_id=product_id, recommendations=recommended_ids)
