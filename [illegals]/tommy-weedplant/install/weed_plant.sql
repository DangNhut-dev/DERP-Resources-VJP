CREATE TABLE IF NOT EXISTS `cannabis_plants` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `plant_id` VARCHAR(50) NOT NULL,
    `citizenid` VARCHAR(50) NOT NULL,
    `seed_type` VARCHAR(50) NOT NULL, -- Loại hạt giống
    `coords` TEXT NOT NULL,
    `stage` INT(11) NOT NULL DEFAULT 1,
    `water_level` INT(11) NOT NULL DEFAULT 0, -- Mức nước hiện tại (0-100)
    `water_count` INT(11) NOT NULL DEFAULT 0, -- Số lần đã tưới
    `is_ready` TINYINT(1) NOT NULL DEFAULT 0,
    `is_withered` TINYINT(1) NOT NULL DEFAULT 0,
    `planted_at` BIGINT(20) NOT NULL,
    `last_watered_at` BIGINT(20) DEFAULT NULL,
    `growth_started_at` BIGINT(20) DEFAULT NULL,
    `has_fertilizer` TINYINT(1) NOT NULL DEFAULT 0, -- Đã bón phân chưa
    `has_uv_light` TINYINT(1) NOT NULL DEFAULT 0, -- Có đèn UV không
    `uv_light_coords` TEXT DEFAULT NULL, -- Tọa độ đèn UV
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `plant_id` (`plant_id`),
    KEY `citizenid` (`citizenid`),
    KEY `seed_type` (`seed_type`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

-- Bảng cannabis_drying_racks
CREATE TABLE IF NOT EXISTS `cannabis_drying_racks` (
  `rack_id` varchar(100) NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `coords` text NOT NULL,
  `items` text DEFAULT NULL,
  `started_at` bigint(20) DEFAULT NULL,
  `is_drying` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`rack_id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Bảng cannabis_infusion_tables
CREATE TABLE IF NOT EXISTS `cannabis_infusion_tables` (
  `table_id` varchar(100) NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `coords` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE cannabis_plants ADD COLUMN `growth_paused_at` BIGINT NULL DEFAULT NULL;
ALTER TABLE cannabis_drying_racks ADD COLUMN heading FLOAT NOT NULL DEFAULT 0.0;
ALTER TABLE cannabis_infusion_tables ADD COLUMN heading FLOAT NOT NULL DEFAULT 0.0;