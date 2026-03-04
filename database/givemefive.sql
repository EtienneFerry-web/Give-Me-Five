-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : mer. 04 mars 2026 à 12:39
-- Version du serveur : 8.4.7
-- Version de PHP : 8.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `givemefive`
--

DELIMITER $$
--
-- Procédures
--
DROP PROCEDURE IF EXISTS `auto_ban_users`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `auto_ban_users` (IN `id` INT, IN `reason` VARCHAR(255))   BEGIN
    DECLARE nbr INT DEFAULT 0;

    SELECT COUNT(DISTINCT hist_id) INTO nbr
    FROM history_users 
    WHERE hist_event = 'UPDATE' AND hist_field = 'user_ban_at' AND hist_elementid = id AND hist_newValue IS NOT NULL;

    
    CASE 
        WHEN nbr = 0 THEN
            UPDATE users 
            SET user_ban_at = CURDATE() + INTERVAL 15 DAY, 
                user_reason_ban = reason 
            WHERE user_id = id AND user_funct_id != 3;
            
        WHEN nbr = 1 THEN
            UPDATE users 
            SET user_ban_at = CURDATE() + INTERVAL 30 DAY, 
                user_reason_ban = reason 
            WHERE user_id = id AND user_funct_id != 3;
            
        WHEN nbr = 2 THEN
            UPDATE users 
            SET user_ban_at = CURDATE() + INTERVAL 60 DAY, 
                user_reason_ban = reason 
            WHERE user_id = id AND user_funct_id != 3;
            
        WHEN nbr = 3 THEN
            UPDATE users 
            SET user_ban_at = CURDATE() + INTERVAL 120 DAY, 
                user_reason_ban = reason 
            WHERE user_id = id AND user_funct_id != 3;
            
        WHEN nbr >= 4 THEN
            UPDATE users 
            SET user_ban_at = CURDATE() + INTERVAL 999 YEAR, 
                user_reason_ban = reason,
                user_pseudo = NULL,
                user_photo = NULL,
                user_bio = NULL
            WHERE user_id = id AND user_funct_id != 3;
    END CASE;
END$$

DROP PROCEDURE IF EXISTS `unban_user`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `unban_user` (IN `target_id` INT)   BEGIN
    
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

        
        UPDATE users 
        SET user_ban_at = NULL, 
            user_reason_ban = NULL 
        WHERE user_id = target_id;

        
        DELETE FROM history_users 
        WHERE hist_elementId = target_id 
          AND hist_field = 'user_ban_at'
        ORDER BY hist_id DESC 
        LIMIT 1;

    COMMIT;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `belongs`
--

DROP TABLE IF EXISTS `belongs`;
CREATE TABLE IF NOT EXISTS `belongs` (
  `belong_cat_id` int UNSIGNED NOT NULL,
  `belong_mov_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`belong_cat_id`,`belong_mov_id`),
  KEY `fk_belong_mov_id` (`belong_mov_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `belongs`
--

INSERT INTO `belongs` (`belong_cat_id`, `belong_mov_id`) VALUES
(1, 13),
(4, 14),
(3, 15),
(6, 16),
(8, 18),
(9, 19),
(10, 20),
(10, 21),
(10, 22),
(10, 24),
(10, 25),
(7, 32);

-- --------------------------------------------------------

--
-- Structure de la table `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE IF NOT EXISTS `categories` (
  `cat_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Categories ID',
  `cat_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Categories name',
  PRIMARY KEY (`cat_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `categories`
--

INSERT INTO `categories` (`cat_id`, `cat_name`) VALUES
(1, 'Science-fiction'),
(2, 'Horreur'),
(3, 'Drame'),
(4, 'Guerre'),
(5, 'Thriller'),
(6, 'Mystère'),
(7, 'Fantastique'),
(8, 'Expérimental'),
(9, 'Biopic'),
(10, 'Néo-noir');

-- --------------------------------------------------------

--
-- Structure de la table `comments`
--

DROP TABLE IF EXISTS `comments`;
CREATE TABLE IF NOT EXISTS `comments` (
  `com_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Comment ID',
  `com_comment` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Comment content',
  `com_datetime` datetime NOT NULL COMMENT 'Comment date time',
  `com_user_id` int UNSIGNED DEFAULT NULL,
  `com_movie_id` int UNSIGNED DEFAULT NULL,
  `com_spoiler` tinyint(1) NOT NULL DEFAULT '0',
  `com_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`com_id`),
  UNIQUE KEY `id_user_movie` (`com_user_id`,`com_movie_id`),
  KEY `fk_com_user_id` (`com_user_id`),
  KEY `fk_com_movie_id` (`com_movie_id`)
) ENGINE=InnoDB AUTO_INCREMENT=110 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `comments`
--

INSERT INTO `comments` (`com_id`, `com_comment`, `com_datetime`, `com_user_id`, `com_movie_id`, `com_spoiler`, `com_updated_at`) VALUES
(8, 'Difficile à regarder, trop de violence gratuite.', '2024-05-12 11:10:00', 7, 13, 1, NULL),
(9, 'La musique de Beethoven n\'a jamais été aussi effrayante.', '2024-10-15 14:00:00', 2, 13, 0, NULL),
(11, 'Moins fan de la partie au Vietnam.', '2024-07-04 15:00:00', 4, 14, 0, NULL),
(12, 'Ce film est nul, je déteste tout !', '2024-09-01 10:30:00', 5, 14, 0, NULL),
(13, 'Une atmosphère onirique et envoûtante.', '2024-08-14 23:45:00', 10, 15, 0, NULL),
(14, 'Je n\'ai pas tout compris, c\'est bizarre.', '2024-09-01 10:30:00', 5, 15, 0, NULL),
(15, 'Le dernier film de Kubrick est son plus mystérieux.', '2024-08-05 18:45:00', 1, 15, 0, NULL),
(16, 'Le puzzle cinématographique ultime. Lynch est un génie.', '2024-10-12 21:00:00', 1, 16, 0, NULL),
(18, 'Naomi Watts est incroyable dans ce film.', '2024-07-30 21:15:00', 9, 16, 0, NULL),
(23, 'Trop bizarre pour moi, j\'ai arrêté.', '2024-04-10 16:40:00', 9, 18, 0, NULL),
(25, 'Le film le plus humain et touchant de Lynch.', '2024-12-20 20:30:00', 7, 19, 0, NULL),
(26, 'Photographie en noir et blanc sublime.', '2024-01-05 17:15:00', 4, 19, 0, NULL),
(27, 'Je ne suis pas un animal, je suis un être humain !', '2024-04-14 20:00:00', 10, 19, 1, NULL),
(28, 'La BO avec Rammstein et Bowie est folle.', '2024-06-18 22:15:00', 5, 20, 0, NULL),
(29, 'L\'homme mystérieux me donne des frissons.', '2024-07-22 13:50:00', 10, 20, 0, NULL),
(30, 'Une boucle temporelle fascinante à analyser.', '2024-03-22 16:50:00', 4, 20, 0, NULL),
(105, '😁😁😁😁😁😁😁😁😁😁😁😁', '2026-03-03 20:29:58', 17, 32, 0, NULL),
(108, 'test', '2026-03-04 09:31:04', 23, 25, 0, '2026-03-04 09:33:38'),
(109, 'dzqdqzd', '2026-03-04 11:38:27', 23, 21, 0, NULL);

--
-- Déclencheurs `comments`
--
DROP TRIGGER IF EXISTS `after_insert_comments`;
DELIMITER $$
CREATE TRIGGER `after_insert_comments` AFTER INSERT ON `comments` FOR EACH ROW INSERT INTO history_comments (hist_table, hist_event, hist_elementid, hist_date, hist_userid)
VALUES ('comments', 'INSERT', NEW.com_id, NOW(), NEW.com_user_id)
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `after_update_comments`;
DELIMITER $$
CREATE TRIGGER `after_update_comments` AFTER UPDATE ON `comments` FOR EACH ROW BEGIN
    IF OLD.com_comment != NEW.com_comment THEN
        INSERT INTO history_comments (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue, hist_userid)
        VALUES ('comments', 'UPDATE', NEW.com_id, NOW(), 'com_comment', OLD.com_comment, NEW.com_comment, NEW.com_user_id);
    END IF;

    IF OLD.com_user_id != NEW.com_user_id THEN
        INSERT INTO history_comments (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue, hist_userid)
        VALUES ('comments', 'UPDATE', NEW.com_id, NOW(), 'com_user_id', OLD.com_user_id, NEW.com_user_id, NEW.com_user_id);
    END IF;
    
    IF OLD.com_spoiler != NEW.com_spoiler THEN
        INSERT INTO history_comments (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue, hist_userid)
        VALUES ('comments', 'UPDATE', NEW.com_id, NOW(), 'com_spoiler', OLD.com_spoiler, NEW.com_spoiler, NEW.com_user_id);
    END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `before_delete_comments`;
DELIMITER $$
CREATE TRIGGER `before_delete_comments` BEFORE DELETE ON `comments` FOR EACH ROW INSERT INTO history_comments (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue, hist_userid)
VALUES ('comments', 'DELETE', OLD.com_id, NOW(), 'com_comment', OLD.com_comment, NULL, OLD.com_user_id)
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `functions`
--

DROP TABLE IF EXISTS `functions`;
CREATE TABLE IF NOT EXISTS `functions` (
  `funct_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Function ID',
  `funct_name` enum('User','Moderator','Administrator') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`funct_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `functions`
--

INSERT INTO `functions` (`funct_id`, `funct_name`) VALUES
(1, 'User'),
(2, 'Moderator'),
(3, 'Administrator');

-- --------------------------------------------------------

--
-- Structure de la table `history_comments`
--

DROP TABLE IF EXISTS `history_comments`;
CREATE TABLE IF NOT EXISTS `history_comments` (
  `hist_id` int NOT NULL AUTO_INCREMENT,
  `hist_table` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hist_event` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hist_elementid` int NOT NULL,
  `hist_date` datetime DEFAULT NULL,
  `hist_field` text COLLATE utf8mb4_unicode_ci,
  `hist_oldvalue` text COLLATE utf8mb4_unicode_ci,
  `hist_newvalue` text COLLATE utf8mb4_unicode_ci,
  `hist_userid` int NOT NULL,
  PRIMARY KEY (`hist_id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `history_comments`
--

INSERT INTO `history_comments` (`hist_id`, `hist_table`, `hist_event`, `hist_elementid`, `hist_date`, `hist_field`, `hist_oldvalue`, `hist_newvalue`, `hist_userid`) VALUES
(1, 'comments', 'INSERT', 89, '2026-02-20 10:34:32', NULL, NULL, NULL, 17),
(2, 'comments', 'UPDATE', 89, '2026-02-20 10:41:45', 'com_comment', 'C nulllllldqzdqzdqzdzqzddqzdzzdq', 'dzqdqzdqzdqzdzq', 17),
(3, 'comments', 'DELETE', 89, '2026-02-20 10:42:28', 'com_comment', 'dzqdqzdqzdqzdzq', NULL, 17),
(4, 'comments', 'UPDATE', 22, '2026-02-20 21:09:11', 'com_spoiler', '0', '1', 3),
(5, 'comments', 'UPDATE', 22, '2026-02-20 21:09:14', 'com_spoiler', '1', '0', 3),
(6, 'comments', 'INSERT', 90, '2026-02-20 21:51:54', NULL, NULL, NULL, 17),
(7, 'comments', 'UPDATE', 90, '2026-02-20 21:51:58', 'com_spoiler', '0', '1', 17),
(8, 'comments', 'UPDATE', 90, '2026-02-20 21:52:00', 'com_spoiler', '1', '0', 17),
(9, 'comments', 'DELETE', 90, '2026-02-20 21:52:03', 'com_comment', 'dzqdzqd', NULL, 17),
(10, 'comments', 'INSERT', 91, '2026-02-20 21:52:05', NULL, NULL, NULL, 17),
(11, 'comments', 'UPDATE', 91, '2026-02-20 21:52:11', 'com_comment', 'dqdzqdqz', 'dqdzqdqzdzqdzqdqzd', 17),
(12, 'comments', 'UPDATE', 23, '2026-02-20 21:54:22', 'com_spoiler', '0', '1', 9),
(13, 'comments', 'UPDATE', 23, '2026-02-20 21:54:23', 'com_spoiler', '1', '0', 9),
(14, 'comments', 'DELETE', 91, '2026-02-21 14:06:00', 'com_comment', 'dqdzqdqzdzqdzqdqzd', NULL, 17),
(15, 'comments', 'INSERT', 92, '2026-02-21 22:54:15', NULL, NULL, NULL, 17),
(16, 'comments', 'DELETE', 92, '2026-02-21 22:58:50', 'com_comment', 'dqzdzqd', NULL, 17),
(17, 'comments', 'INSERT', 93, '2026-02-21 22:59:12', NULL, NULL, NULL, 17),
(18, 'comments', 'DELETE', 93, '2026-02-21 22:59:16', 'com_comment', 'dqdqzd', NULL, 17),
(19, 'comments', 'INSERT', 94, '2026-02-24 11:46:40', NULL, NULL, NULL, 17),
(20, 'comments', 'DELETE', 94, '2026-02-24 13:34:21', 'com_comment', 'dzqdzqd', NULL, 17),
(21, 'comments', 'UPDATE', 30, '2026-02-26 22:14:50', 'com_spoiler', '0', '1', 4),
(22, 'comments', 'UPDATE', 30, '2026-02-26 22:14:52', 'com_spoiler', '1', '0', 4),
(23, 'comments', 'UPDATE', 30, '2026-02-26 22:15:09', 'com_spoiler', '0', '1', 4),
(24, 'comments', 'UPDATE', 30, '2026-02-26 22:15:12', 'com_spoiler', '1', '0', 4),
(25, 'comments', 'INSERT', 95, '2026-02-27 21:31:25', NULL, NULL, NULL, 17),
(26, 'comments', 'UPDATE', 11, '2026-02-27 21:48:28', 'com_spoiler', '1', '0', 4),
(27, 'comments', 'DELETE', 95, '2026-02-28 21:05:15', 'com_comment', 'ttstetsfes', NULL, 17),
(28, 'comments', 'INSERT', 96, '2026-02-28 23:38:20', NULL, NULL, NULL, 17),
(29, 'comments', 'UPDATE', 96, '2026-02-28 23:45:35', 'com_comment', 'dzqdzqdzq', 'dzqdzqdzqdzqdzq', 17),
(30, 'comments', 'UPDATE', 96, '2026-03-02 15:33:18', 'com_comment', 'dzqdzqdzqdzqdzq', 'dzqdzqdzqdzqdzqdqzdqzdzq', 17),
(31, 'comments', 'DELETE', 96, '2026-03-02 15:33:21', 'com_comment', 'dzqdzqdzqdzqdzqdqzdqzdzq', NULL, 17),
(32, 'comments', 'INSERT', 97, '2026-03-02 15:41:00', NULL, NULL, NULL, 17),
(33, 'comments', 'DELETE', 97, '2026-03-02 15:46:45', 'com_comment', 'dqzdqzdzqd', NULL, 17),
(34, 'comments', 'INSERT', 99, '2026-03-02 15:46:59', NULL, NULL, NULL, 17),
(35, 'comments', 'UPDATE', 12, '2026-03-02 15:48:50', 'com_spoiler', '1', '0', 5),
(36, 'comments', 'UPDATE', 99, '2026-03-02 16:01:45', 'com_comment', 'dzqdzq', 'dzqdzqsssssssssssssss', 17),
(37, 'comments', 'DELETE', 99, '2026-03-02 16:19:28', 'com_comment', 'dzqdzqsssssssssssssss', NULL, 17),
(38, 'comments', 'INSERT', 100, '2026-03-02 21:33:50', NULL, NULL, NULL, 17),
(39, 'comments', 'DELETE', 100, '2026-03-02 21:39:12', 'com_comment', '????????', NULL, 17),
(40, 'comments', 'INSERT', 102, '2026-03-02 21:39:14', NULL, NULL, NULL, 17),
(41, 'comments', 'DELETE', 102, '2026-03-02 21:41:45', 'com_comment', '????????', NULL, 17),
(42, 'comments', 'INSERT', 103, '2026-03-02 21:41:54', NULL, NULL, NULL, 17),
(43, 'comments', 'UPDATE', 103, '2026-03-02 21:42:14', 'com_spoiler', '0', '1', 17),
(44, 'comments', 'UPDATE', 103, '2026-03-02 21:42:17', 'com_spoiler', '1', '0', 17),
(45, 'comments', 'DELETE', 103, '2026-03-02 21:42:36', 'com_comment', '🕵️‍♂️', NULL, 17),
(46, 'comments', 'INSERT', 104, '2026-03-02 21:42:39', NULL, NULL, NULL, 17),
(47, 'comments', 'DELETE', 22, '2026-03-02 21:55:07', 'com_comment', 'L\'expérience la plus sonore et visuelle de ma vie.', NULL, 3),
(48, 'comments', 'DELETE', 104, '2026-03-03 20:29:24', 'com_comment', 'dzqdzqd 🕵️‍♂️', NULL, 17),
(49, 'comments', 'INSERT', 105, '2026-03-03 20:29:58', NULL, NULL, NULL, 17),
(50, 'comments', 'INSERT', 106, '2026-03-04 08:46:58', NULL, NULL, NULL, 23),
(51, 'comments', 'UPDATE', 106, '2026-03-04 08:47:17', 'com_comment', '😎😎😎😎😎', '😎😎😎😎😎😒😒😒😒😒', 23),
(52, 'comments', 'DELETE', 106, '2026-03-04 08:47:28', 'com_comment', '😎😎😎😎😎😒😒😒😒😒', NULL, 23),
(53, 'comments', 'INSERT', 107, '2026-03-04 09:25:37', NULL, NULL, NULL, 23),
(54, 'comments', 'DELETE', 107, '2026-03-04 09:28:34', 'com_comment', '<h1>test</h1>', NULL, 23),
(55, 'comments', 'INSERT', 108, '2026-03-04 09:31:04', NULL, NULL, NULL, 23),
(56, 'comments', 'UPDATE', 108, '2026-03-04 09:33:38', 'com_comment', ' test ', 'test', 23),
(57, 'comments', 'INSERT', 109, '2026-03-04 11:38:27', NULL, NULL, NULL, 23);

-- --------------------------------------------------------

--
-- Structure de la table `history_contents`
--

DROP TABLE IF EXISTS `history_contents`;
CREATE TABLE IF NOT EXISTS `history_contents` (
  `hist_id` int NOT NULL AUTO_INCREMENT,
  `hist_table` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hist_event` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hist_elementid` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hist_date` datetime NOT NULL,
  `hist_field` text COLLATE utf8mb4_unicode_ci,
  `hist_oldvalue` text COLLATE utf8mb4_unicode_ci,
  `hist_newvalue` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`hist_id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `history_contents`
--

INSERT INTO `history_contents` (`hist_id`, `hist_table`, `hist_event`, `hist_elementid`, `hist_date`, `hist_field`, `hist_oldvalue`, `hist_newvalue`) VALUES
(1, 'movies', 'DELETE', '29', '2026-02-24 15:40:28', NULL, NULL, NULL),
(2, 'movies', 'DELETE', '30', '2026-02-28 18:35:59', NULL, NULL, NULL),
(3, 'movies', 'UPDATE', '29', '2026-02-28 21:32:27', 'mov_title', 'test', 'testntm'),
(4, 'movies', 'DELETE', '30', '2026-02-28 21:33:45', NULL, NULL, NULL),
(5, 'movies', 'DELETE', '31', '2026-02-28 21:34:18', NULL, NULL, NULL),
(6, 'movies', 'DELETE', '31', '2026-02-28 21:34:33', NULL, NULL, NULL),
(7, 'movies', 'DELETE', '17', '2026-03-02 20:16:59', NULL, NULL, NULL),
(8, 'movies', 'DELETE', '29', '2026-03-02 20:25:33', NULL, NULL, NULL),
(9, 'persons', 'UPDATE', '3', '2026-03-02 20:35:57', 'pers_deathdate', '2008-03-19', '2008-03-19'),
(10, 'persons', 'UPDATE', '3', '2026-03-02 20:35:57', 'pers_photo', 'https://encrypted-tbn0.gstatic.com/licensed-image?q=tbn:ANd9GcSkYSBpua4nWLeJZKz2RIrPgYPlYmz9vfA7K_qKvndm8KzaXivfCgxgLmxCsO8Z4DiVnbaU3bMV24mG39w', '69a5e69d9b550.webp'),
(11, 'persons', 'UPDATE', '8', '2026-03-02 20:37:22', 'pers_deathdate', '1996-12-30', '1996-12-30'),
(12, 'persons', 'UPDATE', '8', '2026-03-02 20:37:22', 'pers_photo', 'https://encrypted-tbn0.gstatic.com/licensed-image?q=tbn:ANd9GcSkYSBpua4nWLeJZKz2RIrPgYPlYmz9vfA7K_qKvndm8KzaXivfCgxgLmxCsO8Z4DiVnbaU3bMV24mG39w', '69a5e6f275ba7.webp'),
(13, 'persons', 'UPDATE', '8', '2026-03-02 20:38:39', 'pers_deathdate', '1996-12-30', '1996-12-30'),
(14, 'persons', 'UPDATE', '8', '2026-03-02 20:38:39', 'pers_photo', '69a5e6f275ba7.webp', '69a5e73fb3c67.webp'),
(15, 'persons', 'UPDATE', '8', '2026-03-02 20:38:49', 'pers_deathdate', '1996-12-30', '1996-12-30'),
(16, 'persons', 'UPDATE', '8', '2026-03-02 20:38:49', 'pers_photo', '69a5e73fb3c67.webp', '69a5e7494b4fe.webp'),
(17, 'persons', 'UPDATE', '4', '2026-03-02 20:41:06', 'pers_photo', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/David_Lynch_Cannes_2017.jpg/250px-David_Lynch_Cannes_2017.jpg', '69a5e7d22ca6e.webp'),
(18, 'persons', 'UPDATE', '9', '2026-03-02 20:41:51', 'pers_deathdate', '2017-01-25', '2017-01-25'),
(19, 'persons', 'UPDATE', '9', '2026-03-02 20:41:51', 'pers_photo', 'https://encrypted-tbn0.gstatic.com/licensed-image?q=tbn:ANd9GcSkYSBpua4nWLeJZKz2RIrPgYPlYmz9vfA7K_qKvndm8KzaXivfCgxgLmxCsO8Z4DiVnbaU3bMV24mG39w', '69a5e7ff4462f.webp'),
(20, 'persons', 'UPDATE', '10', '2026-03-02 20:42:19', 'pers_photo', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/David_Lynch_Cannes_2017.jpg/250px-David_Lynch_Cannes_2017.jpg', '69a5e81b6d268.webp'),
(21, 'persons', 'UPDATE', '5', '2026-03-02 20:42:38', 'pers_photo', 'https://encrypted-tbn0.gstatic.com/licensed-image?q=tbn:ANd9GcSkYSBpua4nWLeJZKz2RIrPgYPlYmz9vfA7K_qKvndm8KzaXivfCgxgLmxCsO8Z4DiVnbaU3bMV24mG39w', '69a5e82ee52dc.webp'),
(22, 'persons', 'UPDATE', '7', '2026-03-02 20:43:08', 'pers_photo', 'https://encrypted-tbn0.gstatic.com/licensed-image?q=tbn:ANd9GcSkYSBpua4nWLeJZKz2RIrPgYPlYmz9vfA7K_qKvndm8KzaXivfCgxgLmxCsO8Z4DiVnbaU3bMV24mG39w', '69a5e84c31ead.webp'),
(23, 'persons', 'UPDATE', '6', '2026-03-02 20:44:07', 'pers_deathdate', '2018-04-15', '2018-04-15'),
(24, 'persons', 'UPDATE', '6', '2026-03-02 20:44:07', 'pers_photo', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/David_Lynch_Cannes_2017.jpg/250px-David_Lynch_Cannes_2017.jpg', '69a5e88781bea.webp'),
(25, 'movies', 'DELETE', '32', '2026-03-02 21:22:49', NULL, NULL, NULL),
(26, 'movies', 'UPDATE', '32', '2026-03-04 09:11:02', 'mov_release_date', '2026-03-02', '2026-03-05'),
(27, 'movies', 'UPDATE', '21', '2026-03-04 10:26:35', 'mov_length', '03:10:00', '03:11:00');

-- --------------------------------------------------------

--
-- Structure de la table `history_users`
--

DROP TABLE IF EXISTS `history_users`;
CREATE TABLE IF NOT EXISTS `history_users` (
  `hist_id` int NOT NULL AUTO_INCREMENT,
  `hist_table` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hist_event` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hist_elementid` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hist_date` datetime NOT NULL,
  `hist_field` text COLLATE utf8mb4_unicode_ci,
  `hist_oldvalue` text COLLATE utf8mb4_unicode_ci,
  `hist_newvalue` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`hist_id`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `history_users`
--

INSERT INTO `history_users` (`hist_id`, `hist_table`, `hist_event`, `hist_elementid`, `hist_date`, `hist_field`, `hist_oldvalue`, `hist_newvalue`) VALUES
(1, 'users', 'UPDATE', '17', '2026-02-19 20:33:56', 'user_ban_at', NULL, '0000-00-00 00:00:00'),
(2, 'users', 'UPDATE', '17', '2026-02-19 21:42:01', 'user_ban_at', '0000-00-00 00:00:00', '2026-03-06 21:42:01'),
(3, 'users', 'UPDATE', '17', '2026-02-19 21:57:37', 'user_ban_at', '2026-03-06 21:42:01', '2026-03-21 00:00:00'),
(4, 'users', 'UPDATE', '17', '2026-02-19 21:58:35', 'user_ban_at', '2026-03-21 00:00:00', '2026-04-20 00:00:00'),
(5, 'users', 'UPDATE', '17', '2026-02-19 21:59:44', 'user_ban_at', '2026-04-20 00:00:00', '2026-06-19 00:00:00'),
(6, 'users', 'UPDATE', '17', '2026-02-19 22:00:32', 'user_ban_at', '2026-06-19 00:00:00', '3025-02-19 00:00:00'),
(7, 'users', 'UPDATE', '4', '2026-02-19 22:25:21', 'user_ban_at', NULL, '2026-02-20 00:00:00'),
(8, 'users', 'UPDATE', '7', '2026-02-19 22:34:00', 'user_funct_id', '1', '3'),
(9, 'users', 'UPDATE', '7', '2026-02-19 22:34:05', 'user_firstname', 'Antoine', 'Antoinedzqdqz'),
(10, 'users', 'INSERT', '26', '2026-02-20 08:33:57', NULL, NULL, NULL),
(11, 'users', 'UPDATE', '9', '2026-02-20 20:42:58', 'user_ban_at', NULL, '2026-03-07 00:00:00'),
(12, 'users', 'UPDATE', '5', '2026-02-20 21:01:03', 'user_ban_at', NULL, '2026-03-07 00:00:00'),
(13, 'users', 'UPDATE', '5', '2026-02-20 21:08:37', 'user_ban_at', '2026-03-07 00:00:00', NULL),
(14, 'users', 'UPDATE', '5', '2026-02-20 21:09:24', 'user_ban_at', NULL, '2026-04-21 00:00:00'),
(15, 'users', 'UPDATE', '5', '2026-02-20 21:09:30', 'user_ban_at', '2026-04-21 00:00:00', NULL),
(16, 'users', 'UPDATE', '9', '2026-02-20 21:53:22', 'user_ban_at', '2026-03-07 00:00:00', '2026-03-22 00:00:00'),
(17, 'users', 'UPDATE', '9', '2026-02-20 21:54:18', 'user_ban_at', '2026-03-22 00:00:00', '2026-04-21 00:00:00'),
(18, 'users', 'UPDATE', '9', '2026-02-20 21:54:20', 'user_ban_at', '2026-04-21 00:00:00', NULL),
(19, 'users', 'UPDATE', '24', '2026-02-20 22:11:38', 'user_funct_id', '1', '2'),
(20, 'users', 'UPDATE', '3', '2026-02-20 22:31:12', 'user_ban_at', NULL, '2026-03-07 00:00:00'),
(21, 'users', 'UPDATE', '3', '2026-02-20 22:31:16', 'user_ban_at', '2026-03-07 00:00:00', NULL),
(22, 'users', 'UPDATE', '3', '2026-02-24 09:14:11', 'user_ban_at', NULL, '2026-04-25 00:00:00'),
(23, 'users', 'UPDATE', '3', '2026-02-24 09:14:13', 'user_ban_at', '2026-04-25 00:00:00', NULL),
(24, 'users', 'INSERT', '27', '2026-02-24 10:30:22', NULL, NULL, NULL),
(25, 'users', 'INSERT', '28', '2026-02-24 10:37:56', NULL, NULL, NULL),
(26, 'users', 'INSERT', '29', '2026-02-24 10:39:24', NULL, NULL, NULL),
(27, 'users', 'UPDATE', '17', '2026-02-24 11:15:29', 'user_bio', 'dzqdzqdqzdzqdqzdzqdzqdqzdqzddzqdzqdz', '<h2> zdqdqzd z</h2>\r\n'),
(28, 'users', 'UPDATE', '3', '2026-02-24 13:32:25', 'user_pseudo', 'luke_sky', ''),
(29, 'users', 'UPDATE', '3', '2026-02-24 13:32:25', 'user_ban_at', NULL, '3025-02-24 00:00:00'),
(30, 'users', 'UPDATE', '3', '2026-02-24 13:33:36', 'user_ban_at', '3025-02-24 00:00:00', NULL),
(31, 'users', 'UPDATE', '24', '2026-02-24 13:33:47', 'user_ban_at', NULL, '2026-03-11 00:00:00'),
(32, 'users', 'UPDATE', '24', '2026-02-24 13:33:50', 'user_ban_at', '2026-03-11 00:00:00', NULL),
(33, 'users', 'INSERT', '30', '2026-02-25 20:28:16', NULL, NULL, NULL),
(34, 'users', 'INSERT', '31', '2026-02-25 20:32:07', NULL, NULL, NULL),
(35, 'users', 'UPDATE', '17', '2026-02-25 21:43:28', 'user_bio', '<h2> zdqdqzd z</h2>\r\n', '<h2> zdqdqdqzdqdzqzd z</h2>\r\n'),
(36, 'users', 'UPDATE', '17', '2026-02-25 21:48:46', 'user_bio', '<h2> zdqdqdqzdqdzqzd z</h2>\r\n', '<h2> zdqdqdqzddqzdqdzqdqdzqzd z</h2>\r\n'),
(37, 'users', 'UPDATE', '17', '2026-02-25 21:51:54', 'user_bio', '<h2> zdqdqdqzddqzdqdzqdqdzqzd z</h2>\r\n', ' zdqdqdqzddqzdqdzqdqdzqzd zdzqdzqd'),
(38, 'users', 'UPDATE', '17', '2026-02-27 16:56:24', 'user_ban_at', '3025-02-19 00:00:00', NULL),
(39, 'users', 'UPDATE', '23', '2026-02-28 15:12:43', 'user_pwd', '$2y$10$rBwyIBmYDriRgNCVsBrqsuW2wzv1y.7az5Ps79.sGeh3oauP1SIzq', '$2y$10$ZWiLqzPoxwvP5KSCRW.Ac.VDgw41CLBalyfmtQ3jolT062c78.M2W'),
(40, 'users', 'UPDATE', '3', '2026-02-28 22:16:54', 'user_ban_at', NULL, '3025-02-28 00:00:00'),
(42, 'users', 'UPDATE', '23', '2026-03-01 16:55:20', 'user_photo', '698b01cf4551c.png', '69a46168ac5d7.png'),
(43, 'users', 'UPDATE', '17', '2026-03-02 15:33:27', 'user_pseudo', 'Test', 'Testzzzzzzzz'),
(44, 'users', 'UPDATE', '17', '2026-03-02 15:33:27', 'user_bio', ' zdqdqdqzddqzdqdzqdqdzqzd zdzqdzqd', 'zdqdqdqzddqzdqdzqdqdzqzd zdzqdzqd'),
(45, 'users', 'UPDATE', '17', '2026-03-02 15:33:32', 'user_photo', '6991c05b884fb.png', '69a59fbcc84a4.png'),
(46, 'users', 'UPDATE', '23', '2026-03-02 19:50:40', 'user_funct_id', '1', '2'),
(47, 'users', 'UPDATE', '3', '2026-03-02 21:55:05', 'user_ban_at', NULL, '3025-03-02 00:00:00'),
(48, 'users', 'UPDATE', '30', '2026-03-02 21:59:30', 'user_ban_at', NULL, '2026-03-17 00:00:00'),
(49, 'users', 'UPDATE', '26', '2026-03-02 21:59:35', 'user_ban_at', NULL, '2026-03-17 00:00:00');

-- --------------------------------------------------------

--
-- Structure de la table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
CREATE TABLE IF NOT EXISTS `jobs` (
  `job_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Jobs ID',
  `job_name` enum('Realisator','Productor','Actor') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`job_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `jobs`
--

INSERT INTO `jobs` (`job_id`, `job_name`) VALUES
(1, 'Realisator'),
(2, 'Productor'),
(3, 'Actor');

-- --------------------------------------------------------

--
-- Structure de la table `liked`
--

DROP TABLE IF EXISTS `liked`;
CREATE TABLE IF NOT EXISTS `liked` (
  `lik_user_id` int UNSIGNED NOT NULL,
  `lik_mov_id` int UNSIGNED DEFAULT NULL,
  `lik_com_id` int UNSIGNED DEFAULT NULL,
  `lik_created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_like_movie` (`lik_user_id`,`lik_mov_id`),
  UNIQUE KEY `uk_like_comment` (`lik_user_id`,`lik_com_id`),
  KEY `FK_com_like` (`lik_com_id`),
  KEY `FK_mov_like` (`lik_mov_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `liked`
--

INSERT INTO `liked` (`lik_user_id`, `lik_mov_id`, `lik_com_id`, `lik_created_at`) VALUES
(1, 13, NULL, '2026-02-15 19:50:38'),
(2, 13, NULL, '2026-02-15 19:50:38'),
(3, 13, NULL, '2026-02-15 19:50:38'),
(4, 13, NULL, '2026-02-15 19:50:38'),
(5, 13, NULL, '2026-02-15 19:50:38'),
(6, 14, NULL, '2026-02-15 19:50:38'),
(7, 14, NULL, '2026-02-15 19:50:38'),
(8, 14, NULL, '2026-02-15 19:50:38'),
(9, 14, NULL, '2026-02-15 19:50:38'),
(10, 14, NULL, '2026-02-15 19:50:38'),
(1, 15, NULL, '2026-02-15 19:50:38'),
(3, 15, NULL, '2026-02-15 19:50:38'),
(5, 15, NULL, '2026-02-15 19:50:38'),
(7, 15, NULL, '2026-02-15 19:50:38'),
(9, 15, NULL, '2026-02-15 19:50:38'),
(2, 16, NULL, '2026-02-15 19:50:38'),
(4, 16, NULL, '2026-02-15 19:50:38'),
(6, 16, NULL, '2026-02-15 19:50:38'),
(8, 16, NULL, '2026-02-15 19:50:38'),
(10, 16, NULL, '2026-02-15 19:50:38'),
(3, 18, NULL, '2026-02-15 19:50:38'),
(4, 18, NULL, '2026-02-15 19:50:38'),
(9, 18, NULL, '2026-02-15 19:50:38'),
(10, 18, NULL, '2026-02-15 19:50:38'),
(23, 18, NULL, '2026-02-15 19:50:38'),
(6, 19, NULL, '2026-02-15 19:50:38'),
(7, 19, NULL, '2026-02-15 19:50:38'),
(1, 19, NULL, '2026-02-15 19:50:38'),
(2, 19, NULL, '2026-02-15 19:50:38'),
(5, 19, NULL, '2026-02-15 19:50:38'),
(2, NULL, 8, '2026-02-15 19:50:38'),
(3, NULL, 8, '2026-02-15 19:50:38'),
(4, NULL, 8, '2026-02-15 19:50:38'),
(1, NULL, 13, '2026-02-15 19:50:38'),
(5, NULL, 13, '2026-02-15 19:50:38'),
(6, NULL, 13, '2026-02-15 19:50:38'),
(7, NULL, 16, '2026-02-15 19:50:38'),
(8, NULL, 16, '2026-02-15 19:50:38'),
(9, NULL, 16, '2026-02-15 19:50:38'),
(4, NULL, 28, '2026-02-15 19:50:38'),
(5, NULL, 28, '2026-02-15 19:50:38'),
(6, NULL, 28, '2026-02-15 19:50:38'),
(17, 14, NULL, '2026-02-22 14:41:07'),
(17, 20, NULL, '2026-03-02 20:53:23'),
(17, NULL, 28, '2026-03-02 20:54:43'),
(17, NULL, 105, '2026-03-03 19:58:59'),
(23, NULL, 18, '2026-03-04 08:03:28');

-- --------------------------------------------------------

--
-- Structure de la table `login_attempts`
--

DROP TABLE IF EXISTS `login_attempts`;
CREATE TABLE IF NOT EXISTS `login_attempts` (
  `attempt_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `attempt_ip` varchar(45) DEFAULT NULL,
  `attempt_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`attempt_id`),
  KEY `index_ip_date` (`attempt_ip`,`attempt_datetime`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `logs_users`
--

DROP TABLE IF EXISTS `logs_users`;
CREATE TABLE IF NOT EXISTS `logs_users` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `log_user_id` int NOT NULL,
  `log_event` varchar(10) DEFAULT NULL,
  `log_ip` varchar(45) NOT NULL,
  `log_agent` text,
  `log_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `logs_users`
--

INSERT INTO `logs_users` (`log_id`, `log_user_id`, `log_event`, `log_ip`, `log_agent`, `log_date`) VALUES
(1, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 10:21:23'),
(2, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 10:22:44'),
(3, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 11:06:54'),
(4, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 11:19:21'),
(5, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 13:02:42'),
(6, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 13:03:00'),
(7, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 13:05:10'),
(8, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 13:15:38'),
(9, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 14:01:52'),
(10, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 14:02:38'),
(11, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 14:11:26'),
(12, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 14:11:36'),
(13, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 14:13:26'),
(14, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 14:13:57'),
(15, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 14:17:58'),
(16, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 14:18:07'),
(17, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 15:27:33'),
(18, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 15:27:39'),
(19, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 15:29:38'),
(20, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 15:29:46'),
(21, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 15:37:57'),
(22, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 15:38:12'),
(23, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 15:38:12'),
(24, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 15:39:02'),
(25, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 15:45:08'),
(26, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 15:48:19'),
(27, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 15:48:40'),
(28, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 15:49:18'),
(29, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 15:49:19'),
(30, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 15:51:53'),
(31, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 15:52:00'),
(32, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 15:52:34'),
(33, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 16:36:27'),
(34, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 19:55:14'),
(35, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 20:35:59'),
(36, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 20:43:58'),
(37, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 21:42:00'),
(38, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-21 21:51:16'),
(39, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-22 10:00:36'),
(40, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-22 12:56:10'),
(41, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-22 14:17:29'),
(42, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-22 17:28:02'),
(43, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 07:47:43'),
(44, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 09:26:22'),
(45, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 09:44:02'),
(46, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 09:54:54'),
(47, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 09:55:20'),
(48, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 09:55:57'),
(49, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 10:15:06'),
(50, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 10:51:32'),
(51, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 12:27:33'),
(52, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 12:41:01'),
(53, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 14:09:11'),
(54, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 15:27:36'),
(55, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 22:40:10'),
(56, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 22:41:25'),
(57, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 19:50:45'),
(58, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 19:53:12'),
(59, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 19:58:28'),
(60, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-26 21:10:06'),
(61, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-27 15:55:24'),
(62, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-27 18:20:18'),
(63, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-27 20:00:32'),
(64, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-28 13:06:43'),
(65, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-28 14:09:45'),
(66, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-28 14:09:51'),
(67, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-28 14:09:53'),
(68, 23, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-28 14:12:48'),
(69, 23, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-28 14:18:38'),
(70, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-28 14:18:46'),
(71, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-28 16:16:00'),
(72, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-28 20:04:58'),
(73, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-28 22:09:34'),
(74, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-28 22:37:52'),
(75, 23, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-01 15:54:01'),
(76, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-02 13:19:50'),
(77, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-02 13:25:42'),
(78, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-02 13:44:20'),
(79, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-02 13:51:09'),
(80, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-02 14:29:57'),
(81, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-02 15:20:57'),
(82, 23, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-02 18:50:45'),
(83, 23, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-02 19:45:51'),
(84, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-02 19:46:04'),
(85, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-02 20:17:47'),
(86, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-02 20:20:21'),
(87, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-03 16:17:44'),
(88, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-03 19:05:46'),
(89, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-03 20:05:58'),
(90, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-03 20:06:04'),
(91, 23, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 07:46:37'),
(92, 23, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 09:26:08'),
(93, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 09:26:23'),
(94, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 09:29:49'),
(95, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 10:22:49'),
(96, 23, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 10:38:19'),
(97, 23, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 10:55:15'),
(98, 17, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 10:55:21'),
(99, 17, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 11:57:12'),
(100, 23, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 12:11:15'),
(101, 23, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 12:11:25'),
(102, 23, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 12:14:50'),
(103, 23, 'LOGOUT', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 12:15:53'),
(104, 23, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 12:15:56');

-- --------------------------------------------------------

--
-- Structure de la table `movies`
--

DROP TABLE IF EXISTS `movies`;
CREATE TABLE IF NOT EXISTS `movies` (
  `mov_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Movie Id',
  `mov_title` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Title of the movie',
  `mov_original_title` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Original title of the movie',
  `mov_length` time NOT NULL COMMENT 'Movie length',
  `mov_description` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Description',
  `mov_release_date` date NOT NULL COMMENT 'Release date',
  `mov_nat_id` int UNSIGNED DEFAULT NULL,
  `mov_trailer_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `mov_published_at` datetime DEFAULT NULL,
  `mov_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`mov_id`),
  KEY `fk_movies_nationality` (`mov_nat_id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `movies`
--

INSERT INTO `movies` (`mov_id`, `mov_title`, `mov_original_title`, `mov_length`, `mov_description`, `mov_release_date`, `mov_nat_id`, `mov_trailer_url`, `mov_published_at`, `mov_updated_at`) VALUES
(13, 'Orange Mécanique', 'A Clockwork Orange', '02:16:00', 'Dans un futur dystopique, un chef de gang sadique est soumis à une expérience de réhabilitation.', '1971-12-19', 3, 'https://www.youtube.com/watch?v=T54uZPI4Z8A', '2026-02-28 17:14:23', NULL),
(14, 'Full Metal Jacket', 'Full Metal Jacket', '01:56:00', 'Le parcours de jeunes marines américains, de l\'entraînement brutal à la guerre du Vietnam.', '1987-06-26', 2, 'https://www.google.com/search?q=trailer+full+metal+jacket&rlz=1C1VDKB_frFR1102FR1102&oq=trailer+full+metal+jacket&gs_lcrp=EgZjaHJvbWUyBggAEEUYOTIICAEQABgWGB4yCAgCEAAYFhgeMggIAxAAGBYYHjIICAQQABgWGB4yCAgFEAAYFhgeMggIBhAAGBYYHjIICAcQABgWGB4yCAgIEAAYFhgeMggIC', '2026-02-28 17:14:23', NULL),
(15, 'Eyes Wide Shut', 'Eyes Wide Shut', '02:39:00', 'Un médecin new-yorkais s\'aventure dans une odyssée nocturne étrange et érotique.', '1999-07-16', 2, 'https://www.google.com/search?q=trailer+eyes+wide+shut&sca_esv=f9558c3169decf9e&rlz=1C1VDKB_frFR1102FR1102&sxsrf=ANbL-n5RN_Qb7MwyMR5AJXafxA7vtNqRZA%3A1768731365994&ei=5bJsadC6PPWpkdUPk8Xh4QY&oq=trailer+eyes&gs_lp=Egxnd3Mtd2l6LXNlcnAiDHRyYWlsZXIgZXllcyoCCA', '2026-02-28 17:14:23', NULL),
(16, 'Mulholland Drive', 'Mulholland Dr.', '02:27:00', 'Une femme amnésique et une aspirante actrice enquêtent dans un Los Angeles onirique.', '2001-10-12', 2, 'https://www.youtube.com/watch?v=91kRgjELBek', '2026-02-28 17:14:23', NULL),
(18, 'Eraserhead', 'Eraserhead', '01:29:00', 'Henry Spencer tente de survivre dans son environnement industriel avec sa petite amie et leur enfant mutant.', '1977-03-19', 2, 'https://www.youtube.com/watch?v=oK-2_OsBe0s', '2026-02-28 17:14:23', NULL),
(19, 'Elephant Man', 'The Elephant Man', '02:04:00', 'Un chirurgien victorien sauve un homme gravement défiguré, exploité comme un monstre de foire.', '1980-10-03', 2, 'https://www.youtube.com/watch?v=AF9gNKJi79g', '2026-02-28 17:14:23', NULL),
(20, 'Lost Highway', 'Lost Highway', '02:14:00', 'Après une rencontre bizarroïde lors d\'une fête, un saxophoniste est accusé du meurtre de sa femme.', '1997-02-21', 2, 'https://www.youtube.com/watch?v=8-1pcMvy5qc', '2026-02-28 17:14:23', NULL),
(21, 'Avatar: Fire and Ash', 'Avatar: Fire and Ash', '03:11:00', 'Jake Sully et Neytiri affrontent un nouveau clan de Na\'vi lié au feu dans une région volcanique de Pandora.', '2026-01-07', 2, 'https://www.youtube.com/watch?v=nb_fFj_0rq8', '2026-02-28 17:14:23', '2026-03-04 10:26:35'),
(22, 'M3GAN 2.0', 'M3GAN 2.0', '01:42:00', 'L\'intelligence artificielle meurtrière est de retour dans une version plus évoluée et plus dangereuse.', '2026-01-14', 2, 'https://www.youtube.com/watch?v=I0VWWnMUjFU', '2026-02-28 17:14:23', NULL),
(24, 'Paddington au Pérou', 'Paddington in Peru', '01:43:00', 'Paddington retourne au Pérou pour rendre visite à sa tante Lucy, entraînant les Brown dans une aventure épique.', '2026-01-07', 3, 'https://www.youtube.com/watch?v=Fp-1L1KOIk8', '2026-02-28 17:14:23', NULL),
(25, 'The Drama', 'The Drama', '02:05:00', 'Une crise inattendue survient dans la vie d\'un couple à la veille de leur mariage.', '2026-01-30', 2, 'https://www.google.com/search?q=trailer+the+drama&rlz=1C1VDKB_frFR1102FR1102&sca_esv=f9558c3169decf9e&sxsrf=ANbL-n40rc4yxeDI2p-TpaTEP3S6ZfVrTA%3A1768731399284&ei=B7Nsaf6EEeDCnsEP7fu26QI&ved=0ahUKEwi-pIf27ZSSAxVgoScCHe29LS0Q4dUDCBE&uact=5&oq=trailer+the+dr', '2026-02-28 17:14:23', NULL),
(32, 'Marsupilami', 'Marsupilami', '01:39:00', 'Pour sauver son emploi, David accepte un plan foireux : ramener un mystérieux colis d’Amérique du Sud. Il se retrouve à bord d’une croisière avec son ex Tess, son fils Léo, et son collègue Stéphane, aussi benêt que maladroit, dont David se sert pour transporter le colis à sa place. Tout dérape lorsque ce dernier l’ouvre accidentellement : un adorable bébé Marsupilami apparait et le voyage vire au chaos !', '2026-03-05', 1, 'https://www.allocine.fr/video/player_gen_cmedia=20630202&cfilm=317669.html', '2026-03-02 21:24:43', NULL);

--
-- Déclencheurs `movies`
--
DROP TRIGGER IF EXISTS `after_insert_movies`;
DELIMITER $$
CREATE TRIGGER `after_insert_movies` AFTER INSERT ON `movies` FOR EACH ROW INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date)
VALUES ('movies', 'DELETE', NEW.mov_id, NOW())
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `after_update_movies`;
DELIMITER $$
CREATE TRIGGER `after_update_movies` AFTER UPDATE ON `movies` FOR EACH ROW BEGIN 
	IF OLD.mov_title != NEW.mov_title THEN
        INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue)
        VALUES ('movies', 'UPDATE', NEW.mov_id, NOW(), 'mov_title', OLD.mov_title, NEW.mov_title);
    END IF;

    
    IF OLD.mov_original_title != NEW.mov_original_title THEN
        INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue)
        VALUES ('movies', 'UPDATE', NEW.mov_id, NOW(), 'mov_original_title', OLD.mov_original_title, NEW.mov_original_title);
    END IF;

    
    IF OLD.mov_length != NEW.mov_length THEN
        INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue)
        VALUES ('movies', 'UPDATE', NEW.mov_id, NOW(), 'mov_length', OLD.mov_length, NEW.mov_length);
    END IF;

    -- Historisation de mov_description
    IF OLD.mov_description != NEW.mov_description THEN
        INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue)
        VALUES ('movies', 'UPDATE', NEW.mov_id, NOW(), 'mov_description', OLD.mov_description, NEW.mov_description);
    END IF;

   
    IF OLD.mov_release_date != NEW.mov_release_date THEN
        INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue)
        VALUES ('movies', 'UPDATE', NEW.mov_id, NOW(), 'mov_release_date', OLD.mov_release_date, NEW.mov_release_date);
    END IF;

    
    IF OLD.mov_trailer_url != NEW.mov_trailer_url THEN
        INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue)
       	VALUES ('movies', 'UPDATE', NEW.mov_id, NOW(), 'mov_trailer_url', OLD.mov_trailer_url, NEW.mov_trailer_url);
    END IF;

END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `before_delete_movies`;
DELIMITER $$
CREATE TRIGGER `before_delete_movies` BEFORE DELETE ON `movies` FOR EACH ROW INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date)
VALUES ('movies', 'DELETE', OLD.mov_id, NOW())
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `nationalities`
--

DROP TABLE IF EXISTS `nationalities`;
CREATE TABLE IF NOT EXISTS `nationalities` (
  `nat_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Nationalities ID',
  `nat_country` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Country name',
  PRIMARY KEY (`nat_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `nationalities`
--

INSERT INTO `nationalities` (`nat_id`, `nat_country`) VALUES
(1, 'France'),
(2, 'États-Unis'),
(3, 'Royaume-Uni'),
(4, 'Allemagne'),
(5, 'Italie'),
(6, 'Espagne'),
(7, 'Japon'),
(8, 'Canada'),
(9, 'Australie'),
(10, 'Brésil');

-- --------------------------------------------------------

--
-- Structure de la table `participates`
--

DROP TABLE IF EXISTS `participates`;
CREATE TABLE IF NOT EXISTS `participates` (
  `part_pers_id` int UNSIGNED NOT NULL,
  `part_job_id` int UNSIGNED NOT NULL,
  `part_mov_id` int UNSIGNED NOT NULL,
  `part_character_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`part_pers_id`,`part_job_id`,`part_mov_id`),
  KEY `fk_part_job_id` (`part_job_id`),
  KEY `fk_part_mov_id` (`part_mov_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `participates`
--

INSERT INTO `participates` (`part_pers_id`, `part_job_id`, `part_mov_id`, `part_character_name`) VALUES
(3, 2, 15, NULL),
(3, 2, 19, NULL),
(4, 1, 20, NULL),
(4, 2, 16, NULL),
(4, 2, 24, NULL),
(5, 1, 16, NULL),
(5, 1, 24, NULL),
(5, 2, 20, NULL),
(6, 1, 13, NULL),
(6, 1, 25, NULL),
(6, 3, 21, NULL),
(7, 1, 21, NULL),
(7, 2, 25, NULL),
(7, 3, 13, NULL),
(8, 2, 13, NULL),
(8, 2, 21, NULL),
(8, 3, 25, NULL),
(9, 1, 14, NULL),
(9, 1, 22, NULL),
(9, 2, 18, NULL),
(10, 1, 18, NULL),
(10, 2, 14, NULL),
(10, 3, 22, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `persons`
--

DROP TABLE IF EXISTS `persons`;
CREATE TABLE IF NOT EXISTS `persons` (
  `pers_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Person ID',
  `pers_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Person name',
  `pers_firstname` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Person firstname',
  `pers_birthdate` date NOT NULL COMMENT 'Person birth date',
  `pers_deathdate` date DEFAULT NULL COMMENT 'person death date',
  `pers_nat_id` int UNSIGNED DEFAULT NULL,
  `pers_bio` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Person biography',
  `pers_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Person photo URL',
  `pers_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`pers_id`),
  KEY `fk_pers_nat_id` (`pers_nat_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `persons`
--

INSERT INTO `persons` (`pers_id`, `pers_name`, `pers_firstname`, `pers_birthdate`, `pers_deathdate`, `pers_nat_id`, `pers_bio`, `pers_photo`, `pers_updated_at`) VALUES
(3, 'Clarke', 'Arthur C.', '1917-12-16', '2008-03-19', 3, 'Stanley Kubrick est un réalisateur, scénariste et producteur américain, connu pour ses films cultes et son perfectionnisme extrême.', '69a5e69d9b550.webp', NULL),
(4, 'Nicholson', 'Jack', '1937-04-22', '0000-00-00', 4, 'David Lynch est un réalisateur, scénariste et artiste américain, connu pour son cinéma étrange et onirique, mêlant mystère, rêve et inquiétante étrangeté.', '69a5e7d22ca6e.webp', NULL),
(5, 'McDowell', 'Malcolm', '1943-06-13', '0000-00-00', 5, 'David Lynch est un réalisateur, scénariste et artiste américain, connu pour son cinéma étrange et onirique, mêlant mystère, rêve et inquiétante étrangeté.', '69a5e82ee52dc.webp', NULL),
(6, 'Ermey', 'R. Lee', '1944-03-24', '2018-04-15', 6, 'David Lynch est un réalisateur, scénariste et artiste américain, connu pour son cinéma étrange et onirique, mêlant mystère, rêve et inquiétante étrangeté.', '69a5e88781bea.webp', NULL),
(7, 'Kidman', 'Nicole', '1967-06-20', '0000-00-00', 7, 'David Lynch est un réalisateur, scénariste et artiste américain, connu pour son cinéma étrange et onirique, mêlant mystère, rêve et inquiétante étrangeté.', '69a5e84c31ead.webp', NULL),
(8, 'Nance', 'Jack', '1943-12-21', '1996-12-30', 8, 'Stanley Kubrick est un réalisateur, scénariste et producteur américain, connu pour ses films cultes et son perfectionnisme extrême.', '69a5e7494b4fe.webp', NULL),
(9, 'Hurt', 'John', '1940-01-22', '2017-01-25', 9, 'Stanley Kubrick est un réalisateur, scénariste et producteur américain, connu pour ses films cultes et son perfectionnisme extrême.', '69a5e7ff4462f.webp', NULL),
(10, 'MacLachlan', 'Kyle', '1959-02-22', '0000-00-00', 10, 'Stanley Kubrick est un réalisateur, scénariste et producteur américain, connu pour ses films cultes et son perfectionnisme extrême.', '69a5e81b6d268.webp', NULL);

--
-- Déclencheurs `persons`
--
DROP TRIGGER IF EXISTS `after_insert_persons`;
DELIMITER $$
CREATE TRIGGER `after_insert_persons` AFTER INSERT ON `persons` FOR EACH ROW INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date)
VALUES ('persons', 'INSERT', NEW.pers_id, NOW())
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `after_update_persons`;
DELIMITER $$
CREATE TRIGGER `after_update_persons` AFTER UPDATE ON `persons` FOR EACH ROW BEGIN 

    IF OLD.pers_name != NEW.pers_name THEN
        INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue)
        VALUES ('persons', 'UPDATE', NEW.pers_id, NOW(), 'pers_name', OLD.pers_name, NEW.pers_name);
    END IF;

    IF OLD.pers_firstname != NEW.pers_firstname THEN
        INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue)
        VALUES ('persons', 'UPDATE', NEW.pers_id, NOW(), 'pers_firstname', OLD.pers_firstname, NEW.pers_firstname);
    END IF;

    IF OLD.pers_birthdate != NEW.pers_birthdate THEN
        INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue)
        VALUES ('persons', 'UPDATE', NEW.pers_id, NOW(), 'pers_birthdate', OLD.pers_birthdate, NEW.pers_birthdate);
    END IF;

    IF (NEW.pers_deathdate <=> OLD.pers_deathdate) THEN
        INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue)
        VALUES ('persons', 'UPDATE', NEW.pers_id, NOW(), 'pers_deathdate', OLD.pers_deathdate, NEW.pers_deathdate);
    END IF;

    IF OLD.pers_bio != NEW.pers_bio THEN
        INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue)
        VALUES ('persons', 'UPDATE', NEW.pers_id, NOW(), 'pers_bio', OLD.pers_bio, NEW.pers_bio);
    END IF;

    IF OLD.pers_photo != NEW.pers_photo THEN
        INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue)
        VALUES ('persons', 'UPDATE', NEW.pers_id, NOW(), 'pers_photo', OLD.pers_photo, NEW.pers_photo);
    END IF;

END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `before_delete_persons`;
DELIMITER $$
CREATE TRIGGER `before_delete_persons` BEFORE DELETE ON `persons` FOR EACH ROW INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date)
VALUES ('persons', 'DELETE', OLD.pers_id, NOW())
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `photos`
--

DROP TABLE IF EXISTS `photos`;
CREATE TABLE IF NOT EXISTS `photos` (
  `pho_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Photo ID',
  `pho_photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Photo URL',
  `pho_type` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Type of file',
  `pho_mov_id` int UNSIGNED DEFAULT NULL,
  `pho_user_id` int UNSIGNED DEFAULT NULL,
  `pho_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`pho_id`),
  UNIQUE KEY `uk_mov_user_id` (`pho_mov_id`,`pho_user_id`),
  KEY `fk_pho_mov_id` (`pho_mov_id`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `photos`
--

INSERT INTO `photos` (`pho_id`, `pho_photo`, `pho_type`, `pho_mov_id`, `pho_user_id`, `pho_updated_at`) VALUES
(3, '69a5e7e37fc0b.webp', 'Affiche', 13, NULL, NULL),
(4, '699b1f71abdce.webp', 'Affiche', 14, NULL, NULL),
(5, '69a5e3dd79e0b.webp', 'Affiche', 15, NULL, NULL),
(6, '69a5e426104c2.webp', 'Affiche', 16, NULL, NULL),
(8, '69a5e3b090632.webp', 'Affiche', 18, NULL, NULL),
(9, '69a5e26e3598d.webp', 'Affiche', 19, NULL, NULL),
(10, '69a5e72eb9a5f.webp', 'Affiche', 20, NULL, NULL),
(11, '6999936d5b186.webp', 'Affiche', 21, NULL, NULL),
(12, '69a5e4019c6ad.webp', 'Affiche', 22, NULL, NULL),
(14, '69a5e45a26090.webp', 'Affiche', 24, NULL, NULL),
(15, '69a5e8a206cb9.webp', 'Affiche', 25, NULL, NULL),
(50, '69a5f246c105e.webp', 'Affiche', 32, NULL, NULL),
(51, '69a7311b81da0.png', 'Content', 32, 17, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `ratings`
--

DROP TABLE IF EXISTS `ratings`;
CREATE TABLE IF NOT EXISTS `ratings` (
  `rat_user_id` int UNSIGNED NOT NULL,
  `rat_mov_id` int UNSIGNED NOT NULL,
  `rat_score` decimal(2,1) NOT NULL,
  PRIMARY KEY (`rat_user_id`,`rat_mov_id`),
  KEY `fk_ratings_movies` (`rat_mov_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `ratings`
--

INSERT INTO `ratings` (`rat_user_id`, `rat_mov_id`, `rat_score`) VALUES
(1, 15, 4.3),
(1, 16, 5.0),
(1, 22, 4.5),
(2, 13, 4.0),
(2, 14, 4.3),
(2, 16, 4.3),
(2, 20, 4.3),
(2, 21, 2.0),
(3, 13, 5.0),
(3, 18, 4.0),
(4, 13, 4.3),
(4, 14, 4.0),
(4, 19, 5.0),
(4, 20, 4.0),
(4, 24, 3.0),
(5, 13, 3.0),
(5, 14, 5.0),
(5, 15, 3.5),
(5, 16, 4.5),
(5, 19, 3.0),
(5, 20, 4.5),
(5, 21, 2.0),
(5, 22, 5.0),
(5, 24, 4.0),
(5, 25, 3.0),
(6, 16, 3.0),
(6, 25, 3.0),
(7, 13, 2.0),
(7, 19, 4.3),
(7, 22, 3.0),
(8, 18, 4.3),
(8, 19, 5.0),
(9, 14, 5.0),
(9, 16, 5.0),
(9, 18, 5.0),
(10, 13, 3.0),
(10, 14, 4.0),
(10, 15, 2.0),
(10, 16, 4.5),
(10, 19, 2.5),
(10, 20, 4.0),
(10, 21, 3.0),
(10, 22, 4.5),
(10, 24, 2.0),
(10, 25, 4.5),
(17, 14, 2.5),
(17, 15, 4.0),
(17, 21, 5.0),
(17, 25, 4.5),
(17, 32, 5.0),
(23, 18, 5.0),
(23, 21, 2.0),
(23, 25, 4.0),
(23, 32, 0.5);

-- --------------------------------------------------------

--
-- Structure de la table `reports`
--

DROP TABLE IF EXISTS `reports`;
CREATE TABLE IF NOT EXISTS `reports` (
  `rep_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `rep_reported_user_id` int UNSIGNED DEFAULT NULL,
  `rep_reported_movie_id` int UNSIGNED DEFAULT NULL,
  `rep_reported_com_id` int UNSIGNED DEFAULT NULL,
  `rep_com_content` text COLLATE utf8mb4_unicode_ci,
  `rep_pseudo_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rep_bio_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rep_date` datetime DEFAULT NULL,
  `rep_reporter_user_id` int UNSIGNED DEFAULT NULL,
  `rep_reason` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rep_deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`rep_id`),
  KEY `fk_rep_reported_user` (`rep_reported_user_id`),
  KEY `fk_rep_reported_mov` (`rep_reported_movie_id`),
  KEY `fk_rep_reported_com` (`rep_reported_com_id`)
) ENGINE=InnoDB AUTO_INCREMENT=95 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `reports`
--

INSERT INTO `reports` (`rep_id`, `rep_reported_user_id`, `rep_reported_movie_id`, `rep_reported_com_id`, `rep_com_content`, `rep_pseudo_user`, `rep_bio_user`, `rep_date`, `rep_reporter_user_id`, `rep_reason`, `rep_deleted_at`) VALUES
(36, 5, NULL, NULL, NULL, 'keke_99', '', '2026-02-14 18:09:30', 25, 'test', '2026-02-21 21:09:38'),
(85, NULL, 21, NULL, NULL, NULL, NULL, '2026-02-25 21:38:37', 17, 'dqzdzdqd', '2026-03-04 09:33:58'),
(87, NULL, 25, NULL, NULL, NULL, NULL, '2026-03-02 15:39:00', 17, 'dqdqzdqz', '2026-03-04 09:33:59'),
(89, 30, NULL, NULL, NULL, 'dzqdqzdzqdzqdq', '', '2026-03-02 21:55:19', 17, 'test ban', '2026-03-02 21:59:37'),
(90, 26, NULL, NULL, NULL, 'Testdzqdzq', '', '2026-03-02 21:59:14', 17, 'dqzdzqd', '2026-03-02 21:59:38');

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'User ID',
  `user_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'User name',
  `user_firstname` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'User first name',
  `user_pseudo` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'User pseudo',
  `user_email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'User email',
  `user_birthdate` date NOT NULL COMMENT 'User Birthdate',
  `user_creadate` datetime NOT NULL COMMENT 'User accounts creation date',
  `user_funct_id` int UNSIGNED DEFAULT '1',
  `user_bio` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User biography',
  `user_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User profile photo URL',
  `user_pwd` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_deleted_at` datetime DEFAULT NULL,
  `user_updated_at` datetime DEFAULT NULL,
  `user_ban_at` datetime DEFAULT NULL,
  `user_reason_ban` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_reset_token` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_reset_expires` datetime DEFAULT NULL,
  `user_reset_at` datetime DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `unique_email` (`user_email`),
  UNIQUE KEY `unique_pseudo` (`user_pseudo`),
  KEY `fk_user_funct_id` (`user_funct_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`user_id`, `user_name`, `user_firstname`, `user_pseudo`, `user_email`, `user_birthdate`, `user_creadate`, `user_funct_id`, `user_bio`, `user_photo`, `user_pwd`, `user_deleted_at`, `user_updated_at`, `user_ban_at`, `user_reason_ban`, `user_reset_token`, `user_reset_expires`, `user_reset_at`) VALUES
(1, 'Dubois', 'Thomas', 'tom_dubois', 'thomas.dubois@exemple.com', '1990-05-15', '2024-01-10 09:00:00', 3, NULL, NULL, '', '2026-02-07 16:32:25', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 'Leroy', 'Marie', 'mary_l', 'marie.leroy@exemple.com', '1985-11-20', '2024-01-12 10:30:00', 2, NULL, NULL, '', '2026-02-10 17:04:20', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 'Martin', 'Lucas', '', 'lucas.martin@exemple.com', '1998-03-08', '2024-01-15 14:15:00', 2, NULL, NULL, '', '2026-02-11 18:12:50', NULL, '3025-03-02 00:00:00', 'dzqdzq', NULL, NULL, NULL),
(4, 'Bernard', 'Sophie', 'sophie_b', 'sophie.bernard@exemple.com', '1992-07-22', '2024-02-01 11:00:00', 2, NULL, NULL, '', NULL, NULL, '2026-02-20 00:00:00', 'dzqdzqdqzdqzdqz', NULL, NULL, NULL),
(5, 'Petit', 'Kevin', 'keke_99', 'kevin.petit@exemple.com', '1999-12-01', '2024-02-10 16:45:00', 2, NULL, NULL, '', NULL, NULL, NULL, 'Parce que!', NULL, NULL, NULL),
(6, 'Robert', 'Camille', 'cam_rob', 'camille.robert@exemple.com', '1995-09-14', '2024-02-20 08:20:00', 1, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(7, 'Richard', 'Antoinedzqdqz', 'tony_ric', 'antoine.richard@exemple.com', '1988-02-28', '2024-03-05 13:10:00', 3, '', 'defaultImgUser.jpg', '', NULL, '2026-02-19 22:34:05', NULL, NULL, NULL, NULL, NULL),
(8, 'Durand', 'Léa', 'lele_d', 'lea.durand@exemple.com', '2001-06-30', '2024-03-12 18:00:00', 1, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(9, 'Moreau', 'Nathan', 'nate_m', 'nathan.moreau@exemple.com', '1993-04-10', '2024-03-25 09:45:00', 1, NULL, NULL, '', NULL, NULL, NULL, 'e édqdzq', NULL, NULL, NULL),
(10, 'Simon', 'Sarah', 's_simon', 'sarah.simon@exemple.com', '1982-08-05', '2024-04-01 12:00:00', 1, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(17, 'MARCO', 'Marco', 'Testzzzzzzzz', 'slendsher48@gmail.com', '2006-03-22', '2026-02-05 15:50:29', 3, 'zdqdqdqzddqzdqdzqdqdzqzd zdzqdzqd', '69a59fbcc84a4.png', '$2y$12$zRjrT2Pcs1Lfn6jhd0Z6guipp3vIph5ZdgGF4dybhQp35RiTst6HO', NULL, '2026-03-02 15:33:32', NULL, NULL, '4f8c7a804b1127776714a58a808d9de6f5b7f397252f6feda9b3292b063db3abbd2e9a2bf4bbf3697e4367e25763274a2fb422759d2c71fa23c7f4efd72ed1d5', '2026-02-28 15:41:45', NULL),
(23, 'SCHMITT', 'MARCO', 'Truc', 'marco06.marco06@gmail.com', '2222-02-22', '2026-02-08 15:12:38', 2, '', '69a46168ac5d7.png', '$2y$10$ZWiLqzPoxwvP5KSCRW.Ac.VDgw41CLBalyfmtQ3jolT062c78.M2W', NULL, '2026-03-01 16:55:20', NULL, NULL, 'a25e81964f79dd3714daad73dfde4c77268633209ff2f78408b6a2250a4a5a2ed6d53243ece3862b68a3a48d5bc07094f09f4aa2ecd104c60f5d6028d0dbdc02', '2026-03-04 12:01:47', NULL),
(24, 'SCHMITT', 'MARCOOOOOOO', 'marcoooo', 'test@gmail.com', '2222-02-22', '2026-02-09 08:55:06', 2, '', '698b57ac34581.png', '$2y$10$QtZit0YtsMgqojOEnlsi6eQcph6yTiI.RuxXqRNI29ZlTXpMPoc6a', NULL, '2026-02-20 22:11:38', NULL, 'parceque', NULL, NULL, NULL),
(25, 'dqzzdq', 'dzqdzq', 'user', 'user@gmail.com', '2222-02-22', '2026-02-13 11:12:08', 1, NULL, NULL, '$2y$12$VMEuNAGgcYnmr13mM7Sy3.naxE/pgFRbal1ujYj6hsHKF.nEUAz8G', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(26, 'dzqdzq', 'dzqdqz', 'Testdzqdzq', 'zaezaedzqd@gmail.com', '2222-02-22', '2026-02-20 08:33:57', 1, NULL, NULL, '$2y$10$D0EWAzxywtwK7iv6wdBn0.Q62/fr4fUtHMhMhtZpOG30JCLPmJEU2', NULL, NULL, '2026-03-17 00:00:00', 'parce que', NULL, NULL, NULL),
(27, 'SCHMITT', 'MARCO', 'Testdzqdzqddddddddddddd', 'slendsher67@gmail.com', '2006-03-22', '2026-02-24 10:30:22', 1, NULL, NULL, '$2y$10$tVH9f3eInanq5vMiLL15f.FDbcq3fd9tvLgKOpjxQiRiBw9UkT82K', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(28, 'SCHMITT', 'MARCO', 'Testdzqdzqddddddddddddddzqdqzdzqdzqdz', 'slensdsher67@gmail.com', '2006-03-22', '2026-02-24 10:37:56', 1, NULL, NULL, '$2y$10$LqOWxt80Vpbz1u5aw87nu.KN5zaDBWuwwU4zOamaNYn5LofXFgZmy', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(29, 'SCHMITT', 'MARCO', 'Trucdzqdzq', 'marco06.mdzqdarco06@gmail.com', '2006-03-22', '2026-02-24 10:39:24', 1, NULL, NULL, '$2y$10$oal4chUiaE/x4xdlqdc55u6v2JpvGnfhig6cPnvV3m0gevdsKu9n2', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(30, 'dqzdzq', 'dzqdqzdq', 'dzqdqzdzqdzqdq', 'mdzqdqzdqzo06@gmail.com', '2032-09-28', '2026-02-25 20:28:16', 1, NULL, NULL, '$2y$10$2iEaM1R15HfcSQqrTGn9DeMd0wC3j3y7n5rFH2WJDxXF0TbjEGzEi', NULL, NULL, '2026-03-17 00:00:00', 'parce que', NULL, NULL, NULL),
(31, 'dzqdqzdzqdzq', 'ddqdzqdqzdq', 'zdqzdqzdq', 'dadadqdzqdzqo06@gmail.com', '3022-12-11', '2026-02-25 20:32:07', 1, NULL, NULL, '$2y$10$8VpzK6yfS07bj79y7tYBMu0yBGVT3d/5qB8Ys9/38DjjTNOcwhiNa', NULL, NULL, NULL, NULL, NULL, NULL, NULL);

--
-- Déclencheurs `users`
--
DROP TRIGGER IF EXISTS `after_insert_user`;
DELIMITER $$
CREATE TRIGGER `after_insert_user` AFTER INSERT ON `users` FOR EACH ROW INSERT INTO history_users (hist_table, hist_event, hist_elementid, hist_date)
    VALUES('users', 'INSERT', NEW.user_id, NOW())
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `after_update_user`;
DELIMITER $$
CREATE TRIGGER `after_update_user` AFTER UPDATE ON `users` FOR EACH ROW BEGIN
	IF NEW.user_name != OLD.user_name THEN
        INSERT INTO history_users (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue)
        VALUES('users', 'UPDATE', NEW.user_id, NOW(), 'user_name', OLD.user_name, NEW.user_name);
    END IF;
    
    IF NEW.user_firstname != OLD.user_firstname THEN
        INSERT INTO history_users (hist_table, hist_event, hist_elementid, hist_field, hist_oldvalue, hist_newvalue, hist_date)
        VALUES('users', 'UPDATE', NEW.user_id, 'user_firstname', OLD.user_firstname, NEW.user_firstname, NOW());
    END IF;

   
    IF NEW.user_pseudo != OLD.user_pseudo THEN
        INSERT INTO history_users (hist_table, hist_event, hist_elementid, hist_field, hist_oldvalue, hist_newvalue, hist_date)
        VALUES('users', 'UPDATE', NEW.user_id, 'user_pseudo', OLD.user_pseudo, NEW.user_pseudo, NOW());
    END IF;

   
    IF NEW.user_email != OLD.user_email THEN
        INSERT INTO history_users (hist_table, hist_event, hist_elementid, hist_field, hist_oldvalue, hist_newvalue, hist_date)
        VALUES('users', 'UPDATE', NEW.user_id, 'user_email', OLD.user_email, NEW.user_email, NOW());
    END IF;
    
    IF NEW.user_bio != OLD.user_bio THEN
        INSERT INTO history_users (hist_table, hist_event, hist_elementid, hist_field, hist_oldvalue, hist_newvalue, hist_date)
        VALUES('users', 'UPDATE', NEW.user_id, 'user_bio', OLD.user_bio, NEW.user_bio, NOW());
    END IF;

    IF NEW.user_pwd != OLD.user_pwd THEN
        INSERT INTO history_users (hist_table, hist_event, hist_elementid, hist_field, hist_oldvalue, hist_newvalue, hist_date)
        VALUES('users', 'UPDATE', NEW.user_id, 'user_pwd', OLD.user_pwd, NEW.user_pwd, NOW());
    END IF;
   
    IF NEW.user_funct_id != OLD.user_funct_id THEN
        INSERT INTO history_users (hist_table, hist_event, hist_elementid, hist_field, hist_oldvalue, hist_newvalue, hist_date)
        VALUES('users', 'UPDATE', NEW.user_id, 'user_funct_id', OLD.user_funct_id, NEW.user_funct_id, NOW());
    END IF;
    
    IF NEW.user_photo != OLD.user_photo THEN
        INSERT INTO history_users (hist_table, hist_event, hist_elementid, hist_field, hist_oldvalue, hist_newvalue, hist_date)
        VALUES('users', 'UPDATE', NEW.user_id, 'user_photo', OLD.user_photo, NEW.user_photo, NOW());
    END IF;

   
    IF NEW.user_birthdate != OLD.user_birthdate THEN
        INSERT INTO history_users (hist_table, hist_event, hist_elementid, hist_field, hist_oldvalue, hist_newvalue, hist_date)
        VALUES('users', 'UPDATE', NEW.user_id, 'user_birthdate', OLD.user_birthdate, NEW.user_birthdate, NOW());
    END IF;

    IF NOT (NEW.user_ban_at <=> OLD.user_ban_at) THEN
        INSERT INTO history_users (hist_table, hist_event, hist_elementid, hist_field, hist_oldvalue, hist_newvalue, hist_date)
        VALUES('users', 'UPDATE', NEW.user_id, 'user_ban_at', OLD.user_ban_at, NEW.user_ban_at, NOW());
    END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `before_delete_user`;
DELIMITER $$
CREATE TRIGGER `before_delete_user` BEFORE DELETE ON `users` FOR EACH ROW INSERT INTO history_users (hist_table, hist_event, hist_elementid, hist_date)
    VALUES('users', 'DELETE', OLD.user_id, NOW())
$$
DELIMITER ;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `belongs`
--
ALTER TABLE `belongs`
  ADD CONSTRAINT `fk_belong_cat_id` FOREIGN KEY (`belong_cat_id`) REFERENCES `categories` (`cat_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_belong_mov_id` FOREIGN KEY (`belong_mov_id`) REFERENCES `movies` (`mov_id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `comments`
--
ALTER TABLE `comments`
  ADD CONSTRAINT `fk_com_movie_id` FOREIGN KEY (`com_movie_id`) REFERENCES `movies` (`mov_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_com_user_id` FOREIGN KEY (`com_user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `liked`
--
ALTER TABLE `liked`
  ADD CONSTRAINT `FK_com_like` FOREIGN KEY (`lik_com_id`) REFERENCES `comments` (`com_id`),
  ADD CONSTRAINT `FK_mov_like` FOREIGN KEY (`lik_mov_id`) REFERENCES `movies` (`mov_id`),
  ADD CONSTRAINT `FK_user_like` FOREIGN KEY (`lik_user_id`) REFERENCES `users` (`user_id`);

--
-- Contraintes pour la table `movies`
--
ALTER TABLE `movies`
  ADD CONSTRAINT `fk_movies_nationality` FOREIGN KEY (`mov_nat_id`) REFERENCES `nationalities` (`nat_id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `participates`
--
ALTER TABLE `participates`
  ADD CONSTRAINT `fk_part_job_id` FOREIGN KEY (`part_job_id`) REFERENCES `jobs` (`job_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_part_mov_id` FOREIGN KEY (`part_mov_id`) REFERENCES `movies` (`mov_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_part_pers_id` FOREIGN KEY (`part_pers_id`) REFERENCES `persons` (`pers_id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `persons`
--
ALTER TABLE `persons`
  ADD CONSTRAINT `fk_pers_nat_id` FOREIGN KEY (`pers_nat_id`) REFERENCES `nationalities` (`nat_id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `photos`
--
ALTER TABLE `photos`
  ADD CONSTRAINT `fk_pho_mov_id` FOREIGN KEY (`pho_mov_id`) REFERENCES `movies` (`mov_id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `ratings`
--
ALTER TABLE `ratings`
  ADD CONSTRAINT `FK_rat_mov` FOREIGN KEY (`rat_mov_id`) REFERENCES `movies` (`mov_id`),
  ADD CONSTRAINT `FK_rat_user` FOREIGN KEY (`rat_user_id`) REFERENCES `users` (`user_id`);

--
-- Contraintes pour la table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `fk_rep_mov` FOREIGN KEY (`rep_reported_movie_id`) REFERENCES `movies` (`mov_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rep_reported_com` FOREIGN KEY (`rep_reported_com_id`) REFERENCES `comments` (`com_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rep_reported_mov` FOREIGN KEY (`rep_reported_movie_id`) REFERENCES `movies` (`mov_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rep_reported_user` FOREIGN KEY (`rep_reported_user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rep_user` FOREIGN KEY (`rep_reported_user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_reported_mov` FOREIGN KEY (`rep_reported_movie_id`) REFERENCES `movies` (`mov_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_reported_user` FOREIGN KEY (`rep_reported_user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_user_funct_id` FOREIGN KEY (`user_funct_id`) REFERENCES `functions` (`funct_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
