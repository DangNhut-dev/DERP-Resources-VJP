DROP TABLE IF EXISTS `scenes`;

CREATE TABLE `scenes` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`coords` JSON NOT NULL,
	`normal` JSON NOT NULL,
	`text` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`color` VARCHAR(50) NOT NULL DEFAULT 'white' COLLATE 'utf8mb4_unicode_ci',
	`font` INT(11) NOT NULL DEFAULT '4',
	`font_size` FLOAT NOT NULL DEFAULT '0.7',
	`distance` FLOAT NOT NULL DEFAULT '5',
	`background` JSON NOT NULL,
	`hidden` TINYINT(1) NOT NULL DEFAULT '0',
	`creator` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`created_at` INT(11) NOT NULL,
	`expires_at` INT(11) NOT NULL,
	PRIMARY KEY (`id`) USING BTREE,
	INDEX `expires_at` (`expires_at`) USING BTREE,
	INDEX `creator` (`creator`) USING BTREE
)
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=9
;
