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

-- Structuur van  tabel voorthuishtmlpages.tb110_images wordt geschreven
CREATE TABLE IF NOT EXISTS `tb110_images` (
  `Name` varchar(50) NOT NULL,
  `IndexNr` int(11) NOT NULL,
  `Description` varchar(50) NOT NULL DEFAULT '',
  `ImagePathHTML` varchar(400) DEFAULT NULL,
  `ImageSource` varchar(400) DEFAULT NULL,
  PRIMARY KEY (`IndexNr`,`Name`) USING BTREE,
  KEY `Description` (`Description`),
  Index `tb110_images_idx` (`Description`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumpen data van tabel voorthuishtmlpages.tb110_images: ~10 rows (ongeveer)
/*!40000 ALTER TABLE `tb110_images` DISABLE KEYS */;
REPLACE INTO `tb110_images` (`Name`, `IndexNr`, `Description`, `ImagePathHTML`, `ImageSource`) VALUES
	('DraaikaarsOmbre', 1, 'Draaikaars blauw/zwart, per twee', '<img onclick="imageClick(src, title);" title="Draaikaars blauw/zwart, per twee" class="smallImage" src="images/dinerKaarsen/gedraaideKaarsOmbre/43d4ef95-0bdf-497f-ba4a-7f58db1c11af.jpg"/>', 'images/dinerKaarsen/gedraaideKaarsOmbre/43d4ef95-0bdf-497f-ba4a-7f58db1c11af.jpg'),
	('DraaikaarsOmbre', 2, 'Draaikaars roze/zwart, met candle wax kandelaar', '<img onclick="imageClick(src, title);" title="Draaikaars roze/zwart, met candle wax kandelaar" class="smallImage" src="images/dinerKaarsen/gedraaideKaarsOmbre/bc15e519-3927-4dfa-ac42-de831abe3084.jpg"/>', 'images/dinerKaarsen/gedraaideKaarsOmbre/bc15e519-3927-4dfa-ac42-de831abe3084.jpg'),
	('DraaikaarsOmbre', 3, 'Draaikaars grijs/zwart', '<img onclick="imageClick(src, title);" title="Draaikaars grijs/zwart" class="smallImage" src="images/dinerKaarsen/gedraaideKaarsOmbre/c0eae43e-5325-46f5-9578-3ac8f0930647.jpg"/>', 'images/dinerKaarsen/gedraaideKaarsOmbre/c0eae43e-5325-46f5-9578-3ac8f0930647.jpg'),
	('DraaikaarsOmbre', 4, 'Draaikaars wit/zwart', '<img onclick="imageClick(src, title);" title="Draaikaars wit/zwart" class="smallImage" src="images/dinerKaarsen/gedraaideKaarsOmbre/f4d7fc24-b32d-48f5-8cb3-6c747ff87d99.jpg"/>', 'images/dinerKaarsen/gedraaideKaarsOmbre/f4d7fc24-b32d-48f5-8cb3-6c747ff87d99.jpg'),
	('DraaikaarsOmbre', 5, 'Draaikaars roze/oranje, per twee', '<img onclick="imageClick(src, title);" title="Draaikaars roze/oranje, per twee" class="smallImage" src="images/dinerKaarsen/gedraaideKaarsOmbre/32070aef-6fdb-4f37-8714-dff379e6533d.jpg"/>', 'images/dinerKaarsen/gedraaideKaarsOmbre/32070aef-6fdb-4f37-8714-dff379e6533d.jpg'),
	('DraaikaarsOmbre', 6, 'Draaikaars licht-/donkerroze, per twee', '<img onclick="imageClick(src, title);" title="Draaikaars licht-/donkerroze, per twee" class="smallImage" src="images/dinerKaarsen/gedraaideKaarsOmbre/1bfba8aa-6cd1-479a-8ef4-7439ed929cdd.jpg"/>', 'images/dinerKaarsen/gedraaideKaarsOmbre/1bfba8aa-6cd1-479a-8ef4-7439ed929cdd.jpg'),
	('DraaikaarsOmbre', 7, 'Draaikaars groen/paars', '<img onclick="imageClick(src, title);" title="Draaikaars groen/paars" class="smallImage" src="images/dinerKaarsen/gedraaideKaarsOmbre/c3b7f087-da44-4827-8791-6bc28cc138f2.jpg"/>', 'images/dinerKaarsen/gedraaideKaarsOmbre/c3b7f087-da44-4827-8791-6bc28cc138f2.jpg'),
	('DraaikaarsOmbre', 8, 'Draaikaars wit/bordeaux', '<img onclick="imageClick(src, title);" title="Draaikaars wit/bordeaux" class="smallImage" src="images/dinerKaarsen/gedraaideKaarsOmbre/0c974640-1eee-4acc-8028-7d202a048e69.jpg"/>', 'images/dinerKaarsen/gedraaideKaarsOmbre/0c974640-1eee-4acc-8028-7d202a048e69.jpg'),
	('DraaikaarsOmbre', 9, 'Draaikaars wit/bordeaux, per twee', '<img onclick="imageClick(src, title);" title="Draaikaars wit/bordeaux, per twee" class="smallImage" src="images/dinerKaarsen/gedraaideKaarsOmbre/85d13d87-46a1-4d32-b08e-2eea9a18f374.jpg"/>', 'images/dinerKaarsen/gedraaideKaarsOmbre/85d13d87-46a1-4d32-b08e-2eea9a18f374.jpg'),
	('DraaikaarsOmbre', 10, 'Draaikaars gemengd. (Set van 24)', '<img onclick="imageClick(src, title);" title="Draaikaars gemengd. (Set van 24)" class="smallImage" src="images/dinerKaarsen/gedraaideKaarsOmbre/cf3e54ed-b4a8-49dd-af2b-7b0970f14004.jpg"/>', 'images/dinerKaarsen/gedraaideKaarsOmbre/cf3e54ed-b4a8-49dd-af2b-7b0970f14004.jpg');
/*!40000 ALTER TABLE `tb110_images` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
