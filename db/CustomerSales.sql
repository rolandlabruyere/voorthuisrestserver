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


-- Databasestructuur van CustomerSales wordt geschreven
CREATE DATABASE IF NOT EXISTS `CustomerSales` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `CustomerSales`;

-- Structuur van  tabel CustomerSales.tb100_customer wordt geschreven
CREATE TABLE IF NOT EXISTS `tb100_customer` (
  `id` mediumint(9) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `tb100_customer_idx` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumpen data van tabel CustomerSales.tb100_customer: ~0 rows (ongeveer)

-- Structuur van  tabel CustomerSales.tb110_address wordt geschreven
CREATE TABLE IF NOT EXISTS `tb110_address` (
  `id` mediumint(9) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `tb110_address_idx` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumpen data van tabel CustomerSales.tb110_address: ~0 rows (ongeveer)

-- Structuur van  tabel CustomerSales.tb200_article wordt geschreven
CREATE TABLE IF NOT EXISTS `tb200_article` (
  `Name` varchar(50) NOT NULL DEFAULT '0',
  `IndexId` int(11) NOT NULL DEFAULT 0,
  `RetailPrice` float NOT NULL DEFAULT 0,
  `Weight` int(11) NOT NULL DEFAULT 0,
  `EstimateBurnTime` int(11) NOT NULL DEFAULT 0,
  `NumOfMoldsPresent` int(11) NOT NULL DEFAULT 0,
  `MoldType` varchar(50) NOT NULL DEFAULT '0',
  PRIMARY KEY (`IndexId`,`Name`) USING BTREE,
  KEY `tb200_article_idx` (`IndexId`,`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumpen data van tabel CustomerSales.tb200_article: ~0 rows (ongeveer)

-- Structuur van  tabel CustomerSales.tb300_shoppingcart wordt geschreven
CREATE TABLE IF NOT EXISTS `tb300_shoppingcart` (
  `ClientId` varchar(36) NOT NULL,
  `GotItems` tinyint(1) DEFAULT NULL,
  `Timestamp` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`ClientId`),
  KEY `tb300_shoppingcart_idx` (`ClientId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumpen data van tabel CustomerSales.tb300_shoppingcart: ~0 rows (ongeveer)

-- Structuur van  tabel CustomerSales.tb310_shoppingcartitems wordt geschreven
CREATE TABLE IF NOT EXISTS `tb310_shoppingcartitems` (
  `ClientId` varchar(36) NOT NULL,
  `OrderRow` int(11) NOT NULL DEFAULT 0,
  `Description` varchar(50) NOT NULL,
  `IndexNr` int(11) NOT NULL,
  `itemsOrdered` int(11) DEFAULT NULL,
  `Price` float DEFAULT NULL,
  `totalItemPrice` float DEFAULT NULL,
  `Timestamp` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`ClientId`,`OrderRow`) USING BTREE,
  KEY `tb310_shoppingcartitems_idx` (`ClientId`,`OrderRow`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumpen data van tabel CustomerSales.tb310_shoppingcartitems: ~0 rows (ongeveer)

-- Structuur van  tabel CustomerSales.tb900_sessionsettings wordt geschreven
CREATE TABLE IF NOT EXISTS `tb900_sessionsettings` (
  `ip` varchar(15) NOT NULL,
  `SessionActive` tinyint(1) NOT NULL DEFAULT 0,
  `Timestamp` varchar(25) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ip`),
  KEY `Index 1` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumpen data van tabel CustomerSales.tb900_sessionsettings: ~1 rows (ongeveer)
INSERT INTO `tb900_sessionsettings` (`ip`, `SessionActive`, `Timestamp`) VALUES
	('077.173.243.036', 1, '2024-07-25 10:31:51:072');

-- Structuur van  view CustomerSales.vw200_pricelist wordt geschreven
-- Tijdelijke tabel wordt aangemaakt zodat we geen VIEW afhankelijkheidsfouten krijgen
CREATE TABLE `vw200_pricelist` (
	`Name` VARCHAR(50) NOT NULL COLLATE 'latin1_swedish_ci',
	`IndexNr` INT(11) NOT NULL,
	`Description` VARCHAR(50) NOT NULL COLLATE 'latin1_swedish_ci',
	`Price` FLOAT NOT NULL,
	`Weight` INT(11) NOT NULL,
	`BurningTime` INT(11) NOT NULL,
	`ImagePathHTML` VARCHAR(400) NULL COLLATE 'latin1_swedish_ci'
) ENGINE=MyISAM;

-- Tijdelijke tabel wordt verwijderd, en definitieve VIEW wordt aangemaakt.
DROP TABLE IF EXISTS `vw200_pricelist`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw200_pricelist` AS SELECT b.Name AS Name, b.IndexNr AS IndexNr, b.Description AS Description, a.RetailPrice AS Price, a.Weight, a.EstimateBurnTime AS BurningTime, b.ImagePathHTML 
FROM CustomerSales.TB200_Article a, VoorThuisHtmlPages.TB110_Images b
WHERE a.Name = b.Name
AND a.IndexId = b.IndexNr ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
