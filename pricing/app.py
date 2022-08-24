from random import uniform

from flask import Flask, jsonify, Response
from flask_sqlalchemy import SQLAlchemy
from opentelemetry import trace

tracer = trace.get_tracer(__name__)
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///./prices.sqlite'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)


class Price(db.Model):
    id: int = db.Column(db.Integer, primary_key=True, autoincrement=True)
    value: float = db.Column(db.Float, nullable=False)
    jitter: float = db.Column(db.Float, nullable=False)

    def __init__(self, _id, value, jitter):
        self.id = _id
        self.value = value
        self.jitter = jitter

    def __repr__(self):
        return f'<Price {self.id} | {self.value}>'


with app.app_context():
    db.create_all()
    if not Price.query.all():
        db.session.add(Price(_id=1, value=0.49, jitter=0.1))
        db.session.add(Price(_id=2, value=1.49, jitter=0.1))
        db.session.add(Price(_id=3, value=9.99, jitter=0.3))
        db.session.commit()


@app.route('/prices/<product_str>')
def price(product_str: str) -> tuple[Response, int]:
    product_id = int(product_str)
    with tracer.start_as_current_span("SELECT * FROM PRICE WHERE ID=:id", attributes={":id": product_id}):
        _price: Price = Price.query.get(product_id)
    if _price is None:
        return jsonify({'error': 'Product not found'}), 404
    else:
        low: float = _price.value - _price.jitter
        high: float = _price.value + _price.jitter
        return jsonify({
            'product_id': product_id,
            'price': round(uniform(low, high), 2)
        }), 200
