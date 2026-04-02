ALTER TABLE `users`
    ADD IF NOT EXISTS `ambulanceData` longtext NOT NULL DEFAULT '{"health": 200, "armor": 0, "type": "none", "damages": "{}"}';

CREATE TABLE IF NOT EXISTS `medic_outfits` (
  `id` int(11) NOT NULL,
  `job` varchar(30) NOT NULL,
  `grade` longtext NOT NULL,
  `label` varchar(60) NOT NULL,
  `gender` varchar(10) NOT NULL,
  `license` longtext DEFAULT 'none',
  `requirements` varchar(50) NOT NULL,
  `skin` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

ALTER TABLE `medic_outfits`
  ADD PRIMARY KEY IF NOT EXISTS (`id`);

ALTER TABLE `medic_outfits`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

CREATE TABLE IF NOT EXISTS `health_insurances` (
  `owner` varchar(60) NOT NULL,
  `insurance` varchar(30) NOT NULL,
  `duration` bigint(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

ALTER TABLE `health_insurances`
  ADD PRIMARY KEY IF NOT EXISTS (`owner`);
COMMIT;