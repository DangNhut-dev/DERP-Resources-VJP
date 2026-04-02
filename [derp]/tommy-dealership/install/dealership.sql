-- Table lưu xe trưng bày
CREATE TABLE IF NOT EXISTS `dealership_showroom` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shop` varchar(50) NOT NULL,
  `slot` int(11) NOT NULL,
  `vehicle` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `shop_slot` (`shop`, `slot`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `dealership_showroom` ADD COLUMN `color` INT(11) DEFAULT 0 AFTER `vehicle`;

UPDATE `dealership_showroom` SET `color` = FLOOR(RAND() * 112) WHERE `color` = 0;

-- Table lưu lịch sử bán xe
CREATE TABLE IF NOT EXISTS `dealership_sales` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shop` varchar(50) NOT NULL,
  `seller_citizenid` varchar(50) NOT NULL,
  `seller_name` varchar(100) NOT NULL,
  `buyer_citizenid` varchar(50) NOT NULL,
  `buyer_name` varchar(100) NOT NULL,
  `vehicle` varchar(50) NOT NULL,
  `price` int(11) NOT NULL,
  `commission` int(11) NOT NULL,
  `payment_type` varchar(10) NOT NULL,
  `sold_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `shop` (`shop`),
  KEY `seller_citizenid` (`seller_citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table xe tồn kho (giữ nguyên)
CREATE TABLE IF NOT EXISTS `vehicle_stock` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shop` varchar(50) NOT NULL,
  `vehicle` varchar(50) NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `price` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `shop` (`shop`),
  KEY `vehicle` (`vehicle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert 10 slots mặc định cho shop luxury
INSERT INTO `dealership_showroom` (`shop`, `slot`, `vehicle`) VALUES
('luxury', 1, 'sultanrs'),
('luxury', 2, 'jester3'),
('luxury', 3, 'elegy'),
('luxury', 4, 'toros'),
('luxury', 5, 'terminus'),
('luxury', 6, 'caracara2'),
('luxury', 7, 'ignus'),
('luxury', 8, 'thrax'),
('luxury', 9, 'mule3'),
('luxury', 10, 'pounder2')
ON DUPLICATE KEY UPDATE vehicle = VALUES(vehicle);

-- Thêm cột allow_self_purchase vào bảng vehicle_stock
ALTER TABLE `vehicle_stock`
ADD COLUMN `allow_self_purchase` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '0 = không cho phép tự mua, 1 = cho phép tự mua';

-- Index để tối ưu query
ALTER TABLE `vehicle_stock`
ADD INDEX `idx_allow_self_purchase` (`allow_self_purchase`);

-- Bảng lưu lịch sử tự mua xe
CREATE TABLE IF NOT EXISTS `dealership_self_purchases` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `shop` VARCHAR(50) NOT NULL,
  `citizenid` VARCHAR(50) NOT NULL,
  `vehicle` VARCHAR(50) NOT NULL,
  `price` INT(11) NOT NULL,
  `payment_type` VARCHAR(20) NOT NULL,
  `purchased_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `shop` (`shop`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `dealership_sales` 
ADD COLUMN `plate` VARCHAR(10) DEFAULT NULL AFTER `vehicle`;

ALTER TABLE `dealership_self_purchases` 
ADD COLUMN `plate` VARCHAR(10) DEFAULT NULL AFTER `vehicle`;

ALTER TABLE `vehicle_stock` 
ADD COLUMN `description` TEXT DEFAULT NULL AFTER `price`;

ALTER TABLE `vehicle_stock` 
ADD FULLTEXT INDEX `idx_description` (`description`);

ALTER TABLE `vehicle_stock` ADD COLUMN `gc_price` INT(11) NOT NULL DEFAULT 0;