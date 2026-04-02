CREATE TABLE IF NOT EXISTS `0r_idcard` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `license` varchar(255) DEFAULT NULL,
  `photo` longtext NOT NULL,
  `driver_license` int(11) DEFAULT 0,
  `weapon_license` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

CREATE TABLE IF NOT EXISTS `0r_idcard_fakecards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `license` varchar(255) DEFAULT NULL,
  `card_type` varchar(255) DEFAULT NULL,
  `card_name` varchar(50) DEFAULT NULL,
  `card_surname` varchar(50) DEFAULT NULL,
  `card_birthdate` varchar(50) DEFAULT NULL,
  `card_sex` varchar(50) DEFAULT NULL,
  `card_photo` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;