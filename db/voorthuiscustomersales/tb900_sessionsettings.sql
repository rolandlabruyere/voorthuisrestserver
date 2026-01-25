-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server versie:                10.11.2-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Versie:              11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Structuur van  tabel voorthuiscustomersales.tb900_sessionsettings wordt geschreven
CREATE TABLE IF NOT EXISTS `tb900_sessionsettings` (
  `SessionId` varchar(20) NOT NULL,
  `ip_v4` varchar(15) NOT NULL,
  `ClientId` varchar(36) NOT NULL DEFAULT '0',
  `SessionActive` tinyint(1) NOT NULL DEFAULT 0,
  `Timestamp` varchar(25) NOT NULL DEFAULT '0',
  PRIMARY KEY (`SessionId`,`ip_v4`),
  KEY `ClientId` (`ClientId`),
    Index `tb900_sessionsettings_idx` (`ClientId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Data exporteren was gedeselecteerd

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
