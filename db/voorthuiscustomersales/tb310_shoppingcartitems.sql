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

-- Structuur van  tabel voorthuiscustomersales.tb310_shoppingcartitems wordt geschreven
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
    Index `tb310_shoppingcartitems_idx` (`ClientId`,`OrderRow`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Data exporteren was gedeselecteerd

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
