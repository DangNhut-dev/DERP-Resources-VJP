CREATE TABLE IF NOT EXISTS `derp-multicharacter_slots` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `amount` INT DEFAULT 1,
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier` (`identifier`)
);