-- ============================================================
--  kq_powerwashing — SQL
--  Uitvoeren in je database (MySQL / MariaDB)
--  Vereist door: kq_jobcontracts (job stats opslag)
-- ============================================================

-- ─────────────────────────────────────────────
--  Job stats tabel
--  Slaat XP en level op per speler per job-type
-- ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `kq_job_stats` (
    `id`         INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(64)     NOT NULL,           -- speler identifier (license, steam, etc.)
    `job_key`    VARCHAR(64)     NOT NULL,           -- bijv. 'powerwashing'
    `level`      SMALLINT        NOT NULL DEFAULT 1,
    `xp`         INT UNSIGNED    NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_player_job` (`identifier`, `job_key`),
    INDEX `idx_identifier`  (`identifier`),
    INDEX `idx_job_key`     (`job_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────
--  Job upgrades tabel
--  Bijhoudt welke upgrades een speler heeft ontgrendeld
-- ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `kq_job_upgrades` (
    `id`           INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `identifier`   VARCHAR(64)     NOT NULL,
    `job_key`      VARCHAR(64)     NOT NULL,
    `upgrade_key`  VARCHAR(64)     NOT NULL,         -- bijv. 'outfit_worker', 'salary_bonus_5'
    `unlocked_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_player_upgrade` (`identifier`, `job_key`, `upgrade_key`),
    INDEX `idx_identifier_job` (`identifier`, `job_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────
--  Contract log tabel  (optioneel — voor statistieken)
-- ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `kq_contract_log` (
    `id`           INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `contract_id`  VARCHAR(128)    NOT NULL,
    `job_key`      VARCHAR(64)     NOT NULL,
    `identifier`   VARCHAR(64)     NOT NULL,         -- leider identifier
    `reward`       INT UNSIGNED    NOT NULL DEFAULT 0,
    `member_count` TINYINT         NOT NULL DEFAULT 1,
    `duration_sec` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `completed_at` TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_identifier` (`identifier`),
    INDEX `idx_job_key`    (`job_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────
--  Voorbeeld: handmatig een speler op level 5 zetten
--  (vervang 'license:xxxx' door het echte identifier)
-- ─────────────────────────────────────────────

-- INSERT INTO `kq_job_stats` (`identifier`, `job_key`, `level`, `xp`)
-- VALUES ('license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 'powerwashing', 5, 4000)
-- ON DUPLICATE KEY UPDATE `level` = 5, `xp` = 4000;
