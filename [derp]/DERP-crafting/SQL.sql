CREATE TABLE IF NOT EXISTS `derp_crafting_exp` (
    `citizenid` VARCHAR(50) NOT NULL,
    `exp` INT(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (`citizenid`)
);