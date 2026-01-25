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

-- Structuur van  view voorthuiscustomersales.vw200_pricelist wordt geschreven
-- Tijdelijke tabel wordt verwijderd, en definitieve VIEW wordt aangemaakt.
DROP TABLE IF EXISTS `vw200_pricelist`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw200_pricelist` AS SELECT b.Name AS Name, b.IndexNr AS IndexNr, b.Description AS description, a.RetailPrice AS Price, a.Weight, a.EstimateBurnTime AS BurningTime, b.ImagePathHTML 
FROM VoorthuisCustomerSales.TB200_Article a, VoorThuisHtmlPages.TB110_Images b
WHERE a.Name = b.Name
AND a.IndexId = b.IndexNr ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
