from json import dumps
from random import uniform
from typing import Any, Optional

from flask import Flask, jsonify, Response
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///./prices.sqlite'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy()
db.init_app(app)


class Price(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    value = db.Column(db.Float, nullable=False)
    jitter = db.Column(db.Float, nullable=False)

    def __repr__(self) -> str:
        dict_repr = {col.name: getattr(self, col.name) for col in self.__table__.columns}
        return dumps(dict_repr, indent=2)

    def serialize_to_view(self) -> dict[str, Any]:
        low: float = self.value - self.jitter
        high: float = self.value + self.jitter
        return {
            'product_id': self.id,
            'price': round(uniform(low, high), 2)
        }


with app.app_context():
    db.create_all()
    if not Price.query.all():
        db.session.add(Price(id=1, value=0.49, jitter=0.1))
        db.session.add(Price(id=2, value=1.49, jitter=0.1))
        db.session.add(Price(id=3, value=9.99, jitter=0.3))
        db.session.commit()


@app.route('/prices/<int:product_id>')
def price(product_id: int) -> tuple[Response, int]:
    price: Optional[Price] = Price.query.get(product_id)
    if price is None:
        return jsonify({'error': 'Product not found'}), 404
    return jsonify(price.serialize_to_view()), 200
