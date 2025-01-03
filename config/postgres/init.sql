CREATE SCHEMA catalog;

CREATE TABLE catalog.product
(
    id          BIGINT PRIMARY KEY,
    name        VARCHAR(50)  NOT NULL,
    description VARCHAR(250) NOT NULL
);

INSERT INTO catalog.product(id, name, description)
VALUES (1, 'Stickers pack',
        'A pack of rad stickers to display on your laptop or wherever you feel like. Show your love for Apache APISIX'),
       (2, 'Lapel pin',
        'With this "Powered by Apache APISIX" lapel pin, support your favorite API Gateway and let everybody know about it.'),
       (3, 'Tee-Shirt',
        'The classic geek product! At a conference, at home, at work, this tee-shirt will be your best friend.');

CREATE SCHEMA pricing;

CREATE TABLE pricing.price
(
    id     BIGINT PRIMARY KEY,
    value  FLOAT NOT NULL,
    jitter FLOAT NOT NULL
);

INSERT INTO pricing.price(id, value, jitter)
VALUES (1, 0.49, 0.1),
       (2, 1.49, 0.1),
       (3, 9.49, 0.3);

CREATE SCHEMA warehouse_us;

CREATE TABLE warehouse_us.location
(
    id    BIGINT PRIMARY KEY,
    city  VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL
);

CREATE TABLE warehouse_us.stocklevel
(
    product_id   BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    quantity     INT    NOT NULL,
    PRIMARY KEY (product_id, warehouse_id)
);

INSERT INTO warehouse_us.location(id, city, state)
VALUES (1, 'Popejoy', 'Iowa'),
       (2, 'Hooker', 'Oklahoma'),
       (3, 'China', 'Texas'),
       (4, 'Rainbow City', 'Alabama'),
       (5, 'Blue Grass', 'Iowa'),
       (6, 'Pink', 'Oklahoma'),
       (7, 'Colon', 'Michigan'),
       (8, 'Cool', 'Texas'),
       (9, 'Oblong', 'Illinois'),
       (10, 'Speed', 'North Carolina'),
       (11, 'Last Chance', 'Iowa'),
       (12, 'Uncertain', 'Texas'),
       (13, 'Winnebago', 'Minnesota'),
       (14, 'Climax', 'Michigan'),
       (15, 'Three Way', 'Tennessee'),
       (16, 'Coward', 'South Carolina'),
       (17, 'Okay', 'Oklahoma'),
       (18, 'Atomic City', 'Idaho'),
       (19, 'Superior', 'Wyoming'),
       (20, 'Canadian', 'Texas');

INSERT INTO warehouse_us.stocklevel(product_id, warehouse_id, quantity)
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
       (1, 17, 17),
       (1, 18, 18),
       (1, 19, 19),
       (1, 20, 20),
       (2, 1, 2),
       (3, 1, 3),
       (2, 2, 2),
       (3, 3, 1);

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
       (4, 'Switzerland', 'Switzerland City'),
       (5, 'Berlin', 'Germany'),
       (6, 'Munich', 'Germany'),
       (7, 'Milan', 'Italy'),
       (8, 'Rome', 'Italy'),
       (9, 'Madrid', 'Spain'),
       (10, 'Barcelona', 'Spain'),
       (11, 'Lisbon', 'Portugal'),
       (12, 'Porto', 'Portugal'),
       (13, 'Amsterdam', 'Netherlands'),
       (14, 'Rotterdam', 'Netherlands'),
       (15, 'Brussels', 'Belgium'),
       (16, 'Antwerp', 'Belgium'),
       (17, 'Luxembourg', 'Luxembourg');

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
       (1, 17, 17),
       (2, 1, 2),
       (3, 1, 3),
       (2, 2, 2),
       (3, 3, 1);

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
       (3, 3, 1);

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

CREATE SCHEMA recommendations;
CREATE TABLE recommendations.product
(
    product_id     BIGINT,
    recommended_id BIGINT NOT NULL,
    PRIMARY KEY (product_id, recommended_id)
);
INSERT INTO recommendations.product(product_id, recommended_id)
VALUES (1, 2),
       (2, 1);
