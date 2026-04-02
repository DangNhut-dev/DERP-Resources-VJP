ALTER TABLE `player_vehicles` 
ADD COLUMN `label` VARCHAR(50) NULL DEFAULT NULL AFTER `plate`;

ALTER TABLE `player_vehicles` 
MODIFY COLUMN `coords` TEXT NULL DEFAULT NULL;

CREATE INDEX IF NOT EXISTS `idx_state_coords` ON `player_vehicles` (`state`, `coords`(255));

CREATE INDEX IF NOT EXISTS `idx_plate` ON `player_vehicles` (`plate`);

CREATE INDEX IF NOT EXISTS `idx_citizenid_state` ON `player_vehicles` (`citizenid`, `state`);

-- ================================================
-- DERP Advanced Garages - Impound System Migration
-- ================================================

ALTER TABLE `player_vehicles`
ADD COLUMN `impound_price` INT NULL DEFAULT NULL AFTER `garage`,
ADD COLUMN `impound_duration` INT NULL DEFAULT NULL COMMENT 'Thời gian giam tính bằng phút' AFTER `impound_price`,
ADD COLUMN `impound_reason` VARCHAR(255) NULL DEFAULT NULL AFTER `impound_duration`,
ADD COLUMN `impound_by` VARCHAR(100) NULL DEFAULT NULL COMMENT 'Tên người giam xe' AFTER `impound_reason`,
ADD COLUMN `impound_start_time` BIGINT NULL DEFAULT NULL COMMENT 'Timestamp bắt đầu giam (milliseconds)' AFTER `impound_by`;

ALTER TABLE `player_vehicles`
ADD COLUMN `lock_state` TINYINT NOT NULL DEFAULT 2 COMMENT '1=unlocked, 2=locked' AFTER `status`;

-- Index để tăng tốc query
CREATE INDEX `idx_impound_garage` ON `player_vehicles` (`garage`, `impound_start_time`);