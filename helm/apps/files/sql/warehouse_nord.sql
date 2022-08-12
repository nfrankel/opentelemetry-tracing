CREATE SCHEMA warehouse_nord;

CREATE TABLE warehouse_nord.location (
    id BIGINT PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL
);

CREATE TABLE warehouse_nord.stocklevel (
    product_id BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (product_id, warehouse_id)
);

-- Nordic warehouse locations
INSERT INTO warehouse_nord.location(id, city, region) VALUES
(1, 'Stockholm', 'Sweden'),
(2, 'Oslo', 'Norway'),
(3, 'Copenhagen', 'Denmark'),
(4, 'Helsinki', 'Finland'),
(5, 'Reykjavik', 'Iceland'),
(6, 'Gothenburg', 'Sweden'),
(7, 'Bergen', 'Norway'),
(8, 'Aarhus', 'Denmark'),
(9, 'Tampere', 'Finland'),
(10, 'Akureyri', 'Iceland');

-- Stock levels for products 1, 2, 3
INSERT INTO warehouse_nord.stocklevel(product_id, warehouse_id, quantity) VALUES
-- Product 1 (Stickers pack)
(1, 1, 15), (1, 2, 12), (1, 3, 18), (1, 4, 10), (1, 5, 8),
(1, 6, 14), (1, 7, 11), (1, 8, 16), (1, 9, 13), (1, 10, 7),
-- Product 2 (Lapel pin)
(2, 1, 8), (2, 2, 6), (2, 3, 9), (2, 4, 5), (2, 5, 4),
(2, 6, 7), (2, 7, 6), (2, 8, 8), (2, 9, 5), (2, 10, 3),
-- Product 3 (Tee-Shirt)
(3, 1, 5), (3, 2, 4), (3, 3, 6), (3, 4, 3), (3, 5, 2),
(3, 6, 4), (3, 7, 3), (3, 8, 5), (3, 9, 4), (3, 10, 2);