
CREATE TABLE IF NOT EXISTS `kd` (
  `identifier` varchar(50) NOT NULL,
  `kd` int(11) NOT NULL DEFAULT 0,
  `kill` int(11) NOT NULL DEFAULT 0,
  `morti` int(11) NOT NULL DEFAULT 0,
  `redzonekd` int(11) NOT NULL DEFAULT 0,
  `redzonekill` int(11) NOT NULL DEFAULT 0,
  `redzonemorti` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`identifier`),
  UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4


