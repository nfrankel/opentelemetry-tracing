from random import uniform
from typing import Dict
from flask import Flask, abort, jsonify
from flask_sqlalchemy import SQLAlchemy


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///./prices.sqlite'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)


class Price(db.Model):
    id: int = db.Column(db.Integer, primary_key=True, autoincrement=True)
    value: float = db.Column(db.Float, nullable=False)
    jitter: float = db.Column(db.Float, nullable=False)

    def __repr__(self):
        return f'<Price {self.id} | {self.value }>'


@app.route('/price/<product_str>')
def price(product_str: str) -> Dict[str, object]:
    product_id = int(product_str)
    price: Price = Price.query.get(product_id)
    if price is None:
        return jsonify({'error': 'Product not found'}), 404
    else:
        low: float = price.value - price.jitter
        high: float = price.value + price.jitter
        return {
            'product_id': product_id,
            'price': round(uniform(low, high), 2)
        }


@app.before_first_request
def init_data() -> None:
    db.create_all()
    if not Price.query.all():
        db.session.add(Price(id=1, value=0.49, jitter=0.1))
        db.session.add(Price(id=2, value=1.49, jitter=0.1))
        db.session.add(Price(id=3, value=9.99, jitter=0.3))
        db.session.commit()
