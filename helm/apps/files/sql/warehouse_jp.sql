CREATE SCHEMA warehouse_jp;
CREATE TABLE warehouse_jp.location
(
    id         BIGINT PRIMARY KEY,
    city       VARCHAR(50) NOT NULL,
    prefecture VARCHAR(50) NOT NULL
);
CREATE TABLE warehouse_jp.stocklevel
(
    product_id   BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    quantity     INT    NOT NULL,
    PRIMARY KEY (product_id, warehouse_id)
);
INSERT INTO warehouse_jp.location(id, city, prefecture)
VALUES (1, 'Sapporo', 'Hokkaidō'),
       (2, 'Tokyo', 'Tokyo'),
       (3, 'Yokohama', 'Kan'),
       (4, 'Osaka', 'Osaka'),
       (5, 'Nagoya', 'Aichi'),
       (6, 'Fukuoka', 'Fukuoka'),
       (7, 'Kobe', 'Hyōgo'),
       (8, 'Kyoto', 'Kyoto');
INSERT INTO warehouse_jp.stocklevel(product_id, warehouse_id, quantity)
VALUES (1, 1, 1),
       (1, 2, 2),
       (1, 3, 3),
       (1, 4, 4),
       (1, 5, 5),
       (1, 6, 6),
       (1, 7, 7),
       (1, 8, 8),
       (2, 1, 2),
       (3, 1, 3),
       (2, 2, 2),
       (3, 3, 1),
       (4, 4, 1),
       (4, 5, 1);
