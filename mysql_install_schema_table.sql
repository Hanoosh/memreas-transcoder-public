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
  `media_metadata` text COLLATE utf8_unicode_ci,
  `error_message` text COLLATE utf8_unicode_ci,
  `transcode_job_duration` int(11) DEFAULT NULL,
  `server_lock` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `priority` char(10) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'low',
  `transcode_start_time` datetime NOT NULL,
  `transcode_end_time` datetime DEFAULT NULL,
  PRIMARY KEY (`transcode_transaction_id`),
  UNIQUE KEY `transcode_transaction_id_UNIQUE` (`transcode_transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
