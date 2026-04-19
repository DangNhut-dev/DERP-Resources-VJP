CREATE TABLE IF NOT EXISTS `derp_weed_relationships` (
    `citizenid` VARCHAR(50) NOT NULL,
    `npc_id` INT NOT NULL,
    `trust` INT NOT NULL DEFAULT 0,
    `total_deals` INT NOT NULL DEFAULT 0,
    `successful_deals` INT NOT NULL DEFAULT 0,
    `deals_today` INT NOT NULL DEFAULT 0,
    `deals_today_game_day` INT NOT NULL DEFAULT 0,
    `last_deal_at` TIMESTAMP NULL,
    `last_completed_at` TIMESTAMP NULL,
    `unlocked_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`citizenid`, `npc_id`),
    INDEX `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `derp_weed_listings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `item` VARCHAR(50) NOT NULL,
    `amount` INT NOT NULL,
    `price_per_unit` INT NOT NULL,
    `status` ENUM('active','expired','sold','cancelled') DEFAULT 'active',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `expires_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_citizenid_status` (`citizenid`, `status`),
    INDEX `idx_status_expires` (`status`, `expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `derp_weed_orders` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `listing_id` INT NOT NULL,
    `citizenid` VARCHAR(50) NOT NULL,
    `npc_id` INT NOT NULL,
    `item` VARCHAR(50) NOT NULL,
    `amount` INT NOT NULL,
    `price_per_unit` INT NOT NULL,
    `total_price` INT NOT NULL,
    `location_idx` INT NOT NULL,
    `deadline_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `status` ENUM('pending','delivered_early','delivered_ontime','delivered_late','failed','cancelled') DEFAULT 'pending',
    `final_payout` INT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `completed_at` TIMESTAMP NULL,
    INDEX `idx_citizenid_status` (`citizenid`, `status`),
    INDEX `idx_status_deadline` (`status`, `deadline_at`),
    FOREIGN KEY (`listing_id`) REFERENCES `derp_weed_listings`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `derp_weed_messages` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `npc_id` INT NOT NULL,
    `sender` ENUM('npc','player') NOT NULL,
    `message` TEXT NOT NULL,
    `message_type` ENUM('text','offer','counter','accept','decline','system','location') DEFAULT 'text',
    `metadata` JSON NULL,
    `read_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_citizenid_npc` (`citizenid`, `npc_id`),
    INDEX `idx_citizenid_created` (`citizenid`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `derp_weed_stats` (
    `citizenid` VARCHAR(50) PRIMARY KEY,
    `total_earned` BIGINT NOT NULL DEFAULT 0,
    `total_deals` INT NOT NULL DEFAULT 0,
    `successful_deals` INT NOT NULL DEFAULT 0,
    `total_trust_points` INT NOT NULL DEFAULT 0,
    `deals_today` INT NOT NULL DEFAULT 0,
    `last_deal_date` DATE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET @dbname = DATABASE();
 
SET @col1 := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @dbname
    AND TABLE_NAME = 'derp_weed_relationships'
    AND COLUMN_NAME = 'deals_today');
SET @sql1 := IF(@col1 = 0,
    'ALTER TABLE derp_weed_relationships ADD COLUMN deals_today INT NOT NULL DEFAULT 0 AFTER successful_deals',
    'SELECT "deals_today already exists"');
PREPARE stmt FROM @sql1; EXECUTE stmt; DEALLOCATE PREPARE stmt;
 
SET @col2 := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @dbname
    AND TABLE_NAME = 'derp_weed_relationships'
    AND COLUMN_NAME = 'deals_today_game_day');
SET @sql2 := IF(@col2 = 0,
    'ALTER TABLE derp_weed_relationships ADD COLUMN deals_today_game_day INT NOT NULL DEFAULT 0 AFTER deals_today',
    'SELECT "deals_today_game_day already exists"');
PREPARE stmt FROM @sql2; EXECUTE stmt; DEALLOCATE PREPARE stmt;
 
SET @col3 := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @dbname
    AND TABLE_NAME = 'derp_weed_relationships'
    AND COLUMN_NAME = 'last_completed_at');
SET @sql3 := IF(@col3 = 0,
    'ALTER TABLE derp_weed_relationships ADD COLUMN last_completed_at TIMESTAMP NULL AFTER last_deal_at',
    'SELECT "last_completed_at already exists"');
PREPARE stmt FROM @sql3; EXECUTE stmt; DEALLOCATE PREPARE stmt;