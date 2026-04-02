CREATE TABLE IF NOT EXISTS `vehicle_purchases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `vehicle` varchar(50) NOT NULL,
  `purchase_date` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  UNIQUE KEY `unique_purchase` (`citizenid`, `vehicle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;