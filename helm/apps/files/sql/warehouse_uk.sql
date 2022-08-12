CREATE SCHEMA warehouse_uk;
CREATE TABLE warehouse_uk.location
(
    id         BIGINT PRIMARY KEY,
    city       VARCHAR(50) NOT NULL
);
CREATE TABLE warehouse_uk.stocklevel
(
    product_id   BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    quantity     INT    NOT NULL,
    PRIMARY KEY (product_id, warehouse_id)
);
INSERT INTO warehouse_uk.location(id, city)
VALUES (1, 'London'),
       (2, 'Liverpool'),
       (3, 'Edimburg');
INSERT INTO warehouse_uk.stocklevel(product_id, warehouse_id, quantity)
VALUES (1, 1, 1),
       (1, 2, 2),
       (1, 3, 3),
       (2, 1, 2),
       (3, 1, 3),
       (2, 2, 2),
       (3, 3, 1);
