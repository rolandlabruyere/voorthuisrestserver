-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server versie:                11.3.2-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Versie:              12.6.0.6765
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Structuur van  tabel customersales.tb200_trafoconfig wordt geschreven
CREATE TABLE IF NOT EXISTS `tb200_trafoconfig` (
  `ip` varchar(15) NOT NULL DEFAULT '0',
  `TrafoNum` varchar(20) NOT NULL DEFAULT '0',
  `secundary` tinyint(4) NOT NULL DEFAULT 0,
  `centerTap` tinyint(4) NOT NULL DEFAULT 0,
  `tapFiftyVolt` tinyint(4) NOT NULL DEFAULT 0,
  `filamentFiveVolt` tinyint(4) NOT NULL DEFAULT 0,
  `filamentSixVolt` tinyint(4) NOT NULL DEFAULT 0,
  `filamentTwelveVolt` tinyint(4) NOT NULL DEFAULT 0,
  `filamentCenterTap` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`ip`,`TrafoNum`),
  KEY `TrafoNum` (`TrafoNum`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumpen data van tabel customersales.tb200_trafoconfig: ~0 rows (ongeveer)

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
