-- SQL Migration: Add cloth_slots column to players table
-- Run this ONCE on your database

ALTER TABLE `players`
ADD COLUMN `cloth_slots` LONGTEXT NULL DEFAULT NULL
COMMENT 'JSON data for equipped clothing slots (1-14)';

-- Example data format:
-- {
--   "1": { "name": "mu", "drawableId": 5, "textureId": 0, "gender": 0 },
--   "3": { "name": "aokhoac", "drawableId": 12, "textureId": 2, "gender": 0 },
--   "6": { "name": "quan", "drawableId": 4, "textureId": 0, "gender": 0 }
-- }
-- Slots not present in JSON = not equipped

CREATE TABLE IF NOT EXISTS `clothing_glove_extras` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `drawable` INT NOT NULL,
    `texture` INT NOT NULL DEFAULT 0,
    UNIQUE KEY `uk_citizen_drawable_texture` (`citizenid`, `drawable`, `texture`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- DTB cho găng tay

-- Migration: Add weapon_skin_slots column to players table
ALTER TABLE `players`
ADD COLUMN `weapon_skin_slots` LONGTEXT NULL DEFAULT NULL
AFTER `cloth_slots`;