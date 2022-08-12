CREATE SCHEMA warehouse_eu;
CREATE TABLE warehouse_eu.location
(
    id      BIGINT PRIMARY KEY,
    city    VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);
CREATE TABLE warehouse_eu.stocklevel
(
    product_id   BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    quantity     INT    NOT NULL,
    PRIMARY KEY (product_id, warehouse_id)
);
INSERT INTO warehouse_eu.location(id, city, country)
VALUES (1, 'Lyon', 'France'),
       (2, 'Paris', 'France'),
       (3, 'Geneva', 'Switzerland'),
       (4, 'Berlin', 'Germany'),
       (5, 'Munich', 'Germany'),
       (6, 'Milan', 'Italy'),
       (7, 'Rome', 'Italy'),
       (8, 'Madrid', 'Spain'),
       (9, 'Barcelona', 'Spain'),
       (10, 'Lisbon', 'Portugal'),
       (11, 'Porto', 'Portugal'),
       (12, 'Amsterdam', 'Netherlands'),
       (13, 'Rotterdam', 'Netherlands'),
       (14, 'Brussels', 'Belgium'),
       (15, 'Antwerp', 'Belgium'),
       (16, 'Luxembourg', 'Luxembourg');
INSERT INTO warehouse_eu.stocklevel(product_id, warehouse_id, quantity)
VALUES (1, 1, 1),
       (1, 2, 2),
       (1, 3, 3),
       (1, 4, 4),
       (1, 5, 5),
       (1, 6, 6),
       (1, 7, 7),
       (1, 8, 8),
       (1, 9, 9),
       (1, 10, 10),
       (1, 11, 11),
       (1, 12, 12),
       (1, 13, 13),
       (1, 14, 14),
       (1, 15, 15),
       (1, 16, 16),
       (2, 1, 2),
       (3, 1, 3),
       (2, 2, 2),
       (3, 3, 1);
