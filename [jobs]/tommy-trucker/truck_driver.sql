-- ═══════════════════════════════════════════════════════════
-- 🚚 TOMMY TRUCKER - DATABASE SCHEMA
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `truck_driver_stats` (
    `citizenid` VARCHAR(11) NOT NULL,
    `registered_plate` VARCHAR(10) NULL DEFAULT NULL,
    `registered_vehicle` VARCHAR(50) NULL DEFAULT NULL,
    `trips_completed` INT(11) NOT NULL DEFAULT 0,
    `total_exp` INT(11) NOT NULL DEFAULT 0,
    `current_level` INT(11) NOT NULL DEFAULT 1,
    `last_updated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Index để tăng tốc query
CREATE INDEX IF NOT EXISTS `idx_registered_plate` ON `truck_driver_stats` (`registered_plate`);
CREATE INDEX IF NOT EXISTS `idx_current_level` ON `truck_driver_stats` (`current_level`);


-- ═══════════════════════════════════════════════════════════
-- 🔑 TRUCK RENTAL - Bảng lưu thông tin thuê xe
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `truck_rentals` (
    `id`            INT(11)      NOT NULL AUTO_INCREMENT,
    `citizenid`     VARCHAR(11)  NOT NULL,
    `plate`         VARCHAR(10)  NOT NULL,
    `vehicle_model` VARCHAR(50)  NOT NULL,
    `price_per_day` INT(11)      NOT NULL DEFAULT 1000,
    `rental_days`   TINYINT(1)   NOT NULL DEFAULT 1,
    `total_price`   INT(11)      NOT NULL DEFAULT 0,
    `start_time`    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `expire_time`   TIMESTAMP    NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_plate`     (`plate`),
    UNIQUE KEY `uq_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE INDEX IF NOT EXISTS `idx_expire_time` ON `truck_rentals` (`expire_time`);