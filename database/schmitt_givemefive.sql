-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost:3306
-- Généré le : jeu. 05 mars 2026 à 16:20
-- Version du serveur : 11.4.10-MariaDB
-- Version de PHP : 8.3.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `schmitt_givemefive`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`schmitt`@`localhost` PROCEDURE `auto_ban_users` (IN `id` INT, IN `reason` VARCHAR(255))   BEGIN
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

CREATE DEFINER=`schmitt`@`localhost` PROCEDURE `unban_user` (IN `target_id` INT)   BEGIN
    
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

CREATE TABLE `belongs` (
  `belong_cat_id` int(10) UNSIGNED NOT NULL,
  `belong_mov_id` int(10) UNSIGNED NOT NULL
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
(7, 32),
(3, 33),
(2, 35),
(1, 36),
(9, 37),
(2, 38),
(2, 39),
(1, 40),
(2, 41),
(9, 42),
(7, 43),
(5, 44),
(5, 45),
(1, 46),
(3, 47),
(2, 48),
(3, 49),
(2, 50),
(8, 51),
(1, 52);

-- --------------------------------------------------------

--
-- Structure de la table `categories`
--

CREATE TABLE `categories` (
  `cat_id` int(10) UNSIGNED NOT NULL COMMENT 'Categories ID',
  `cat_name` varchar(50) NOT NULL COMMENT 'Categories name'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

CREATE TABLE `comments` (
  `com_id` int(10) UNSIGNED NOT NULL COMMENT 'Comment ID',
  `com_comment` text NOT NULL COMMENT 'Comment content',
  `com_datetime` datetime NOT NULL COMMENT 'Comment date time',
  `com_user_id` int(10) UNSIGNED DEFAULT NULL,
  `com_movie_id` int(10) UNSIGNED DEFAULT NULL,
  `com_spoiler` tinyint(1) NOT NULL DEFAULT 0,
  `com_updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `comments`
--

INSERT INTO `comments` (`com_id`, `com_comment`, `com_datetime`, `com_user_id`, `com_movie_id`, `com_spoiler`, `com_updated_at`) VALUES
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
(108, 'test', '2026-03-04 09:31:04', 23, 25, 0, '2026-03-04 09:33:38'),
(110, 'je l\'ai pas encore vu, mais il n\'a pas l\'air ouf 🤔', '2026-03-04 14:27:22', 32, 21, 1, NULL),
(111, 'Ce film est vraiment INCROYABLE !!!', '2026-03-04 15:06:18', 35, 24, 0, NULL),
(113, 'Minou ♥♥♥♥♥♥♥♥♥', '2026-03-05 00:29:18', 38, 41, 0, NULL),
(117, 'Comme vous pouvez le voir, Minou se porte magnifiquement bien dans notre sanctuaire ! Pour des raisons que l\'on ignore, il semble être devenu un Toyger, et non plus un Tiger. Probablement parce que sa vie est maintenant rempli de bonheur.', '2026-03-05 15:47:31', 41, 41, 0, NULL),
(118, 'MIIIIIIIIIIIINOUUUUUUUUUUUUUUU LE GOAT', '2026-03-05 15:47:53', 42, 41, 0, NULL),
(119, 'Meilleur film de ma vie. Tellement émue par les péripéties de Minou. Je vais régulièrement lui rendre visite dans son nouveau sanctuaire. Minou à jamais dans nos cœurs !', '2026-03-05 15:57:29', 43, 41, 0, NULL);

--
-- Déclencheurs `comments`
--
DELIMITER $$
CREATE TRIGGER `after_insert_comments` AFTER INSERT ON `comments` FOR EACH ROW INSERT INTO history_comments (hist_table, hist_event, hist_elementid, hist_date, hist_userid)
VALUES ('comments', 'INSERT', NEW.com_id, NOW(), NEW.com_user_id)
$$
DELIMITER ;
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
DELIMITER $$
CREATE TRIGGER `before_delete_comments` BEFORE DELETE ON `comments` FOR EACH ROW INSERT INTO history_comments (hist_table, hist_event, hist_elementid, hist_date, hist_field, hist_oldvalue, hist_newvalue, hist_userid)
VALUES ('comments', 'DELETE', OLD.com_id, NOW(), 'com_comment', OLD.com_comment, NULL, OLD.com_user_id)
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `functions`
--

CREATE TABLE `functions` (
  `funct_id` int(10) UNSIGNED NOT NULL COMMENT 'Function ID',
  `funct_name` enum('User','Moderator','Administrator') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

CREATE TABLE `history_comments` (
  `hist_id` int(11) NOT NULL,
  `hist_table` varchar(50) DEFAULT NULL,
  `hist_event` varchar(10) DEFAULT NULL,
  `hist_elementid` int(11) NOT NULL,
  `hist_date` datetime DEFAULT NULL,
  `hist_field` text DEFAULT NULL,
  `hist_oldvalue` text DEFAULT NULL,
  `hist_newvalue` text DEFAULT NULL,
  `hist_userid` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
(57, 'comments', 'INSERT', 109, '2026-03-04 11:38:27', NULL, NULL, NULL, 23),
(58, 'comments', 'INSERT', 110, '2026-03-04 14:27:22', NULL, NULL, NULL, 32),
(59, 'comments', 'UPDATE', 110, '2026-03-04 14:28:17', 'com_spoiler', '0', '1', 32),
(60, 'comments', 'INSERT', 111, '2026-03-04 15:06:18', NULL, NULL, NULL, 35),
(61, 'comments', 'DELETE', 109, '2026-03-04 15:33:25', 'com_comment', 'dzqdqzd', NULL, 23),
(62, 'comments', 'INSERT', 112, '2026-03-04 18:35:28', NULL, NULL, NULL, 32),
(63, 'comments', 'DELETE', 112, '2026-03-04 18:44:32', 'com_comment', 'Ce film est une grosse daube et tous ceux qui aiment ce film son des gros 🤬🤬🤬🤬🤬🤬🤬🤬🤬🤬🤬🤬🤬🤬🤬🤬🤬🤬🤬!!!', NULL, 32),
(64, 'comments', 'UPDATE', 8, '2026-03-04 21:17:25', 'com_spoiler', '1', '0', 7),
(65, 'comments', 'INSERT', 113, '2026-03-05 00:29:18', NULL, NULL, NULL, 38),
(66, 'comments', 'INSERT', 114, '2026-03-05 08:38:48', NULL, NULL, NULL, 17),
(67, 'comments', 'UPDATE', 113, '2026-03-05 09:39:03', 'com_spoiler', '0', '1', 38),
(68, 'comments', 'UPDATE', 113, '2026-03-05 09:39:07', 'com_spoiler', '1', '0', 38),
(70, 'comments', 'DELETE', 8, '2026-03-05 09:42:35', 'com_comment', 'Difficile à regarder, trop de violence gratuite.', NULL, 7),
(71, 'comments', 'DELETE', 114, '2026-03-05 09:42:44', 'com_comment', 'dqdqzdqdq', NULL, 17),
(72, 'comments', 'DELETE', 105, '2026-03-05 09:43:13', 'com_comment', '😁😁😁😁😁😁😁😁😁😁😁😁', NULL, 17),
(73, 'comments', 'INSERT', 115, '2026-03-05 10:54:59', NULL, NULL, NULL, 40),
(74, 'comments', 'DELETE', 115, '2026-03-05 11:05:28', 'com_comment', 'zdqdzqdzqdzdzqdzqdzq', NULL, 40),
(75, 'comments', 'UPDATE', 113, '2026-03-05 14:28:36', 'com_spoiler', '0', '1', 38),
(76, 'comments', 'UPDATE', 113, '2026-03-05 14:28:38', 'com_spoiler', '1', '0', 38),
(77, 'comments', 'INSERT', 117, '2026-03-05 15:47:31', NULL, NULL, NULL, 41),
(78, 'comments', 'INSERT', 118, '2026-03-05 15:47:53', NULL, NULL, NULL, 42),
(79, 'comments', 'INSERT', 119, '2026-03-05 15:57:29', NULL, NULL, NULL, 43),
(80, 'comments', 'UPDATE', 117, '2026-03-05 16:08:07', 'com_spoiler', '0', '1', 41),
(81, 'comments', 'UPDATE', 117, '2026-03-05 16:11:05', 'com_spoiler', '1', '0', 41);

-- --------------------------------------------------------

--
-- Structure de la table `history_contents`
--

CREATE TABLE `history_contents` (
  `hist_id` int(11) NOT NULL,
  `hist_table` varchar(50) NOT NULL,
  `hist_event` varchar(10) NOT NULL,
  `hist_elementid` varchar(50) NOT NULL,
  `hist_date` datetime NOT NULL,
  `hist_field` text DEFAULT NULL,
  `hist_oldvalue` text DEFAULT NULL,
  `hist_newvalue` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
(27, 'movies', 'UPDATE', '21', '2026-03-04 10:26:35', 'mov_length', '03:10:00', '03:11:00'),
(28, 'movies', 'UPDATE', '16', '2026-03-04 14:12:35', 'mov_release_date', '2001-10-12', '2026-10-12'),
(29, 'movies', 'UPDATE', '16', '2026-03-04 14:13:03', 'mov_release_date', '2026-10-12', '2026-03-03'),
(30, 'movies', 'UPDATE', '20', '2026-03-04 14:13:31', 'mov_release_date', '1997-02-21', '2026-03-02'),
(31, 'movies', 'DELETE', '33', '2026-03-04 14:17:55', NULL, NULL, NULL),
(32, 'movies', 'DELETE', '34', '2026-03-04 14:19:07', NULL, NULL, NULL),
(33, 'movies', 'DELETE', '34', '2026-03-04 14:19:39', NULL, NULL, NULL),
(34, 'persons', 'UPDATE', '7', '2026-03-04 14:21:54', 'pers_deathdate', '0000-00-00', '0000-00-00'),
(35, 'movies', 'DELETE', '35', '2026-03-04 14:24:37', NULL, NULL, NULL),
(36, 'movies', 'DELETE', '36', '2026-03-04 14:35:53', NULL, NULL, NULL),
(37, 'movies', 'DELETE', '37', '2026-03-04 14:40:22', NULL, NULL, NULL),
(38, 'movies', 'DELETE', '38', '2026-03-04 14:40:54', NULL, NULL, NULL),
(39, 'movies', 'DELETE', '39', '2026-03-04 15:00:56', NULL, NULL, NULL),
(40, 'movies', 'DELETE', '40', '2026-03-04 15:05:17', NULL, NULL, NULL),
(41, 'movies', 'DELETE', '41', '2026-03-04 15:20:59', NULL, NULL, NULL),
(42, 'movies', 'DELETE', '42', '2026-03-04 20:09:20', NULL, NULL, NULL),
(43, 'movies', 'DELETE', '43', '2026-03-04 20:11:23', NULL, NULL, NULL),
(44, 'movies', 'DELETE', '44', '2026-03-04 20:13:53', NULL, NULL, NULL),
(45, 'movies', 'DELETE', '45', '2026-03-04 20:16:58', NULL, NULL, NULL),
(46, 'movies', 'DELETE', '46', '2026-03-04 20:20:52', NULL, NULL, NULL),
(47, 'movies', 'DELETE', '47', '2026-03-04 20:26:57', NULL, NULL, NULL),
(48, 'movies', 'DELETE', '48', '2026-03-04 20:32:41', NULL, NULL, NULL),
(49, 'movies', 'DELETE', '49', '2026-03-04 20:42:16', NULL, NULL, NULL),
(50, 'movies', 'DELETE', '50', '2026-03-04 20:45:50', NULL, NULL, NULL),
(51, 'persons', 'UPDATE', '7', '2026-03-05 08:41:04', 'pers_firstname', 'Nicole', 'Nicolee'),
(52, 'persons', 'UPDATE', '7', '2026-03-05 08:42:42', 'pers_deathdate', '0000-00-00', '0000-00-00'),
(53, 'persons', 'UPDATE', '7', '2026-03-05 08:43:07', 'pers_firstname', 'Nicolee', 'Nicoleeeee'),
(54, 'persons', 'UPDATE', '7', '2026-03-05 08:43:07', 'pers_deathdate', '0000-00-00', '0000-00-00'),
(55, 'persons', 'UPDATE', '7', '2026-03-05 08:46:19', 'pers_firstname', 'Nicoleeeee', 'Nicoleeeeeeeeeeeeeeee'),
(56, 'persons', 'UPDATE', '7', '2026-03-05 08:50:42', 'pers_firstname', 'Nicoleeeeeeeeeeeeeeee', 'Nicole'),
(57, 'persons', 'UPDATE', '7', '2026-03-05 08:50:42', 'pers_deathdate', NULL, NULL),
(58, 'persons', 'UPDATE', '10', '2026-03-05 08:51:30', 'pers_firstname', 'Kyle', 'Kyle test'),
(59, 'persons', 'UPDATE', '10', '2026-03-05 08:51:30', 'pers_deathdate', NULL, NULL),
(60, 'persons', 'UPDATE', '10', '2026-03-05 08:51:39', 'pers_firstname', 'Kyle test', 'Kyle'),
(61, 'persons', 'UPDATE', '10', '2026-03-05 08:51:39', 'pers_deathdate', NULL, NULL),
(62, 'movies', 'DELETE', '51', '2026-03-05 10:32:11', NULL, NULL, NULL),
(63, 'movies', 'DELETE', '52', '2026-03-05 16:05:01', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `history_users`
--

CREATE TABLE `history_users` (
  `hist_id` int(11) NOT NULL,
  `hist_table` varchar(50) NOT NULL,
  `hist_event` varchar(10) NOT NULL,
  `hist_elementid` varchar(50) NOT NULL,
  `hist_date` datetime NOT NULL,
  `hist_field` text DEFAULT NULL,
  `hist_oldvalue` text DEFAULT NULL,
  `hist_newvalue` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
(49, 'users', 'UPDATE', '26', '2026-03-02 21:59:35', 'user_ban_at', NULL, '2026-03-17 00:00:00'),
(50, 'users', 'INSERT', '32', '2026-03-04 14:12:54', NULL, NULL, NULL),
(51, 'users', 'INSERT', '33', '2026-03-04 14:15:42', NULL, NULL, NULL),
(52, 'users', 'UPDATE', '33', '2026-03-04 14:41:15', 'user_bio', 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', 'Marco arrete de foutre la merde'),
(53, 'users', 'UPDATE', '33', '2026-03-04 14:42:19', 'user_bio', 'Marco arrete de foutre la merde', 'Marco arrete de foutre la merde 😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜🐒🐒🐒🐒🐒🐒🐒🐒🐒🐒🐒🐒🐒'),
(54, 'users', 'UPDATE', '33', '2026-03-04 14:42:54', 'user_bio', 'Marco arrete de foutre la merde 😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜😜🐒🐒🐒🐒🐒🐒🐒🐒🐒🐒🐒🐒🐒', ''),
(55, 'users', 'INSERT', '34', '2026-03-04 14:45:13', NULL, NULL, NULL),
(56, 'users', 'UPDATE', '33', '2026-03-04 14:46:46', 'user_pseudo', 'ruin-e', 'ruin-ed'),
(57, 'users', 'UPDATE', '33', '2026-03-04 14:46:57', 'user_pseudo', 'ruin-ed', 'ruin-e 🐒🐒🐒'),
(58, 'users', 'UPDATE', '33', '2026-03-04 14:46:59', 'user_pseudo', 'ruin-e 🐒🐒🐒', 'ruin-e'),
(59, 'users', 'UPDATE', '33', '2026-03-04 14:46:59', 'user_photo', 'defaultImgUser.jpg', '69a837d3ab2f8.jpg'),
(60, 'users', 'UPDATE', '33', '2026-03-04 14:47:49', 'user_pseudo', 'ruin-e', 'ruin-e 🐒🐒🐒🐒🐒'),
(61, 'users', 'UPDATE', '33', '2026-03-04 14:49:11', 'user_funct_id', '1', '3'),
(62, 'users', 'UPDATE', '34', '2026-03-04 14:49:16', 'user_funct_id', '1', '3'),
(63, 'users', 'INSERT', '35', '2026-03-04 14:51:24', NULL, NULL, NULL),
(64, 'users', 'UPDATE', '35', '2026-03-04 14:55:21', 'user_pseudo', 'Mayou', 'Minou'),
(65, 'users', 'UPDATE', '33', '2026-03-04 15:31:54', 'user_pseudo', 'ruin-e 🐒🐒🐒🐒🐒', 'ruin-e'),
(66, 'users', 'UPDATE', '35', '2026-03-04 15:44:16', 'user_ban_at', NULL, '2026-03-19 00:00:00'),
(67, 'users', 'UPDATE', '32', '2026-03-04 15:53:10', 'user_pwd', '$2y$10$gHZbsLjpXqJwdr0shKASaOj9iAcYfsnzRaZB40o2uNsccnKQdQIV6', '$2y$10$LfKbesgdvUYwRhOIqiYIEOLI/3rza7NP.daJdf9XBgQgRVsFXY8Tu'),
(68, 'users', 'UPDATE', '23', '2026-03-04 15:59:06', 'user_ban_at', NULL, '2026-03-28 15:59:02'),
(69, 'users', 'UPDATE', '26', '2026-03-04 16:01:17', 'user_ban_at', '2026-03-17 00:00:00', NULL),
(70, 'users', 'UPDATE', '23', '2026-03-04 16:11:08', 'user_email', 'marco06.marco06@gmail.com', ''),
(71, 'users', 'UPDATE', '33', '2026-03-04 16:21:12', 'user_photo', '69a837d3ab2f8.jpg', '69a84de848e72.webp'),
(72, 'users', 'UPDATE', '33', '2026-03-04 16:22:09', 'user_photo', '69a84de848e72.webp', '69a84e21d0945.webp'),
(73, 'users', 'UPDATE', '4', '2026-03-04 16:28:49', 'user_pseudo', 'sophie_b', 'sophie_bb'),
(74, 'users', 'INSERT', '36', '2026-03-04 16:34:18', NULL, NULL, NULL),
(75, 'users', 'UPDATE', '36', '2026-03-04 16:49:01', 'user_funct_id', '1', '2'),
(76, 'users', 'INSERT', '37', '2026-03-04 18:37:05', NULL, NULL, NULL),
(77, 'users', 'UPDATE', '37', '2026-03-04 20:29:54', 'user_pseudo', 'casseCroute', 'Nicky'),
(78, 'users', 'UPDATE', '24', '2026-03-04 22:09:33', 'user_ban_at', NULL, '2026-04-03 00:00:00'),
(80, 'users', 'UPDATE', '24', '2026-03-04 22:09:49', 'user_ban_at', NULL, '2026-05-03 00:00:00'),
(82, 'users', 'UPDATE', '24', '2026-03-04 22:46:30', 'user_ban_at', NULL, '2026-07-02 00:00:00'),
(86, 'users', 'UPDATE', '30', '2026-03-04 22:56:47', 'user_ban_at', NULL, '2026-04-03 00:00:00'),
(88, 'users', 'UPDATE', '30', '2026-03-04 23:00:09', 'user_ban_at', NULL, '2026-05-03 00:00:00'),
(90, 'users', 'UPDATE', '35', '2026-03-04 23:03:53', 'user_ban_at', NULL, '2026-04-03 00:00:00'),
(92, 'users', 'INSERT', '38', '2026-03-05 00:28:48', NULL, NULL, NULL),
(93, 'users', 'UPDATE', '6', '2026-03-05 08:33:35', 'user_ban_at', NULL, '2026-03-20 00:00:00'),
(96, 'users', 'INSERT', '39', '2026-03-05 10:20:30', NULL, NULL, NULL),
(97, 'users', 'UPDATE', '39', '2026-03-05 10:20:49', 'user_funct_id', '1', '2'),
(98, 'users', 'INSERT', '40', '2026-03-05 10:24:03', NULL, NULL, NULL),
(99, 'users', 'UPDATE', '40', '2026-03-05 10:25:51', 'user_pseudo', 'UserUtilisateurUtile', 'UserTroCool'),
(100, 'users', 'DELETE', '26', '2026-03-05 12:09:05', NULL, NULL, NULL),
(101, 'users', 'DELETE', '27', '2026-03-05 12:09:05', NULL, NULL, NULL),
(102, 'users', 'DELETE', '28', '2026-03-05 12:09:05', NULL, NULL, NULL),
(103, 'users', 'DELETE', '29', '2026-03-05 12:09:05', NULL, NULL, NULL),
(104, 'users', 'DELETE', '30', '2026-03-05 12:09:05', NULL, NULL, NULL),
(105, 'users', 'DELETE', '31', '2026-03-05 12:09:05', NULL, NULL, NULL),
(106, 'users', 'UPDATE', '10', '2026-03-05 15:18:40', 'user_funct_id', '1', '2'),
(107, 'users', 'UPDATE', '10', '2026-03-05 15:18:45', 'user_funct_id', '2', '1'),
(108, 'users', 'UPDATE', '10', '2026-03-05 15:18:47', 'user_funct_id', '1', '3'),
(109, 'users', 'UPDATE', '9', '2026-03-05 15:18:57', 'user_ban_at', NULL, '2026-07-03 00:00:00'),
(111, 'users', 'INSERT', '41', '2026-03-05 15:45:18', NULL, NULL, NULL),
(112, 'users', 'INSERT', '42', '2026-03-05 15:47:22', NULL, NULL, NULL),
(113, 'users', 'UPDATE', '42', '2026-03-05 15:49:44', 'user_pwd', '$2y$10$.M/ADs0cr2GTHE9KkhlxSeEMdwF9BpcjPqzaie8gUmRY3CtuzbAbK', '$2y$10$gXL1JSzlrpgUcdOUXRFazezmfg0NZQ.rM1pvhLoH3VUetZ9aUEYTG'),
(114, 'users', 'INSERT', '43', '2026-03-05 15:55:21', NULL, NULL, NULL),
(115, 'users', 'UPDATE', '17', '2026-03-05 15:55:51', 'user_pwd', '$2y$12$zRjrT2Pcs1Lfn6jhd0Z6guipp3vIph5ZdgGF4dybhQp35RiTst6HO', '$2y$10$Grw/XVwbShpIgK40Wx52.e9vAvhozt4rYgAFQHSxv0nDj/BI/4Ad.'),
(116, 'users', 'UPDATE', '38', '2026-03-05 16:15:21', 'user_firstname', 'Grisouuuuuuuuuu', 'Mégane'),
(117, 'users', 'UPDATE', '38', '2026-03-05 16:15:42', 'user_firstname', 'Mégane', 'Grisouuuuuuu'),
(118, 'users', 'UPDATE', '38', '2026-03-05 16:15:42', 'user_pseudo', 'Grigri', 'Mégane');

-- --------------------------------------------------------

--
-- Structure de la table `jobs`
--

CREATE TABLE `jobs` (
  `job_id` int(10) UNSIGNED NOT NULL COMMENT 'Jobs ID',
  `job_name` enum('Realisator','Productor','Actor') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

CREATE TABLE `liked` (
  `lik_user_id` int(10) UNSIGNED NOT NULL,
  `lik_mov_id` int(10) UNSIGNED DEFAULT NULL,
  `lik_com_id` int(10) UNSIGNED DEFAULT NULL,
  `lik_created_at` timestamp NULL DEFAULT current_timestamp()
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
(23, NULL, 18, '2026-03-04 08:03:28'),
(23, 20, NULL, '2026-03-04 13:14:08'),
(32, 21, NULL, '2026-03-04 13:24:43'),
(33, 35, NULL, '2026-03-04 13:28:09'),
(17, 35, NULL, '2026-03-04 13:31:20'),
(32, 37, NULL, '2026-03-04 13:41:25'),
(32, 33, NULL, '2026-03-04 13:42:09'),
(32, 38, NULL, '2026-03-04 13:42:41'),
(35, 36, NULL, '2026-03-04 14:01:21'),
(35, 20, NULL, '2026-03-04 14:01:36'),
(35, 24, NULL, '2026-03-04 14:05:41'),
(33, 41, NULL, '2026-03-04 14:30:47'),
(33, 37, NULL, '2026-03-04 14:31:05'),
(33, 16, NULL, '2026-03-04 14:31:31'),
(38, NULL, 113, '2026-03-04 23:30:46'),
(17, 41, NULL, '2026-03-05 06:43:45'),
(17, NULL, 113, '2026-03-05 13:28:34'),
(17, 46, NULL, '2026-03-05 14:19:33'),
(41, 41, NULL, '2026-03-05 14:45:50'),
(41, NULL, 113, '2026-03-05 14:47:40'),
(38, NULL, 118, '2026-03-05 14:48:10'),
(38, NULL, 117, '2026-03-05 14:48:12'),
(41, NULL, 118, '2026-03-05 14:48:15'),
(41, NULL, 117, '2026-03-05 14:48:18'),
(43, 41, NULL, '2026-03-05 14:55:48'),
(17, NULL, 117, '2026-03-05 14:57:36'),
(43, NULL, 113, '2026-03-05 14:57:38'),
(17, NULL, 119, '2026-03-05 14:57:38'),
(43, NULL, 117, '2026-03-05 14:57:41'),
(43, NULL, 118, '2026-03-05 14:57:44'),
(17, NULL, 118, '2026-03-05 14:58:21'),
(42, NULL, 118, '2026-03-05 15:00:54'),
(38, NULL, 119, '2026-03-05 15:14:54');

-- --------------------------------------------------------

--
-- Structure de la table `login_attempts`
--

CREATE TABLE `login_attempts` (
  `attempt_id` int(10) UNSIGNED NOT NULL,
  `attempt_ip` varchar(45) DEFAULT NULL,
  `attempt_datetime` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `logs_users`
--

CREATE TABLE `logs_users` (
  `log_id` int(11) NOT NULL,
  `log_user_id` int(11) NOT NULL,
  `log_event` varchar(10) DEFAULT NULL,
  `log_ip` varchar(45) NOT NULL,
  `log_agent` text DEFAULT NULL,
  `log_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
(104, 23, 'LOGIN', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 12:15:56'),
(105, 23, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:11:22'),
(106, 23, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:11:53'),
(107, 23, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:12:08'),
(108, 32, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:13:04'),
(109, 33, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:15:48'),
(110, 23, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:27:50'),
(111, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:27:56'),
(112, 32, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:30:20'),
(113, 32, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36', '2026-03-04 13:30:43'),
(114, 33, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (iPhone; CPU iPhone OS 26_3_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/145.0.7632.108 Mobile/15E148 Safari/604.1', '2026-03-04 13:31:14'),
(115, 32, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:32:05'),
(116, 32, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:43:59'),
(117, 32, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:45:25'),
(118, 32, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:45:30'),
(119, 34, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:45:39'),
(120, 34, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:49:02'),
(121, 33, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:51:22'),
(122, 35, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:51:38'),
(123, 17, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 13:52:26'),
(124, 35, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:27:16'),
(125, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:29:13'),
(126, 33, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:30:34'),
(127, 34, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:32:29'),
(128, 34, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:44:04'),
(129, 35, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:44:30'),
(130, 35, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:45:02'),
(131, 33, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:46:43'),
(132, 17, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:48:50'),
(133, 23, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:48:54'),
(134, 23, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:51:08'),
(135, 23, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:52:11'),
(136, 23, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:52:16'),
(137, 23, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:52:21'),
(138, 23, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:52:22'),
(139, 23, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:52:27'),
(140, 23, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:52:50'),
(141, 23, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:53:09'),
(142, 32, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 14:53:28'),
(143, 32, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 14:53:35'),
(144, 23, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:54:10'),
(145, 23, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:54:17'),
(146, 23, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:54:18'),
(147, 33, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:55:17'),
(148, 23, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:55:56'),
(149, 23, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:55:59'),
(150, 23, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:56:05'),
(151, 23, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 14:56:12'),
(152, 33, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 15:01:33'),
(153, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 15:06:19'),
(154, 32, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 15:06:58'),
(155, 33, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 15:07:00'),
(156, 17, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 15:09:26'),
(157, 33, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 15:09:57'),
(158, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 15:09:59'),
(159, 32, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 15:10:23'),
(160, 34, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 15:10:31'),
(161, 34, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 15:10:44'),
(162, 33, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 15:20:56'),
(163, 33, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 15:25:52'),
(164, 34, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 15:31:23'),
(165, 36, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 15:34:25'),
(166, 36, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 15:38:09'),
(167, 33, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 15:38:14'),
(168, 34, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 16:08:27'),
(169, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 17:31:22'),
(170, 34, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 17:32:40'),
(171, 34, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 17:32:58'),
(172, 32, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 17:33:13'),
(173, 32, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 17:35:31'),
(174, 37, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 17:37:19'),
(175, 37, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 17:38:11'),
(176, 34, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 17:38:18'),
(177, 34, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 17:44:20'),
(178, 32, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 17:44:24'),
(179, 32, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 17:44:43'),
(180, 34, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 17:44:50'),
(181, 32, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 19:05:24'),
(182, 33, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 19:22:15'),
(183, 32, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 19:27:02'),
(184, 34, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 19:27:10'),
(185, 34, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 19:27:45'),
(186, 37, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 19:27:57'),
(187, 37, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 19:45:53'),
(188, 34, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 19:47:19'),
(189, 34, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0', '2026-03-04 19:48:15'),
(190, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-04 20:19:07'),
(191, 38, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Avast/144.0.0.0', '2026-03-04 23:28:56'),
(192, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3 Mobile/15E148 Safari/604.1', '2026-03-05 06:43:19'),
(193, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 07:28:30'),
(194, 17, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 08:01:42'),
(195, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 08:01:55'),
(196, 17, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 08:01:56'),
(197, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 08:03:31'),
(198, 17, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 08:03:38'),
(199, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 08:03:42'),
(200, 17, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 08:03:43'),
(201, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 08:03:49'),
(202, 17, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 08:03:51'),
(203, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 08:38:27'),
(204, 33, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:18:14'),
(205, 33, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:18:32'),
(206, 39, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:20:43'),
(207, 39, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:20:49'),
(208, 33, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:20:53'),
(209, 33, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:21:35'),
(210, 40, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:24:10'),
(211, 40, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:25:14'),
(212, 40, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:25:18'),
(213, 40, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:26:35'),
(214, 39, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:26:42'),
(215, 39, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:26:48'),
(216, 39, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:26:53'),
(217, 39, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:33:12'),
(218, 39, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:33:38'),
(219, 40, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:33:46'),
(220, 40, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:33:57'),
(221, 33, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:34:01'),
(222, 33, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:35:47'),
(223, 40, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 09:54:24'),
(224, 40, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 10:03:51'),
(225, 40, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 10:04:37'),
(226, 40, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 10:09:31'),
(227, 39, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 10:09:37'),
(228, 39, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 10:10:07'),
(229, 33, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 10:10:14'),
(230, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 11:13:49'),
(231, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 13:21:18'),
(232, 17, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 13:21:39'),
(233, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 13:26:10'),
(234, 40, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 13:32:58'),
(235, 40, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 13:33:09'),
(236, 39, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 13:33:20'),
(237, 39, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 13:33:30'),
(238, 33, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 13:33:35'),
(239, 33, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 13:39:15'),
(240, 39, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 13:39:21'),
(241, 39, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 13:48:37'),
(242, 33, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 13:48:42'),
(243, 17, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 14:33:14'),
(244, 41, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:148.0) Gecko/20100101 Firefox/148.0', '2026-03-05 14:45:31'),
(245, 42, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 14:47:28'),
(246, 38, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Avast/144.0.0.0', '2026-03-05 14:47:52'),
(247, 42, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 14:48:43'),
(248, 42, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 14:49:50'),
(249, 43, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:148.0) Gecko/20100101 Firefox/148.0', '2026-03-05 14:55:32'),
(250, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 14:55:57'),
(251, 17, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 15:00:50'),
(252, 42, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 15:01:20'),
(253, 42, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 15:01:31'),
(254, 42, 'LOGOUT', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 15:05:05'),
(255, 17, 'LOGIN', '109.234.161.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 15:06:19');

-- --------------------------------------------------------

--
-- Structure de la table `movies`
--

CREATE TABLE `movies` (
  `mov_id` int(10) UNSIGNED NOT NULL COMMENT 'Movie Id',
  `mov_title` varchar(100) DEFAULT NULL COMMENT 'Title of the movie',
  `mov_original_title` varchar(100) NOT NULL COMMENT 'Original title of the movie',
  `mov_length` time NOT NULL COMMENT 'Movie length',
  `mov_description` text NOT NULL COMMENT 'Description',
  `mov_release_date` date NOT NULL COMMENT 'Release date',
  `mov_nat_id` int(10) UNSIGNED DEFAULT NULL,
  `mov_trailer_url` text DEFAULT NULL,
  `mov_published_at` datetime DEFAULT NULL,
  `mov_updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `movies`
--

INSERT INTO `movies` (`mov_id`, `mov_title`, `mov_original_title`, `mov_length`, `mov_description`, `mov_release_date`, `mov_nat_id`, `mov_trailer_url`, `mov_published_at`, `mov_updated_at`) VALUES
(13, 'Orange Mécanique', 'A Clockwork Orange', '02:16:00', 'Dans un futur dystopique, un chef de gang sadique est soumis à une expérience de réhabilitation.', '1971-12-19', 3, 'https://www.youtube.com/watch?v=T54uZPI4Z8A', '2026-02-28 17:14:23', NULL),
(14, 'Full Metal Jacket', 'Full Metal Jacket', '01:56:00', 'Le parcours de jeunes marines américains, de l\'entraînement brutal à la guerre du Vietnam.', '1987-06-26', 2, 'https://www.google.com/search?q=trailer+full+metal+jacket&rlz=1C1VDKB_frFR1102FR1102&oq=trailer+full+metal+jacket&gs_lcrp=EgZjaHJvbWUyBggAEEUYOTIICAEQABgWGB4yCAgCEAAYFhgeMggIAxAAGBYYHjIICAQQABgWGB4yCAgFEAAYFhgeMggIBhAAGBYYHjIICAcQABgWGB4yCAgIEAAYFhgeMggIC', '2026-02-28 17:14:23', NULL),
(15, 'Eyes Wide Shut', 'Eyes Wide Shut', '02:39:00', 'Un médecin new-yorkais s\'aventure dans une odyssée nocturne étrange et érotique.', '1999-07-16', 2, 'https://www.google.com/search?q=trailer+eyes+wide+shut&sca_esv=f9558c3169decf9e&rlz=1C1VDKB_frFR1102FR1102&sxsrf=ANbL-n5RN_Qb7MwyMR5AJXafxA7vtNqRZA%3A1768731365994&ei=5bJsadC6PPWpkdUPk8Xh4QY&oq=trailer+eyes&gs_lp=Egxnd3Mtd2l6LXNlcnAiDHRyYWlsZXIgZXllcyoCCA', '2026-02-28 17:14:23', NULL),
(16, 'Mulholland Drive', 'Mulholland Dr.', '02:27:00', 'Une femme amnésique et une aspirante actrice enquêtent dans un Los Angeles onirique.', '2026-03-03', 2, 'https://www.youtube.com/watch?v=91kRgjELBek', '2026-02-28 17:14:23', '2026-03-04 14:13:03'),
(18, 'Eraserhead', 'Eraserhead', '01:29:00', 'Henry Spencer tente de survivre dans son environnement industriel avec sa petite amie et leur enfant mutant.', '1977-03-19', 2, 'https://www.youtube.com/watch?v=oK-2_OsBe0s', '2026-02-28 17:14:23', NULL),
(19, 'Elephant Man', 'The Elephant Man', '02:04:00', 'Un chirurgien victorien sauve un homme gravement défiguré, exploité comme un monstre de foire.', '1980-10-03', 2, 'https://www.youtube.com/watch?v=AF9gNKJi79g', '2026-02-28 17:14:23', NULL),
(20, 'Lost Highway', 'Lost Highway', '02:14:00', 'Après une rencontre bizarroïde lors d\'une fête, un saxophoniste est accusé du meurtre de sa femme.', '2026-03-02', 2, 'https://www.youtube.com/watch?v=8-1pcMvy5qc', '2026-02-28 17:14:23', '2026-03-04 14:13:31'),
(21, 'Avatar: Fire and Ash', 'Avatar: Fire and Ash', '03:11:00', 'Jake Sully et Neytiri affrontent un nouveau clan de Na\'vi lié au feu dans une région volcanique de Pandora.', '2026-01-07', 2, 'https://www.youtube.com/watch?v=nb_fFj_0rq8', '2026-02-28 17:14:23', '2026-03-04 10:26:35'),
(22, 'M3GAN 2.0', 'M3GAN 2.0', '01:42:00', 'L\'intelligence artificielle meurtrière est de retour dans une version plus évoluée et plus dangereuse.', '2026-01-14', 2, 'https://www.youtube.com/watch?v=I0VWWnMUjFU', '2026-02-28 17:14:23', NULL),
(24, 'Paddington au Pérou', 'Paddington in Peru', '01:43:00', 'Paddington retourne au Pérou pour rendre visite à sa tante Lucy, entraînant les Brown dans une aventure épique.', '2026-01-07', 3, 'https://www.youtube.com/watch?v=Fp-1L1KOIk8', '2026-02-28 17:14:23', NULL),
(25, 'The Drama', 'The Drama', '02:05:00', 'Une crise inattendue survient dans la vie d\'un couple à la veille de leur mariage.', '2026-01-30', 2, 'https://www.google.com/search?q=trailer+the+drama&rlz=1C1VDKB_frFR1102FR1102&sca_esv=f9558c3169decf9e&sxsrf=ANbL-n40rc4yxeDI2p-TpaTEP3S6ZfVrTA%3A1768731399284&ei=B7Nsaf6EEeDCnsEP7fu26QI&ved=0ahUKEwi-pIf27ZSSAxVgoScCHe29LS0Q4dUDCBE&uact=5&oq=trailer+the+dr', '2026-02-28 17:14:23', NULL),
(32, 'Marsupilami', 'Marsupilami', '01:39:00', 'Pour sauver son emploi, David accepte un plan foireux : ramener un mystérieux colis d’Amérique du Sud. Il se retrouve à bord d’une croisière avec son ex Tess, son fils Léo, et son collègue Stéphane, aussi benêt que maladroit, dont David se sert pour transporter le colis à sa place. Tout dérape lorsque ce dernier l’ouvre accidentellement : un adorable bébé Marsupilami apparait et le voyage vire au chaos !', '2026-03-05', 1, 'https://www.allocine.fr/video/player_gen_cmedia=20630202&cfilm=317669.html', '2026-03-02 21:24:43', NULL),
(33, 'Les enfants de la résistance', '', '01:41:00', 'Pendant l’occupation allemande durant la Seconde Guerre mondiale, François, Eusèbe et Lisa, trois enfants courageux, se lancent dans une aventure secrète : résister aux nazis en plein cœur de la France. Sabotages, messages cachés et évasions périlleuses, ils mènent des actions clandestines sous le nez de l’ennemi. L’audace et l’amitié sont leurs seules armes pour lutter contre l’injustice.', '2026-02-11', 1, 'https://youtu.be/-2v2vWrUwcA', '2026-03-04 14:27:38', NULL),
(35, 'Evil Dead Burn', 'Evil Dead Burn', '01:25:00', 'Evil Dead Burn est un film américain réalisé par Sébastien Vaniček et dont la sortie est prévue en 2026. Il s\'agit du sixième film de la franchise Evil Dead créée par Sam Raimi.', '2026-07-22', 2, 'https://www.youtube.com/watch?v=YyASjCJCAdw', '2026-03-04 14:27:40', NULL),
(36, 'Projet Dernière Chance', 'Project Hail Mary', '02:36:00', 'Ryland Grace, professeur de sciences, se réveille seul à bord d’un vaisseau spatial, à des années-lumière de la Terre, sans aucun souvenir de son identité ni des raisons de sa présence à bord. Peu à peu, sa mémoire lui revient, et il comprend l’enjeu de sa mission : résoudre l\'énigme de la mystérieuse substance qui cause l\'extinction du Soleil. Pour tenter de sauver l’humanité, il va devoir faire appel à ses connaissances scientifiques et à des idées peu conventionnelles … Mais une amitié inattendue pourrait bien l’aider à ne pas affronter cette mission tout seul.', '2026-03-11', 3, 'https://www.youtube.com/watch?v=6nRoftXLBFo', '2026-03-04 14:37:37', NULL),
(37, 'Plus fort que moi', 'I swear', '02:01:00', 'L\'histoire vraie et le parcours semé d\'embûches de John Davidson, un adolescent atteint du syndrome de la Tourette, une maladie encore méconnue dans les années 1980.', '2026-04-01', 3, 'https://www.youtube.com/watch?v=BiWjGmMJO6E', '2026-03-04 14:41:17', '2026-03-04 14:41:11'),
(38, 'Le reveil de la momie', 'Lee Cronin\'s The Mummy', '01:30:00', 'Une jeune fille disparue dans le désert égyptien réapparaît mystérieusement huit ans plus tard, mais les retrouvailles tournent vite au cauchemar. Alors que son comportement devient de plus en plus inquiétant, sa famille se lance dans une course contre-la-montre pour comprendre l\'origine du mal. Ce qu\'ils vont découvrir dépasse tout ce qu\'ils imaginaient.', '2026-04-15', 2, 'https://www.youtube.com/watch?v=V7qM1EjlYFc', '2026-03-04 14:41:20', '2026-03-04 14:44:06'),
(39, 'RRRrrrr !!!', '', '01:38:00', 'Il y a 37 000 ans, deux tribus voisines vivaient en paix... à un cheveu près. Pendant que la tribu des Cheveux Propres coulait des jours paisibles en gardant pour elle seule le secret de la formule du shampooing, la tribu des Cheveux Sales se lamentait.\r\n\r\nSon chef décida d\'envoyer un espion pour voler la recette. Mais un événement bien plus grave allait bouleverser la vie des Cheveux Propres : pour la première fois dans l\'histoire de l\'humanité, un crime venait d\'être commis. Comment découvrir son auteur ?\r\n\r\nAu temps des mammouths et des moumoutes commence la première enquête policière de l\'Histoire.', '2004-01-28', 1, 'https://www.youtube.com/watch?v=y_UKPVezalU', '2026-03-04 15:42:35', '2026-03-04 15:42:19'),
(40, 'Blade Runner', 'Blade Runner', '01:57:00', 'Dans les dernières années du 20ème siècle, des milliers d\'hommes et de femmes partent à la conquête de l\'espace, fuyant les mégalopoles devenues insalubres. Sur les colonies, une nouvelle race d\'esclaves voit le jour : les répliquants, des androïdes que rien ne peut distinguer de l\'être humain. Los Angeles, 2019. Après avoir massacré un équipage et pris le contrôle d\'un vaisseau, les répliquants de type Nexus 6, le modèle le plus perfectionné, sont désormais déclarés \"hors la loi\". Quatre d\'entre eux parviennent cependant à s\'échapper et à s\'introduire dans Los Angeles. Un agent d\'une unité spéciale, un blade-runner, est chargé de les éliminer. Selon la terminologie officielle, on ne parle pas d\'exécution, mais de retrait...', '1982-09-15', 2, 'https://www.youtube.com/watch?v=FfRPKYwsFNg', '2026-03-04 15:42:39', NULL),
(41, 'Exec(Minou)', '', '12:34:00', 'Dans un parc zoologique de province au bord de la faillite, Minou, un tigre du Bengale vieillissant, est devenu un fardeau financier. Cricri, son soigneur usé par les années et acculé par la direction du parc, décide d\'orchestrer l\'abattage illégal de l\'animal en prétextant une soudaine dangerosité. Alors que la mise à mort se prépare dans l\'ombre, une petite association de protection animale, alertée clandestinement par un employé du zoo, s\'engage dans une course contre la montre. Les militants doivent prouver la supercherie et intervenir physiquement sur les lieux avant que l\'irréparable ne soit commis.', '2026-02-23', 1, 'https://www.youtube.com/shorts/FFtblCTnATQ', '2026-03-04 15:29:56', NULL),
(42, 'La Liste de Schindler', 'Schindler\'s List', '03:15:00', 'Evocation des années de guerre d\'Oskar Schindler, fils d\'industriel d\'origine autrichienne rentré à Cracovie en 1939 avec les troupes allemandes. Il va, tout au long de la guerre, protéger des juifs en les faisant travailler dans sa fabrique et en 1944 sauver huit cents hommes et trois cents femmes du camp d\'extermination de Auschwitz-Birkenau.', '1994-03-02', 2, 'https://www.youtube.com/watch?v=ONWtyxzl-GE', '2026-03-04 22:28:35', NULL),
(43, 'La Ligne verte', 'The Green Mile', '03:09:00', 'Paul Edgecomb, pensionnaire centenaire d\'une maison de retraite, est hanté par ses souvenirs. Gardien-chef du pénitencier de Cold Mountain en 1935, il était chargé de veiller au bon déroulement des exécutions capitales en s’efforçant d\'adoucir les derniers moments des condamnés. Parmi eux se trouvait un colosse du nom de John Coffey, accusé du viol et du meurtre de deux fillettes. Intrigué par cet homme candide et timide aux dons magiques, Edgecomb va tisser avec lui des liens très forts.', '2000-03-01', 2, 'https://www.youtube.com/watch?v=mccs8Ql8m8o', '2026-03-04 22:28:38', '2026-03-05 12:14:48'),
(44, 'Hacker', 'Blackhat', '02:13:00', 'À Hong Kong, la centrale nucléaire de Chai Wan a été hackée. Un logiciel malveillant, sous la forme d’un outil d’administration à distance ou RAT (Remote Access Tool), a ouvert la porte à un autre malware plus puissant qui a détruit le système de refroidissement de la centrale, provoquant la fissure d’un caisson de confinement et la fusion de son coeur. Aucune tentative d’extorsion de fonds ou de revendication politique n’a été faite. Ce qui a motivé cet acte criminel reste un mystère', '2015-03-18', 2, 'https://www.youtube.com/watch?v=gvguTQ9uPSA', '2026-03-04 22:28:40', NULL),
(45, 'Seven', 'Se7en', '02:10:00', 'Pour conclure sa carrière, l\'inspecteur Somerset, vieux flic blasé, tombe à sept jours de la retraite sur un criminel peu ordinaire. John Doe, c\'est ainsi que se fait appeler l\'assassin, a decidé de nettoyer la societé des maux qui la rongent en commettant sept meurtres basés sur les sept pechés capitaux: la gourmandise, l\'avarice, la paresse, l\'orgueil, la luxure, l\'envie et la colère.', '1996-01-31', 2, 'https://www.youtube.com/watch?v=KPOuJGkpblk', '2026-03-04 22:28:43', NULL),
(46, 'Alien, le huitième passager', 'Alien', '01:56:00', 'Le vaisseau commercial Nostromo et son équipage, sept hommes et femmes, rentrent sur Terre avec une importante cargaison de minerai. Mais lors d\'un arrêt forcé sur une planète déserte, l\'officier Kane se fait agresser par une forme de vie inconnue, une arachnide qui étouffe son visage.\r\nAprès que le docteur de bord lui retire le spécimen, l\'équipage retrouve le sourire et dîne ensemble. Jusqu\'à ce que Kane, pris de convulsions, voit son abdomen perforé par un corps étranger vivant, qui s\'échappe dans les couloirs du vaisseau...', '1979-09-12', 2, 'https://www.youtube.com/watch?v=j3CFj1R9HbQ', '2026-03-04 22:28:45', NULL),
(47, 'Les Evadés', 'The Shawshank Redemption', '02:22:00', 'Red, condamné à perpétuité, et Andy Dufresne, un gentil banquier injustement condamné pour meurtre, se lient d\'une amitié inattendue qui va durer plus de vingt ans. Ensemble, ils découvrent l\'espoir comme l\'ultime moyen de survie. Sous des conditions terrifiantes et la menace omniprésente de la violence, les deux condamnés à perpétuité récupèrent leurs âmes et retrouvent la liberté dans leurs cœurs.', '1995-03-01', 2, 'https://www.youtube.com/watch?v=PLl99DlL6b4', '2026-03-04 22:28:47', NULL),
(48, 'The Bride!', '', '02:07:00', 'Rongé par la solitude, « Frank » se rend à Chicago dans les années 1930 et demande au Dr. Euphronious, scientifique visionnaire, de lui créer une compagne. Ensemble, ils ressuscitent une jeune femme assassinée, et la fiancée prend vie ! Mais la suite des événements dépasse tout ce que qu’ils auraient pu imaginer : meurtres, possessions, et un couple hors-la-loi qui se retrouve au centre d’un mouvement social radical et débridé, et d’une histoire d’amour passionnelle et tumultueuse !', '2026-03-04', 2, 'https://www.youtube.com/watch?v=OaDwvZ4tiyI', '2026-03-04 22:28:49', NULL),
(49, 'Las Corrientes', '', '01:44:00', 'Lina, 34 ans, est une styliste argentine au sommet de sa carrière. Lors d\'un séjour en Suisse pour recevoir un prix prestigieux, elle se jette sans raison apparente dans un fleuve. De retour à Buenos Aires, elle garde le silence sur cet épisode. Pourtant, imperceptiblement, quelque chose en elle a changé. Une peur de l\'eau s\'installe, insidieuse, et finit par paralyser son quotidien. Peu à peu, ce bouleversement fait remonter à la surface un passé qu\'elle croyait à jamais enfoui.', '0006-03-18', 6, 'https://www.youtube.com/watch?v=1FPCFFToFQY', '2026-03-04 22:28:51', NULL),
(50, 'Le siflet', 'Whistle', '01:40:00', 'Un groupe de lycéens tombe sur un artefact oublié : un sifflet de mort aztèque. Ils découvrent que souffler dedans libère un son terrifiant, capable d\'invoquer leurs morts futures pour les traquer. Alors que le nombre de victimes augmente, les adolescents doivent briser la chaîne de la Mort avant que le dernier écho du sifflet ne scelle leur destin.\r\n\r\nCe film de Corin Hardy s’inscrit dans la veine du cinéma d’horreur canadien contemporain, qui mêle tension psychologique et folklore, à l’image d\'Infinity Pool ou de Vicious Fun. La coproduction avec l’Irlande illustre la dynamique actuelle du genre : mutualiser moyens et influences pour toucher un public le plus large possible. Le cinéaste, déjà à l\'origine de Le Sanctuaire ou La Nonne, combine ici mythologie ancienne et figures adolescentes, motifs connus du film d\'épouvante, et se fait ainsi témoin de la vitalité d’un cinéma horrifique hors des circuits hollywoodiens classiques.', '2026-03-18', 3, 'https://www.youtube.com/watch?v=fgUTp1M3MG8', '2026-03-04 22:28:54', NULL),
(51, 'Jean Michel a la plage', 'Jean s\'en va faire ses courses a la plage', '03:33:00', 'Alors c\'est le jean mi, il va à la plage et il découvre qu\'en fait c\'est vraiment une plage, puis l\'eau, bah les poissons ils font l\'amour dedans, caca aussi enfin j\'crois donc c\'est salé, goût sel et ça pue... et même que les baleines elles vomissent et un éjaculat de baleine ça fait 400 gallons de semences... Gné ?', '2026-06-02', 8, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&themeRefresh=1', NULL, NULL),
(52, 'Blade Runner 2049', '', '02:43:00', 'En 2049, des humanoïdes issus du génie biologique, appelés Réplicants, ont été améliorés par la Wallace Corporation, cette entreprise ayant pris le relais de la Tyrell Corporation, suite à la faillite de cette dernière. Rendus émotionnellement plus stables, ils sont à présent couramment intégrés dans la société, au contact des humains, afin d\'assurer tout type de tâches sur Terre ou encore le développement des colonies spatiales. K (pour KD6-3.7), un modèle Nexus-9 de dernière génération, travaille comme Blade Runner au LAPD. Il traque et élimine les anciens modèles considérés à priori comme déviants et à risque. Tout juste toléré - voire haï - par les humains qu\'il côtoie, il mène une vie recluse et insipide, et son seul plaisir réside en la compagnie de sa « petite amie » holographique, Joi.', '2017-11-04', 2, 'https://www.youtube.com/watch?v=gCcx85zbxz4', NULL, NULL);

--
-- Déclencheurs `movies`
--
DELIMITER $$
CREATE TRIGGER `after_insert_movies` AFTER INSERT ON `movies` FOR EACH ROW INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date)
VALUES ('movies', 'DELETE', NEW.mov_id, NOW())
$$
DELIMITER ;
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
DELIMITER $$
CREATE TRIGGER `before_delete_movies` BEFORE DELETE ON `movies` FOR EACH ROW INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date)
VALUES ('movies', 'DELETE', OLD.mov_id, NOW())
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `nationalities`
--

CREATE TABLE `nationalities` (
  `nat_id` int(10) UNSIGNED NOT NULL COMMENT 'Nationalities ID',
  `nat_country` varchar(50) NOT NULL COMMENT 'Country name'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

CREATE TABLE `participates` (
  `part_pers_id` int(10) UNSIGNED NOT NULL,
  `part_job_id` int(10) UNSIGNED NOT NULL,
  `part_mov_id` int(10) UNSIGNED NOT NULL,
  `part_character_name` varchar(255) DEFAULT NULL
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

CREATE TABLE `persons` (
  `pers_id` int(10) UNSIGNED NOT NULL COMMENT 'Person ID',
  `pers_name` varchar(50) NOT NULL COMMENT 'Person name',
  `pers_firstname` varchar(50) NOT NULL COMMENT 'Person firstname',
  `pers_birthdate` date NOT NULL COMMENT 'Person birth date',
  `pers_deathdate` date DEFAULT NULL COMMENT 'person death date',
  `pers_nat_id` int(10) UNSIGNED DEFAULT NULL,
  `pers_bio` varchar(255) DEFAULT NULL COMMENT 'Person biography',
  `pers_photo` varchar(255) DEFAULT NULL COMMENT 'Person photo URL',
  `pers_updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `persons`
--

INSERT INTO `persons` (`pers_id`, `pers_name`, `pers_firstname`, `pers_birthdate`, `pers_deathdate`, `pers_nat_id`, `pers_bio`, `pers_photo`, `pers_updated_at`) VALUES
(3, 'Clarke', 'Arthur C.', '1917-12-16', '2008-03-19', 3, 'Stanley Kubrick est un réalisateur, scénariste et producteur américain, connu pour ses films cultes et son perfectionnisme extrême.', '69a5e69d9b550.webp', NULL),
(4, 'Nicholson', 'Jack', '1937-04-22', NULL, 4, 'David Lynch est un réalisateur, scénariste et artiste américain, connu pour son cinéma étrange et onirique, mêlant mystère, rêve et inquiétante étrangeté.', '69a5e7d22ca6e.webp', NULL),
(5, 'McDowell', 'Malcolm', '1943-06-13', NULL, 5, 'David Lynch est un réalisateur, scénariste et artiste américain, connu pour son cinéma étrange et onirique, mêlant mystère, rêve et inquiétante étrangeté.', '69a5e82ee52dc.webp', NULL),
(6, 'Ermey', 'R. Lee', '1944-03-24', '2018-04-15', 6, 'David Lynch est un réalisateur, scénariste et artiste américain, connu pour son cinéma étrange et onirique, mêlant mystère, rêve et inquiétante étrangeté.', '69a5e88781bea.webp', NULL),
(7, 'Kidman', 'Nicole', '1967-06-20', NULL, 7, 'David Lynch est un réalisateur, scénariste et artiste américain, connu pour son cinéma étrange et onirique, mêlant mystère, rêve et inquiétante étrangeté.', '69a5e84c31ead.webp', '2026-03-05 08:51:08'),
(8, 'Nance', 'Jack', '1943-12-21', '1996-12-30', 8, 'Stanley Kubrick est un réalisateur, scénariste et producteur américain, connu pour ses films cultes et son perfectionnisme extrême.', '69a5e7494b4fe.webp', NULL),
(9, 'Hurt', 'John', '1940-01-22', '2017-01-25', 9, 'Stanley Kubrick est un réalisateur, scénariste et producteur américain, connu pour ses films cultes et son perfectionnisme extrême.', '69a5e7ff4462f.webp', NULL),
(10, 'MacLachlan', 'Kyle', '1959-02-22', NULL, 10, 'Stanley Kubrick est un réalisateur, scénariste et producteur américain, connu pour ses films cultes et son perfectionnisme extrême.', '69a5e81b6d268.webp', '2026-03-05 08:51:39');

--
-- Déclencheurs `persons`
--
DELIMITER $$
CREATE TRIGGER `after_insert_persons` AFTER INSERT ON `persons` FOR EACH ROW INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date)
VALUES ('persons', 'INSERT', NEW.pers_id, NOW())
$$
DELIMITER ;
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
DELIMITER $$
CREATE TRIGGER `before_delete_persons` BEFORE DELETE ON `persons` FOR EACH ROW INSERT INTO history_contents (hist_table, hist_event, hist_elementid, hist_date)
VALUES ('persons', 'DELETE', OLD.pers_id, NOW())
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `photos`
--

CREATE TABLE `photos` (
  `pho_id` int(10) UNSIGNED NOT NULL COMMENT 'Photo ID',
  `pho_photo` varchar(255) NOT NULL COMMENT 'Photo URL',
  `pho_type` varchar(150) NOT NULL COMMENT 'Type of file',
  `pho_mov_id` int(10) UNSIGNED DEFAULT NULL,
  `pho_user_id` int(10) UNSIGNED DEFAULT NULL,
  `pho_updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `photos`
--

INSERT INTO `photos` (`pho_id`, `pho_photo`, `pho_type`, `pho_mov_id`, `pho_user_id`, `pho_updated_at`) VALUES
(3, '69a5e7e37fc0b.webp', 'Affiche', 13, NULL, NULL),
(4, '699b1f71abdce.webp', 'Affiche', 14, NULL, NULL),
(5, '69a5e3dd79e0b.webp', 'Affiche', 15, NULL, NULL),
(6, '69a5e426104c2.webp', 'Affiche', 16, NULL, '2026-03-04 14:13:03'),
(8, '69a5e3b090632.webp', 'Affiche', 18, NULL, NULL),
(9, '69a5e26e3598d.webp', 'Affiche', 19, NULL, NULL),
(10, '69a5e72eb9a5f.webp', 'Affiche', 20, NULL, '2026-03-04 14:13:31'),
(11, '6999936d5b186.webp', 'Affiche', 21, NULL, NULL),
(12, '69a5e4019c6ad.webp', 'Affiche', 22, NULL, NULL),
(14, '69a5e45a26090.webp', 'Affiche', 24, NULL, NULL),
(15, '69a5e8a206cb9.webp', 'Affiche', 25, NULL, NULL),
(50, '69a5f246c105e.webp', 'Affiche', 32, NULL, NULL),
(52, '69a83103d2c49.webp', 'Affiche', 33, NULL, NULL),
(54, '69a83295a1ef3.webp', 'Affiche', 35, NULL, NULL),
(55, '69a83539a9541.webp', 'Affiche', 36, NULL, NULL),
(56, '69a83646ad51e.webp', 'Affiche', 37, NULL, '2026-03-04 14:41:11'),
(57, '69a83726c30cb.webp', 'Affiche', 38, NULL, '2026-03-04 14:44:06'),
(58, '69a83b183251c.webp', 'Affiche', 39, NULL, '2026-03-04 15:42:19'),
(59, '69a83c1d5ec06.webp', 'Affiche', 40, NULL, NULL),
(60, '69a83fcb52e5b.webp', 'Affiche', 41, NULL, NULL),
(61, '69a88360360c7.webp', 'Affiche', 42, NULL, NULL),
(62, '69a965a8298f9.webp', 'Affiche', 43, NULL, '2026-03-05 12:14:48'),
(63, '69a88471d7404.webp', 'Affiche', 44, NULL, NULL),
(64, '69a8852a8a5c1.webp', 'Affiche', 45, NULL, NULL),
(65, '69a886149546a.webp', 'Affiche', 46, NULL, NULL),
(66, '', 'Affiche', 47, NULL, NULL),
(67, '69a888d930fd5.webp', 'Affiche', 48, NULL, NULL),
(68, '69a88b180f67c.webp', 'Affiche', 49, NULL, NULL),
(69, '69a88bee7b2e7.webp', 'Affiche', 50, NULL, NULL),
(76, '69a936f31f43d.jpg', 'Content', 13, 17, NULL),
(78, '69a94111b88f2.jpg', 'Content', 41, 17, NULL),
(79, '69a94d9bc5c7f.webp', 'Affiche', 51, NULL, NULL),
(80, '69a9975c5ac48.jpg', 'Content', 41, 41, NULL),
(81, '69a997e131af4.jpg', 'Content', 41, 38, NULL),
(82, '69a99991d64ac.jpg', 'Content', 41, 43, NULL),
(83, '69a99b9deeca9.webp', 'Affiche', 52, NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `ratings`
--

CREATE TABLE `ratings` (
  `rat_user_id` int(10) UNSIGNED NOT NULL,
  `rat_mov_id` int(10) UNSIGNED NOT NULL,
  `rat_score` decimal(2,1) NOT NULL
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
(17, 13, 3.5),
(17, 14, 2.5),
(17, 15, 4.0),
(17, 21, 5.0),
(17, 24, 5.0),
(17, 25, 4.5),
(17, 41, 5.0),
(17, 46, 4.5),
(23, 18, 5.0),
(23, 20, 0.5),
(23, 21, 2.0),
(23, 25, 4.0),
(23, 32, 0.5),
(32, 20, 0.5),
(32, 21, 2.5),
(33, 16, 5.0),
(33, 32, 0.5),
(33, 35, 4.5),
(33, 37, 5.0),
(33, 41, 5.0),
(35, 20, 3.5),
(35, 24, 5.0),
(38, 41, 5.0),
(40, 32, 4.5),
(41, 41, 5.0),
(42, 41, 5.0),
(43, 41, 5.0);

-- --------------------------------------------------------

--
-- Structure de la table `reports`
--

CREATE TABLE `reports` (
  `rep_id` int(10) UNSIGNED NOT NULL,
  `rep_reported_user_id` int(10) UNSIGNED DEFAULT NULL,
  `rep_reported_movie_id` int(10) UNSIGNED DEFAULT NULL,
  `rep_reported_com_id` int(10) UNSIGNED DEFAULT NULL,
  `rep_com_content` text DEFAULT NULL,
  `rep_pseudo_user` varchar(50) DEFAULT NULL,
  `rep_bio_user` varchar(255) DEFAULT NULL,
  `rep_date` datetime DEFAULT NULL,
  `rep_reporter_user_id` int(10) UNSIGNED DEFAULT NULL,
  `rep_reason` varchar(255) NOT NULL,
  `rep_deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `reports`
--

INSERT INTO `reports` (`rep_id`, `rep_reported_user_id`, `rep_reported_movie_id`, `rep_reported_com_id`, `rep_com_content`, `rep_pseudo_user`, `rep_bio_user`, `rep_date`, `rep_reporter_user_id`, `rep_reason`, `rep_deleted_at`) VALUES
(36, 5, NULL, NULL, NULL, 'keke_99', '', '2026-02-14 18:09:30', 25, 'test', '2026-02-21 21:09:38'),
(85, NULL, 21, NULL, NULL, NULL, NULL, '2026-02-25 21:38:37', 17, 'dqzdzdqd', '2026-03-04 09:33:58'),
(87, NULL, 25, NULL, NULL, NULL, NULL, '2026-03-02 15:39:00', 17, 'dqdqzdqz', '2026-03-04 09:33:59'),
(97, NULL, 38, NULL, NULL, NULL, NULL, '2026-03-04 14:42:34', 33, 'Il y a pas d\'image :(', '2026-03-04 15:32:37'),
(98, 35, NULL, NULL, NULL, 'Minou', 'Not exec($Minou)', '2026-03-04 15:44:05', 17, 'dqdzqdq', '2026-03-04 15:44:19'),
(100, 24, NULL, NULL, NULL, 'marcoooo', '', '2026-03-04 22:09:28', 17, 'dzqdqz', '2026-03-04 22:24:04'),
(101, 24, NULL, NULL, NULL, 'marcoooo', '', '2026-03-04 22:44:45', 17, 'dzqdzqdzq', '2026-03-05 15:18:22'),
(105, 42, NULL, 118, 'MIIIIIIIIIIIINOUUUUUUUUUUUUUUU LE GOAT', NULL, NULL, '2026-03-05 15:49:50', 41, 'Individu dangereux venant souvent au sanctuaire pour harceler minou. Faites attentions!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `user_id` int(10) UNSIGNED NOT NULL COMMENT 'User ID',
  `user_name` varchar(50) NOT NULL COMMENT 'User name',
  `user_firstname` varchar(50) NOT NULL COMMENT 'User first name',
  `user_pseudo` varchar(50) NOT NULL COMMENT 'User pseudo',
  `user_email` varchar(255) NOT NULL COMMENT 'User email',
  `user_birthdate` date NOT NULL COMMENT 'User Birthdate',
  `user_creadate` datetime NOT NULL COMMENT 'User accounts creation date',
  `user_funct_id` int(10) UNSIGNED DEFAULT 1,
  `user_bio` varchar(255) DEFAULT NULL COMMENT 'User biography',
  `user_photo` varchar(255) DEFAULT NULL COMMENT 'User profile photo URL',
  `user_pwd` varchar(255) NOT NULL,
  `user_deleted_at` datetime DEFAULT NULL,
  `user_updated_at` datetime DEFAULT NULL,
  `user_ban_at` datetime DEFAULT NULL,
  `user_reason_ban` varchar(255) DEFAULT NULL,
  `user_reset_token` varchar(255) DEFAULT NULL,
  `user_reset_expires` datetime DEFAULT NULL,
  `user_reset_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`user_id`, `user_name`, `user_firstname`, `user_pseudo`, `user_email`, `user_birthdate`, `user_creadate`, `user_funct_id`, `user_bio`, `user_photo`, `user_pwd`, `user_deleted_at`, `user_updated_at`, `user_ban_at`, `user_reason_ban`, `user_reset_token`, `user_reset_expires`, `user_reset_at`) VALUES
(1, 'Dubois', 'Thomas', 'tom_dubois', 'thomas.dubois@exemple.com', '1990-05-15', '2024-01-10 09:00:00', 3, NULL, NULL, '', '2026-02-07 16:32:25', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 'Leroy', 'Marie', 'mary_l', 'marie.leroy@exemple.com', '1985-11-20', '2024-01-12 10:30:00', 2, NULL, NULL, '', '2026-02-10 17:04:20', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 'Martin', 'Lucas', '', 'lucas.martin@exemple.com', '1998-03-08', '2024-01-15 14:15:00', 2, NULL, NULL, '', '2026-02-11 18:12:50', NULL, '3025-03-02 00:00:00', 'dzqdzq', NULL, NULL, NULL),
(4, 'Bernard', 'Sophie', 'sophie_bb', 'sophie.bernard@exemple.com', '1992-07-22', '2024-02-01 11:00:00', 2, '', '69a84f41a2b3a.webp', '', NULL, '2026-03-04 16:29:07', NULL, NULL, NULL, NULL, NULL),
(5, 'Petit', 'Kevin', 'keke_99', 'kevin.petit@exemple.com', '1999-12-01', '2024-02-10 16:45:00', 2, NULL, NULL, '', NULL, NULL, NULL, 'Parce que!', NULL, NULL, NULL),
(6, 'Robert', 'Camille', 'cam_rob', 'camille.robert@exemple.com', '1995-09-14', '2024-02-20 08:20:00', 1, '', '69a932145c2c1.webp', '', NULL, '2026-03-05 08:34:44', NULL, NULL, NULL, NULL, NULL),
(7, 'Richard', 'Antoinedzqdqz', 'tony_ric', 'antoine.richard@exemple.com', '1988-02-28', '2024-03-05 13:10:00', 3, '', 'defaultImgUser.jpg', '', NULL, '2026-02-19 22:34:05', NULL, NULL, NULL, NULL, NULL),
(8, 'Durand', 'Léa', 'lele_d', 'lea.durand@exemple.com', '2001-06-30', '2024-03-12 18:00:00', 1, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(9, 'Moreau', 'Nathan', 'nate_m', 'nathan.moreau@exemple.com', '1993-04-10', '2024-03-25 09:45:00', 1, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(10, 'Simon', 'Sarah', 's_simon', 'sarah.simon@exemple.com', '1982-08-05', '2024-04-01 12:00:00', 3, '', '69a932eea2d62.webp', '', NULL, '2026-03-05 15:18:47', NULL, NULL, NULL, NULL, NULL),
(17, 'MARCO', 'Marco', 'Testzzzzzzzz', 'slendsher48@gmail.com', '2006-03-22', '2026-02-05 15:50:29', 3, 'zdqdqdqzddqzdqdzqdqdzqzd zdzqdzqd', '69a59fbcc84a4.png', '$2y$10$Grw/XVwbShpIgK40Wx52.e9vAvhozt4rYgAFQHSxv0nDj/BI/4Ad.', NULL, '2026-03-02 15:33:32', NULL, NULL, 'e0c58385a48393613997e043977755b942d7abfcec642f0a7cc2a62e3629795c9cddde87e08c5339d94eb10049a9613458cad65f58c67f4e08c63c4f11c45909', '2026-03-05 16:30:54', NULL),
(23, 'SCHMITT', 'MARCO', 'Truc', '', '2222-02-22', '2026-02-08 15:12:38', 2, '', '69a46168ac5d7.png', '$2y$10$ZWiLqzPoxwvP5KSCRW.Ac.VDgw41CLBalyfmtQ3jolT062c78.M2W', '2026-03-04 16:11:08', '2026-03-01 16:55:20', '2026-03-28 15:59:02', NULL, '5912be52aa133031e6503e2d46a9f07f270a45d318dafd0e7e4c67d16c0d2d237679ec3d752853981dd006f5f535cc2c93b48b614a8a26d419984c3ddc25139e', '2026-03-04 15:57:49', NULL),
(24, 'SCHMITT', 'MARCOOOOOOO', 'marcoooo', 'test@gmail.com', '2222-02-22', '2026-02-09 08:55:06', 2, '', '698b57ac34581.png', '$2y$10$QtZit0YtsMgqojOEnlsi6eQcph6yTiI.RuxXqRNI29ZlTXpMPoc6a', NULL, '2026-02-20 22:11:38', NULL, NULL, NULL, NULL, NULL),
(25, 'dqzzdq', 'dzqdzq', 'user', 'user@gmail.com', '2222-02-22', '2026-02-13 11:12:08', 1, NULL, NULL, '$2y$12$VMEuNAGgcYnmr13mM7Sy3.naxE/pgFRbal1ujYj6hsHKF.nEUAz8G', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(32, 'Sonntag', 'Audrey', 'Audrawww', 'sonntagaudrey@yahoo.fr', '1982-11-15', '2026-03-04 14:12:54', 1, '', '69a83249b4ab9.jpg', '$2y$10$LfKbesgdvUYwRhOIqiYIEOLI/3rza7NP.daJdf9XBgQgRVsFXY8Tu', NULL, '2026-03-04 14:23:21', NULL, NULL, '2fc0a22477238c53d10da6830831e368e9e0530e1b840897db0b162bb25a4611b0812594558a00056368ac04fb5a4caca0933b28d42b778190e5fc804825f62b', '2026-03-04 16:22:04', NULL),
(33, 'FERRY', 'Etienne', 'ruin-e', 'e.ferry607@gmail.com', '1996-05-23', '2026-03-04 14:15:42', 3, '', '69a84e21d0945.webp', '$2y$10$MMpVDCV2o4o3gPrmySolSOPmNOuyPBsFXpUTFOjtLC0K5Z8NHEQli', NULL, '2026-03-04 16:22:09', NULL, NULL, '1a9dc0ce5c14fa86af856eb621fdfa59de183b2b2e96c2c1cae22ee86e8578e0804d4481b706c3216b6313e86d0da2f731898f58ac2c739a1c13c461ae83e764', '2026-03-04 16:40:02', NULL),
(34, 'Golinki', 'Audrey Marie Evelyne', 'Error404', 'lamu151182@gmail.com', '1982-03-05', '2026-03-04 14:45:13', 3, '', '69a8380f720d4.png', '$2y$10$YjYB.JBSVCHj/B/0p.3uAuTuDraOLqxaJFBceWS4Spd42oLtIg11m', NULL, '2026-03-04 14:47:59', NULL, NULL, NULL, NULL, NULL),
(35, 'Sonntag', 'Maya', 'Minou', 'sailormoon0183@gmail.com', '2008-07-28', '2026-03-04 14:51:24', 1, 'Not exec($Minou)', '69a839c9d2609.jpg', '$2y$10$MC5o..H6b3rUvvhYWDYpMu60NTaaInYLGTDpcCD7KJf8zk3xGuxG6', NULL, '2026-03-04 14:55:21', NULL, NULL, NULL, NULL, NULL),
(36, 'Schulz', 'Julie', 'Le J c le S', 'lalala@gmail.com', '1996-11-20', '2026-03-04 16:34:18', 2, NULL, NULL, '$2y$10$m/ehQxWcVHFFZRQIsWatWu0qVQhgafovi47W22x/k8uZMminLELN6', NULL, '2026-03-04 16:49:01', NULL, NULL, NULL, NULL, NULL),
(37, 'Jean', 'Bonbeurre', 'Nicky', 'ludinski@gmail.com', '1978-06-25', '2026-03-04 18:37:05', 1, 'Fan de Mangas et de films en tout genre', '69a88832de213.webp', '$2y$10$GMJHbtQVcGmR7pYKyrHZwe8m8TrLBVIBo3ktZQEv/PRYnoQspWLyu', NULL, '2026-03-04 20:29:54', NULL, NULL, NULL, NULL, NULL),
(38, 'Grisou', 'Grisouuuuuuu', 'Mégane', 'grisou.grisou@gmail.com', '1950-08-23', '2026-03-05 00:28:48', 1, '', '69a8c0bbb6684.webp', '$2y$10$7Rulsx6eBp4ABSN.zrqZ7uv8YNDvWjAz8sX/I2BM79qJwpiwYveB6', NULL, '2026-03-05 16:15:42', NULL, NULL, NULL, NULL, NULL),
(39, 'Jesuisunmoderateur', 'Moderateur', 'mot d\'eau', 'jesuisunmoderateur@gmail.com', '1996-03-12', '2026-03-05 10:20:30', 2, NULL, NULL, '$2y$10$NKUYjbZgZWJR2PKGp2yf1u8ls5WtbgTTxu6VNhfBrGAs2UH2rCK5.', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(40, 'unUtilisateur', 'User', 'UserTroCool', 'userutilisateurutile@gmail.com', '1996-03-12', '2026-03-05 10:24:03', 1, '', 'defaultImgUser.jpg', '$2y$10$HLrND/AVQ7Sthv6HS8QF/ei0h32J38hzRVlFovIOi1gFDz9P9PA3G', NULL, '2026-03-05 10:25:51', NULL, NULL, NULL, NULL, NULL),
(41, 'Burdloff', 'Kévin', 'Beardwulf', 'burdloffkevin@gmail.com', '1992-05-14', '2026-03-05 15:45:18', 1, '', '69a997d151290.webp', '$2y$10$h.QWpmpKlzOIWcYly5QZ1uSYf6NwkJJVVji4FkticpEmzM492kEzW', NULL, '2026-03-05 15:48:49', NULL, NULL, NULL, NULL, NULL),
(42, 'Boulayoune', 'Yasser', 'Yasder5', 'ressaygaming753@gmail.com', '2005-05-14', '2026-03-05 15:47:22', 1, '', '69a99ab163f4c.webp', '$2y$10$gXL1JSzlrpgUcdOUXRFazezmfg0NZQ.rM1pvhLoH3VUetZ9aUEYTG', NULL, '2026-03-05 16:01:05', NULL, NULL, '7f43db955c4041b0ab764167e02a979c8f14c7b10849355e6799df0afa1bb814e0d1ac788bb28ece0b2d764412954902c5e06c224f45e56cc1054f1b94b92fb1', '2026-03-05 16:18:47', NULL),
(43, 'Chevillet', 'Laura', 'Laura', 'chevillet.laura@gmail.com', '1994-06-04', '2026-03-05 15:55:21', 1, '', '69a99b702c9ec.webp', '$2y$10$LGjDeSnJgN22R5vDQ2O8Nujbre6t3Wa6tUg5gO7uNRrCFnXEU8Wwe', NULL, '2026-03-05 16:04:16', NULL, NULL, NULL, NULL, NULL);

--
-- Déclencheurs `users`
--
DELIMITER $$
CREATE TRIGGER `after_insert_user` AFTER INSERT ON `users` FOR EACH ROW INSERT INTO history_users (hist_table, hist_event, hist_elementid, hist_date)
    VALUES('users', 'INSERT', NEW.user_id, NOW())
$$
DELIMITER ;
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
DELIMITER $$
CREATE TRIGGER `before_delete_user` BEFORE DELETE ON `users` FOR EACH ROW INSERT INTO history_users (hist_table, hist_event, hist_elementid, hist_date)
    VALUES('users', 'DELETE', OLD.user_id, NOW())
$$
DELIMITER ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `belongs`
--
ALTER TABLE `belongs`
  ADD PRIMARY KEY (`belong_cat_id`,`belong_mov_id`),
  ADD KEY `fk_belong_mov_id` (`belong_mov_id`);

--
-- Index pour la table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`cat_id`);

--
-- Index pour la table `comments`
--
ALTER TABLE `comments`
  ADD PRIMARY KEY (`com_id`),
  ADD UNIQUE KEY `id_user_movie` (`com_user_id`,`com_movie_id`),
  ADD KEY `fk_com_user_id` (`com_user_id`),
  ADD KEY `fk_com_movie_id` (`com_movie_id`);

--
-- Index pour la table `functions`
--
ALTER TABLE `functions`
  ADD PRIMARY KEY (`funct_id`);

--
-- Index pour la table `history_comments`
--
ALTER TABLE `history_comments`
  ADD PRIMARY KEY (`hist_id`);

--
-- Index pour la table `history_contents`
--
ALTER TABLE `history_contents`
  ADD PRIMARY KEY (`hist_id`);

--
-- Index pour la table `history_users`
--
ALTER TABLE `history_users`
  ADD PRIMARY KEY (`hist_id`);

--
-- Index pour la table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`job_id`);

--
-- Index pour la table `liked`
--
ALTER TABLE `liked`
  ADD UNIQUE KEY `uk_like_movie` (`lik_user_id`,`lik_mov_id`),
  ADD UNIQUE KEY `uk_like_comment` (`lik_user_id`,`lik_com_id`),
  ADD KEY `FK_com_like` (`lik_com_id`),
  ADD KEY `FK_mov_like` (`lik_mov_id`);

--
-- Index pour la table `login_attempts`
--
ALTER TABLE `login_attempts`
  ADD PRIMARY KEY (`attempt_id`),
  ADD KEY `index_ip_date` (`attempt_ip`,`attempt_datetime`);

--
-- Index pour la table `logs_users`
--
ALTER TABLE `logs_users`
  ADD PRIMARY KEY (`log_id`);

--
-- Index pour la table `movies`
--
ALTER TABLE `movies`
  ADD PRIMARY KEY (`mov_id`),
  ADD KEY `fk_movies_nationality` (`mov_nat_id`);

--
-- Index pour la table `nationalities`
--
ALTER TABLE `nationalities`
  ADD PRIMARY KEY (`nat_id`);

--
-- Index pour la table `participates`
--
ALTER TABLE `participates`
  ADD PRIMARY KEY (`part_pers_id`,`part_job_id`,`part_mov_id`),
  ADD KEY `fk_part_job_id` (`part_job_id`),
  ADD KEY `fk_part_mov_id` (`part_mov_id`);

--
-- Index pour la table `persons`
--
ALTER TABLE `persons`
  ADD PRIMARY KEY (`pers_id`),
  ADD KEY `fk_pers_nat_id` (`pers_nat_id`);

--
-- Index pour la table `photos`
--
ALTER TABLE `photos`
  ADD PRIMARY KEY (`pho_id`),
  ADD UNIQUE KEY `uk_mov_user_id` (`pho_mov_id`,`pho_user_id`),
  ADD KEY `fk_pho_mov_id` (`pho_mov_id`);

--
-- Index pour la table `ratings`
--
ALTER TABLE `ratings`
  ADD PRIMARY KEY (`rat_user_id`,`rat_mov_id`),
  ADD KEY `fk_ratings_movies` (`rat_mov_id`);

--
-- Index pour la table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`rep_id`),
  ADD KEY `fk_rep_reported_user` (`rep_reported_user_id`),
  ADD KEY `fk_rep_reported_mov` (`rep_reported_movie_id`),
  ADD KEY `fk_rep_reported_com` (`rep_reported_com_id`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `unique_email` (`user_email`),
  ADD UNIQUE KEY `unique_pseudo` (`user_pseudo`),
  ADD KEY `fk_user_funct_id` (`user_funct_id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `categories`
--
ALTER TABLE `categories`
  MODIFY `cat_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Categories ID', AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `comments`
--
ALTER TABLE `comments`
  MODIFY `com_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Comment ID', AUTO_INCREMENT=120;

--
-- AUTO_INCREMENT pour la table `functions`
--
ALTER TABLE `functions`
  MODIFY `funct_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Function ID', AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `history_comments`
--
ALTER TABLE `history_comments`
  MODIFY `hist_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=82;

--
-- AUTO_INCREMENT pour la table `history_contents`
--
ALTER TABLE `history_contents`
  MODIFY `hist_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT pour la table `history_users`
--
ALTER TABLE `history_users`
  MODIFY `hist_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=119;

--
-- AUTO_INCREMENT pour la table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `job_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Jobs ID', AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `login_attempts`
--
ALTER TABLE `login_attempts`
  MODIFY `attempt_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT pour la table `logs_users`
--
ALTER TABLE `logs_users`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=256;

--
-- AUTO_INCREMENT pour la table `movies`
--
ALTER TABLE `movies`
  MODIFY `mov_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Movie Id', AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT pour la table `nationalities`
--
ALTER TABLE `nationalities`
  MODIFY `nat_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Nationalities ID', AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `persons`
--
ALTER TABLE `persons`
  MODIFY `pers_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Person ID', AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `photos`
--
ALTER TABLE `photos`
  MODIFY `pho_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Photo ID', AUTO_INCREMENT=84;

--
-- AUTO_INCREMENT pour la table `reports`
--
ALTER TABLE `reports`
  MODIFY `rep_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=106;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'User ID', AUTO_INCREMENT=44;

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
  ADD CONSTRAINT `FK_com_like` FOREIGN KEY (`lik_com_id`) REFERENCES `comments` (`com_id`) ON DELETE CASCADE,
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
