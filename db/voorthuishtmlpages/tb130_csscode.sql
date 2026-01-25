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

-- Structuur van  tabel voorthuishtmlpages.tb130_csscode wordt geschreven
CREATE TABLE IF NOT EXISTS `tb130_csscode` (
  `Id` varchar(50) NOT NULL,
  `PlaceHolder` varchar(50) DEFAULT NULL,
  `CssCode` mediumtext DEFAULT NULL,
  PRIMARY KEY (`Id`),
  Index `tb130_csscode_idx` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumpen data van tabel voorthuishtmlpages.tb130_csscode: ~0 rows (ongeveer)
/*!40000 ALTER TABLE `tb130_csscode` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb130_csscode` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
