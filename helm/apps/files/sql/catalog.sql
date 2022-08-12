CREATE SCHEMA catalog;
CREATE TABLE catalog.product
(
    id          BIGINT PRIMARY KEY,
    name        VARCHAR(50)  NOT NULL,
    description VARCHAR(250) NOT NULL
);
INSERT INTO catalog.product(id, name, description)
VALUES (1, 'Stickers pack',
        'A pack of rad stickers to display on your laptop or wherever you feel like.'),
       (2, 'Lapel pin',
        'With this rad lapel pin, support your favorite Kubernetes virtualization solution and let everybody know about it.'),
       (3, 'Tee-Shirt',
        'The classic geek product! At a conference, at home, at work, this tee-shirt will be your best friend.');
