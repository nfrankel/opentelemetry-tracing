from typing import TypedDict
from random import uniform
from flask import Flask


app = Flask(__name__)


class Price(TypedDict):
    price: float
    jitter: float

prices_range  = {
    1: {'value': 0.49, 'jitter': 0.1},
    2: {'value': 1.49, 'jitter': 0.1},
    3: {'value':  9.99, 'jitter': 0.3},
}


@app.route('/price/<product_str>')
def price(product_str: str):
    product_id = int(product_str)
    if product_id in prices_range.keys():
        price: Price = prices_range[product_id]
        low = price['value'] - price['jitter']
        high = price['value'] + price['jitter']
        return {
            'product_id': product_id,
            'price': round(uniform(low, high), 2)
        }
    else:
        raise HTTPException(status_code=404, detail="Product not found")
