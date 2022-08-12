CREATE SCHEMA recommandations;
CREATE TABLE recommandations.product
(
    product_id     BIGINT,
    recommended_id BIGINT NOT NULL,
    PRIMARY KEY (product_id, recommended_id)
);
INSERT INTO recommandations.product(product_id, recommended_id)
VALUES (1, 2),
       (2, 1);
