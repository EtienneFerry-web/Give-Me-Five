-- Migration : support des films issus de l'API RapidAPI/Streaming Availability
-- À exécuter une seule fois sur la base givemefive

ALTER TABLE `movies`
    ADD COLUMN `mov_api_id` VARCHAR(100) NULL DEFAULT NULL COMMENT 'Identifiant API externe (ex: tt1234567)'
        AFTER `mov_id`,
    ADD UNIQUE KEY `uk_mov_api_id` (`mov_api_id`);
