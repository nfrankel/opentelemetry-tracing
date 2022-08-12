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
