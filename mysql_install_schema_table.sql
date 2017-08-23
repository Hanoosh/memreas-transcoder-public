-- MySQL dump 10.13  Distrib 5.6.24, for osx10.8 (x86_64)
--
-- Host: memreasdevdb.co0fw2snbu92.us-east-1.rds.amazonaws.com    Database: memreasbackenddb
-- ------------------------------------------------------
-- Server version	5.6.27-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `server_monitor`
--

DROP TABLE IF EXISTS `server_monitor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `server_monitor` (
  `server_id` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `server_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `server_addr` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `hostname` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `status` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `job_count` int(11) NOT NULL,
  `cpu_util_1min` float NOT NULL,
  `cpu_util_5min` float NOT NULL,
  `cpu_util_15min` float NOT NULL,
  `last_cpu_check` datetime NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime DEFAULT NULL,
  PRIMARY KEY (`server_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transcodetransaction`
--

DROP TABLE IF EXISTS `transcodetransaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transcodetransaction` (
  `transcode_transaction_id` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `media_id` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `file_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `message_data` text COLLATE utf8_unicode_ci NOT NULL,
  `media_type` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `media_extension` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `media_duration` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `media_size` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transcode_status` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'pending',
  `pass_fail` bit(1) NOT NULL,
  `metadata` text COLLATE utf8_unicode_ci,
  `error_message` text COLLATE utf8_unicode_ci,
  `transcode_job_duration` int(11) DEFAULT NULL,
  `server_lock` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `priority` char(10) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'low',
  `transcode_start_time` datetime NOT NULL,
  `transcode_end_time` datetime DEFAULT NULL,
  PRIMARY KEY (`transcode_transaction_id`),
  UNIQUE KEY `transcode_transaction_id_UNIQUE` (`transcode_transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-06-25 22:28:07
