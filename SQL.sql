CREATE TABLE IF NOT EXISTS `user_inventory2` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_id` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '0',
  `information` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '0',
  `slot` int(11) NOT NULL,
  `dropped` tinyint(4) NOT NULL DEFAULT 0,
  `quality` int(11) DEFAULT 100,
  `creationDate` bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


