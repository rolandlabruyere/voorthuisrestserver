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


-- Databasestructuur van htmlpages wordt geschreven
CREATE DATABASE IF NOT EXISTS `htmlpages` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `htmlpages`;

-- Structuur van  tabel htmlpages.tb230_metricwire wordt geschreven
CREATE TABLE IF NOT EXISTS `tb230_metricwire` (
  `Diameter` decimal(4,2) NOT NULL,
  `Doorsnede` decimal(5,3) DEFAULT NULL,
  `MaxAmp` decimal(4,2) DEFAULT NULL,
  PRIMARY KEY (`Diameter`),
  KEY `MaxAmp` (`MaxAmp`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumpen data van tabel htmlpages.tb230_metricwire: ~30 rows (ongeveer)
INSERT INTO `tb230_metricwire` (`Diameter`, `Doorsnede`, `MaxAmp`) VALUES
	(0.05, 0.002, 0.02),
	(0.08, 0.005, 0.06),
	(0.10, 0.008, 0.09),
	(0.12, 0.011, 0.14),
	(0.15, 0.018, 0.21),
	(0.18, 0.026, 0.31),
	(0.20, 0.031, 0.38),
	(0.25, 0.049, 0.59),
	(0.30, 0.071, 0.85),
	(0.35, 0.096, 1.15),
	(0.40, 0.126, 1.50),
	(0.45, 0.159, 1.90),
	(0.50, 0.196, 2.35),
	(0.55, 0.238, 2.85),
	(0.60, 0.283, 3.40),
	(0.65, 0.332, 4.00),
	(0.70, 0.385, 4.60),
	(0.75, 0.442, 5.30),
	(0.80, 0.503, 6.00),
	(0.90, 0.686, 7.00),
	(1.00, 0.785, 9.40),
	(1.10, 0.950, 11.40),
	(1.20, 1.000, 13.60),
	(1.30, 1.000, 15.90),
	(1.40, 2.000, 18.50),
	(1.50, 2.000, 21.20),
	(1.60, 2.000, 24.10),
	(1.80, 3.000, 30.50),
	(2.00, 3.000, 37.70),
	(2.50, 5.000, 59.00);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
