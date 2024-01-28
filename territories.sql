CREATE TABLE IF NOT EXISTS `blombinoterritories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(50) DEFAULT NULL,
  `owner` varchar(50) DEFAULT NULL,
  `claiming` varchar(50) DEFAULT NULL,
  `influence` float NOT NULL DEFAULT 0,
  `coords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `cooldown` int(11) NOT NULL DEFAULT 0,
  `radius` int(11) NOT NULL DEFAULT 0,
  `lastclaimed` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8;