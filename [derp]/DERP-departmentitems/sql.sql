CREATE TABLE IF NOT EXISTS `department_items` (
    `id`          INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid`   VARCHAR(50)  NOT NULL,
    `charname`    VARCHAR(100) NULL DEFAULT NULL,
    `job`         VARCHAR(50)  NOT NULL,
    `grade`       TINYINT      NOT NULL,
    `item_name`   VARCHAR(50)  NOT NULL,
    `drawable`    SMALLINT     NOT NULL,
    `texture`     SMALLINT     NOT NULL,
    `gender`      TINYINT      NOT NULL,
    `received_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `returned_at` TIMESTAMP    NULL DEFAULT NULL,
    INDEX `idx_citizenid`  (`citizenid`),
    INDEX `idx_job_active` (`job`, `returned_at`)
);

ALTER TABLE `department_items` ADD COLUMN `department_id` VARCHAR(20) NULL DEFAULT NULL;