-- phpMyAdmin SQL Dump
-- version 4.0.10.7
-- http://www.phpmyadmin.net
--
-- Host: localhost:3306
-- Generation Time: Apr 26, 2016 at 09:54 AM
-- Server version: 5.5.48-cll
-- PHP Version: 5.4.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `htsoluti_earthquake`
--

DELIMITER $$
--
-- Functions
--
DROP FUNCTION IF EXISTS `myWithin`$$
CREATE DEFINER=`htsolution`@`localhost` FUNCTION `myWithin`(p POINT, poly POLYGON) RETURNS int(1)
    DETERMINISTIC
BEGIN
   DECLARE n INT DEFAULT 0;
   DECLARE pX DECIMAL(9,6);
   DECLARE pY DECIMAL(9,6);
   DECLARE ls LINESTRING;
   DECLARE poly1 POINT;
   DECLARE poly1X DECIMAL(9,6);
   DECLARE poly1Y DECIMAL(9,6);
   DECLARE poly2 POINT;
   DECLARE poly2X DECIMAL(9,6);
   DECLARE poly2Y DECIMAL(9,6);
   DECLARE i INT DEFAULT 0;
   DECLARE result INT(1) DEFAULT 0;
   SET pX = X(p);
   SET pY = Y(p);
   SET ls = ExteriorRing(poly);
   SET poly2 = EndPoint(ls);
   SET poly2X = X(poly2);
   SET poly2Y = Y(poly2);
   SET n = NumPoints(ls);
   WHILE i<n DO
   SET poly1 = PointN(ls, (i+1));
   SET poly1X = X(poly1);
   SET poly1Y = Y(poly1);
   IF ( ( ( ( poly1X <= pX ) && ( pX < poly2X ) ) || ( ( poly2X <= pX ) && ( pX < poly1X ) ) ) && ( pY > ( poly2Y - poly1Y ) * ( pX - poly1X ) / ( poly2X - poly1X ) + poly1Y ) ) THEN
   SET result = !result;
   END IF;
   SET poly2X = poly1X;
   SET poly2Y = poly1Y;
   SET i = i + 1;
   END WHILE;
   RETURN result;
   END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `actionable`
--

DROP TABLE IF EXISTS `actionable`;
CREATE TABLE `actionable` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `incident_id` int(11) NOT NULL COMMENT 'incident_id of the new report that is created',
  `actionable` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Is a report actionable? 0=Unactionable 1=Actionable 2=Actionable+Urgent',
  `action_taken` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Has an action been taken yet?',
  `action_closed` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Has this action been closed?',
  `action_summary` varchar(255) DEFAULT NULL COMMENT 'What action was taken',
  `action_urgent` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Is this report urgent? 0=No 1=Yes',
  PRIMARY KEY (`id`),
  KEY `incident_id` (`incident_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `actions`
--

DROP TABLE IF EXISTS `actions`;
CREATE TABLE `actions` (
  `action_id` int(11) NOT NULL AUTO_INCREMENT,
  `action` varchar(75) NOT NULL,
  `qualifiers` text NOT NULL,
  `response` varchar(75) NOT NULL,
  `response_vars` text NOT NULL,
  `active` tinyint(4) NOT NULL,
  PRIMARY KEY (`action_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores user defined actions triggered by certain events';

-- --------------------------------------------------------

--
-- Table structure for table `actions_log`
--

DROP TABLE IF EXISTS `actions_log`;
CREATE TABLE `actions_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `action_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `time` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `action_id` (`action_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores a log of triggered actions';

-- --------------------------------------------------------

--
-- Table structure for table `alert`
--

DROP TABLE IF EXISTS `alert`;
CREATE TABLE `alert` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned DEFAULT '0',
  `alert_type` tinyint(4) NOT NULL COMMENT '1 - MOBILE, 2 - EMAIL',
  `alert_recipient` varchar(200) DEFAULT NULL,
  `alert_code` varchar(30) DEFAULT NULL,
  `alert_confirmed` tinyint(4) NOT NULL DEFAULT '0',
  `alert_lat` varchar(150) DEFAULT NULL,
  `alert_lon` varchar(150) DEFAULT NULL,
  `alert_radius` tinyint(4) NOT NULL DEFAULT '20',
  `alert_ip` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_alert_code` (`alert_code`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores alerts subscribers information';

-- --------------------------------------------------------

--
-- Table structure for table `alert_category`
--

DROP TABLE IF EXISTS `alert_category`;
CREATE TABLE `alert_category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `alert_id` bigint(20) unsigned DEFAULT NULL,
  `category_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `alert_id` (`alert_id`),
  KEY `category_id` (`category_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores subscriber alert categories';

-- --------------------------------------------------------

--
-- Table structure for table `alert_sent`
--

DROP TABLE IF EXISTS `alert_sent`;
CREATE TABLE `alert_sent` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `incident_id` bigint(20) unsigned NOT NULL,
  `alert_id` bigint(20) unsigned NOT NULL,
  `alert_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `incident_id` (`incident_id`),
  KEY `alert_id` (`alert_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Stores a log of alerts sent out to subscribers';

-- --------------------------------------------------------

--
-- Table structure for table `api_banned`
--

DROP TABLE IF EXISTS `api_banned`;
CREATE TABLE `api_banned` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `banned_ipaddress` varchar(50) NOT NULL,
  `banned_date` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='For logging banned API IP addresses';

-- --------------------------------------------------------

--
-- Table structure for table `api_log`
--

DROP TABLE IF EXISTS `api_log`;
CREATE TABLE `api_log` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `api_task` varchar(10) NOT NULL,
  `api_parameters` varchar(100) NOT NULL,
  `api_records` tinyint(11) NOT NULL,
  `api_ipaddress` varchar(50) NOT NULL,
  `api_date` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='For logging API activities';

-- --------------------------------------------------------

--
-- Table structure for table `api_settings`
--

DROP TABLE IF EXISTS `api_settings`;
CREATE TABLE `api_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `default_record_limit` int(11) NOT NULL DEFAULT '20',
  `max_record_limit` int(11) DEFAULT NULL,
  `max_requests_per_ip_address` int(11) DEFAULT NULL,
  `max_requests_quota_basis` int(11) DEFAULT NULL,
  `modification_date` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='For storing API logging settings';

-- --------------------------------------------------------

--
-- Table structure for table `badge`
--

DROP TABLE IF EXISTS `badge`;
CREATE TABLE `badge` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(250) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Stores description of badges to be assigned';

-- --------------------------------------------------------

--
-- Table structure for table `badge_users`
--

DROP TABLE IF EXISTS `badge_users`;
CREATE TABLE `badge_users` (
  `user_id` int(11) unsigned NOT NULL,
  `badge_id` int(11) NOT NULL,
  PRIMARY KEY (`user_id`,`badge_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Stores assigned badge information';

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) NOT NULL DEFAULT '0',
  `locale` varchar(10) NOT NULL DEFAULT 'en_US',
  `category_position` tinyint(4) NOT NULL DEFAULT '0',
  `category_title` varchar(255) DEFAULT NULL,
  `category_description` text,
  `category_color` varchar(20) DEFAULT NULL,
  `category_image` varchar(255) DEFAULT NULL,
  `category_image_thumb` varchar(255) DEFAULT NULL,
  `category_visible` tinyint(4) NOT NULL DEFAULT '1',
  `category_trusted` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `category_visible` (`category_visible`),
  KEY `parent_id` (`parent_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Holds information about categories defined for a deployment';

-- --------------------------------------------------------

--
-- Table structure for table `category_lang`
--

DROP TABLE IF EXISTS `category_lang`;
CREATE TABLE `category_lang` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `category_id` int(11) unsigned NOT NULL,
  `locale` varchar(10) DEFAULT NULL,
  `category_title` varchar(255) DEFAULT NULL,
  `category_description` text,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Holds translations for category titles and descriptions';

-- --------------------------------------------------------

--
-- Table structure for table `city`
--

DROP TABLE IF EXISTS `city`;
CREATE TABLE `city` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `country_id` int(11) DEFAULT NULL,
  `city` varchar(200) DEFAULT NULL,
  `city_lat` varchar(150) DEFAULT NULL,
  `city_lon` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `country_id` (`country_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores cities of countries retrieved by user.';

-- --------------------------------------------------------

--
-- Table structure for table `cluster`
--

DROP TABLE IF EXISTS `cluster`;
CREATE TABLE `cluster` (
  `id` int(11) NOT NULL,
  `location_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `latitude` double NOT NULL,
  `longitude` double NOT NULL,
  `latitude_min` double NOT NULL,
  `longitude_min` double NOT NULL,
  `latitude_max` double NOT NULL,
  `longitude_max` double NOT NULL,
  `child_count` int(11) NOT NULL,
  `parent_id` int(11) NOT NULL,
  `left_side` int(11) NOT NULL,
  `right_side` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `incident_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `category_id` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `location_id` (`location_id`),
  KEY `incident_id` (`incident_id`),
  KEY `category_id` (`category_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Stores information used for clustering of reports on the map.';

-- --------------------------------------------------------

--
-- Table structure for table `comment`
--

DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `incident_id` bigint(20) unsigned DEFAULT NULL,
  `user_id` int(11) unsigned DEFAULT '0',
  `comment_author` varchar(100) DEFAULT NULL,
  `comment_email` varchar(120) DEFAULT NULL,
  `comment_description` text,
  `comment_ip` varchar(100) DEFAULT NULL,
  `comment_spam` tinyint(4) NOT NULL DEFAULT '0',
  `comment_active` tinyint(4) NOT NULL DEFAULT '0',
  `comment_date` datetime DEFAULT NULL,
  `comment_date_gmt` datetime DEFAULT NULL,
  `comment_follow_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '0 - Not Tagged for Sending, 1 - Tagged for Sending, 2 - Alerts Have Been Sent',
  PRIMARY KEY (`id`),
  KEY `incident_id` (`incident_id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores comments made on reports';

-- --------------------------------------------------------

--
-- Table structure for table `country`
--

DROP TABLE IF EXISTS `country`;
CREATE TABLE `country` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `iso` varchar(10) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `capital` varchar(100) DEFAULT NULL,
  `cities` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores a list of all countries and their capital cities';

-- --------------------------------------------------------

--
-- Table structure for table `externalapp`
--

DROP TABLE IF EXISTS `externalapp`;
CREATE TABLE `externalapp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Info on external apps(mobile) that work with your deployment';

-- --------------------------------------------------------

--
-- Table structure for table `feed`
--

DROP TABLE IF EXISTS `feed`;
CREATE TABLE `feed` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `feed_name` varchar(255) DEFAULT NULL,
  `feed_url` varchar(255) DEFAULT NULL,
  `feed_cache` text,
  `feed_active` tinyint(4) DEFAULT '1',
  `feed_update` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Information about RSS Feeds a deployment subscribes to';

-- --------------------------------------------------------

--
-- Table structure for table `feed_item`
--

DROP TABLE IF EXISTS `feed_item`;
CREATE TABLE `feed_item` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `feed_id` int(11) unsigned NOT NULL,
  `location_id` bigint(20) unsigned DEFAULT '0',
  `incident_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `item_title` varchar(255) DEFAULT NULL,
  `item_description` text,
  `item_link` varchar(255) DEFAULT NULL,
  `item_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `feed_id` (`feed_id`),
  KEY `incident_id` (`incident_id`),
  KEY `location_id` (`location_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores feed items pulled from each RSS Feed';

-- --------------------------------------------------------

--
-- Table structure for table `feed_item_category`
--

DROP TABLE IF EXISTS `feed_item_category`;
CREATE TABLE `feed_item_category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `feed_item_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `category_id` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `feed_item_category_ids` (`feed_item_id`,`category_id`),
  KEY `feed_item_id` (`feed_item_id`),
  KEY `category_id` (`category_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Stores fetched feed items categories';

-- --------------------------------------------------------

--
-- Table structure for table `findlocation_cache`
--

DROP TABLE IF EXISTS `findlocation_cache`;
CREATE TABLE `findlocation_cache` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `search_term` varchar(255) DEFAULT NULL,
  `result_name` varchar(255) DEFAULT NULL,
  `lat` double NOT NULL DEFAULT '0',
  `lon` double NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `findlocation_settings`
--

DROP TABLE IF EXISTS `findlocation_settings`;
CREATE TABLE `findlocation_settings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `region_code` varchar(10) DEFAULT NULL,
  `append_to_google` varchar(255) DEFAULT NULL,
  `geonames_username` varchar(255) DEFAULT NULL,
  `n_w_lat` double NOT NULL DEFAULT '0',
  `n_w_lon` double NOT NULL DEFAULT '0',
  `s_e_lat` double NOT NULL DEFAULT '0',
  `s_e_lon` double NOT NULL DEFAULT '0',
  `fuzzy` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `follow`
--

DROP TABLE IF EXISTS `follow`;
CREATE TABLE `follow` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `incident_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `follower` varchar(200) DEFAULT NULL,
  `follow_type` tinyint(4) unsigned NOT NULL COMMENT '1 - MOBILE, 2 - EMAIL',
  `follow_code` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `subscribe_incident_id` (`incident_id`,`follower`,`follow_type`),
  KEY `incident_id` (`incident_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores incident subscription';

-- --------------------------------------------------------

--
-- Table structure for table `follow_sent`
--

DROP TABLE IF EXISTS `follow_sent`;
CREATE TABLE `follow_sent` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `comment_id` bigint(20) unsigned NOT NULL,
  `follow_id` bigint(20) unsigned NOT NULL,
  `follow_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `incident_id` (`comment_id`),
  KEY `alert_id` (`follow_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores a log of follow sent out to subscribers';

-- --------------------------------------------------------

--
-- Table structure for table `form`
--

DROP TABLE IF EXISTS `form`;
CREATE TABLE `form` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `form_title` varchar(200) NOT NULL,
  `form_description` text,
  `form_active` tinyint(4) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `form_title` (`form_title`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores all report submission forms created(default+custom)';

-- --------------------------------------------------------

--
-- Table structure for table `form_field`
--

DROP TABLE IF EXISTS `form_field`;
CREATE TABLE `form_field` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `form_id` int(11) NOT NULL DEFAULT '1',
  `field_name` varchar(200) DEFAULT NULL,
  `field_type` tinyint(4) NOT NULL DEFAULT '1' COMMENT '1 - TEXTFIELD, 2 - TEXTAREA (FREETEXT), 3 - DATE, 4 - PASSWORD, 5 - RADIO, 6 - CHECKBOX',
  `field_required` tinyint(4) DEFAULT '0',
  `field_position` tinyint(4) NOT NULL DEFAULT '0',
  `field_default` text,
  `field_maxlength` int(11) NOT NULL DEFAULT '0',
  `field_width` smallint(6) NOT NULL DEFAULT '0',
  `field_height` tinyint(4) DEFAULT '5',
  `field_isdate` tinyint(4) NOT NULL DEFAULT '0',
  `field_ispublic_visible` tinyint(4) NOT NULL DEFAULT '0',
  `field_ispublic_submit` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `field_name` (`field_name`,`form_id`),
  KEY `fk_form_id` (`form_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores all custom form fields created by users';

-- --------------------------------------------------------

--
-- Table structure for table `form_field_option`
--

DROP TABLE IF EXISTS `form_field_option`;
CREATE TABLE `form_field_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `form_field_id` int(11) NOT NULL DEFAULT '0',
  `option_name` varchar(200) DEFAULT NULL,
  `option_value` text,
  PRIMARY KEY (`id`),
  KEY `form_field_id` (`form_field_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Options related to custom form fields';

-- --------------------------------------------------------

--
-- Table structure for table `form_response`
--

DROP TABLE IF EXISTS `form_response`;
CREATE TABLE `form_response` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `form_field_id` int(11) NOT NULL,
  `incident_id` bigint(20) unsigned NOT NULL,
  `form_response` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_form_field_id` (`form_field_id`),
  KEY `incident_id` (`incident_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores responses to custom form fields';

-- --------------------------------------------------------

--
-- Table structure for table `geometry`
--

DROP TABLE IF EXISTS `geometry`;
CREATE TABLE `geometry` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `incident_id` bigint(20) unsigned NOT NULL,
  `geometry` geometry NOT NULL,
  `geometry_label` varchar(150) DEFAULT NULL,
  `geometry_comment` varchar(255) DEFAULT NULL,
  `geometry_color` varchar(20) DEFAULT NULL,
  `geometry_strokewidth` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`id`),
  SPATIAL KEY `geometry` (`geometry`),
  KEY `incident_id` (`incident_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores map geometries i.e polygons, lines etc';

-- --------------------------------------------------------

--
-- Table structure for table `incident`
--

DROP TABLE IF EXISTS `incident`;
CREATE TABLE `incident` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `location_id` bigint(20) unsigned NOT NULL,
  `form_id` int(11) NOT NULL DEFAULT '1',
  `locale` varchar(10) NOT NULL DEFAULT 'en_US',
  `user_id` int(11) unsigned DEFAULT NULL,
  `incident_title` varchar(255) DEFAULT NULL,
  `incident_description` longtext,
  `incident_date` datetime DEFAULT NULL,
  `incident_mode` tinyint(4) NOT NULL DEFAULT '1' COMMENT '1 - WEB, 2 - SMS, 3 - EMAIL, 4 - TWITTER',
  `incident_active` tinyint(4) NOT NULL DEFAULT '0',
  `incident_verified` tinyint(4) NOT NULL DEFAULT '0',
  `incident_dateadd` datetime DEFAULT NULL,
  `incident_dateadd_gmt` datetime DEFAULT NULL,
  `incident_datemodify` datetime DEFAULT NULL,
  `incident_alert_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '0 - Not Tagged for Sending, 1 - Tagged for Sending, 2 - Alerts Have Been Sent',
  `incident_zoom` tinyint(4) DEFAULT NULL,
  `pcode` varchar(255) DEFAULT NULL,
  `adm_level` int(11) DEFAULT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `location_id` (`location_id`),
  KEY `incident_active` (`incident_active`),
  KEY `incident_date` (`incident_date`),
  KEY `form_id` (`form_id`),
  KEY `user_id` (`user_id`),
  KEY `incident_mode` (`incident_mode`),
  KEY `incident_verified` (`incident_verified`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores reports submitted';

-- --------------------------------------------------------

--
-- Table structure for table `incident_category`
--

DROP TABLE IF EXISTS `incident_category`;
CREATE TABLE `incident_category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `incident_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `category_id` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `incident_category_ids` (`incident_id`,`category_id`),
  KEY `incident_id` (`incident_id`),
  KEY `category_id` (`category_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores submitted reports categories';

-- --------------------------------------------------------

--
-- Table structure for table `incident_lang`
--

DROP TABLE IF EXISTS `incident_lang`;
CREATE TABLE `incident_lang` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `incident_id` bigint(20) unsigned NOT NULL,
  `locale` varchar(10) DEFAULT NULL,
  `incident_title` varchar(255) DEFAULT NULL,
  `incident_description` longtext,
  PRIMARY KEY (`id`),
  KEY `incident_id` (`incident_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Holds translations for report titles and descriptions';

-- --------------------------------------------------------

--
-- Table structure for table `incident_person`
--

DROP TABLE IF EXISTS `incident_person`;
CREATE TABLE `incident_person` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `incident_id` bigint(20) unsigned DEFAULT NULL,
  `person_first` varchar(200) DEFAULT NULL,
  `person_last` varchar(200) DEFAULT NULL,
  `person_email` varchar(120) DEFAULT NULL,
  `person_phone` varchar(60) DEFAULT NULL,
  `person_ip` varchar(50) DEFAULT NULL,
  `person_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `incident_id` (`incident_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Holds information provided by people who submit reports';

-- --------------------------------------------------------

--
-- Table structure for table `layer`
--

DROP TABLE IF EXISTS `layer`;
CREATE TABLE `layer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `layer_name` varchar(255) DEFAULT NULL,
  `layer_url` varchar(255) DEFAULT NULL,
  `layer_file` varchar(100) DEFAULT NULL,
  `layer_color` varchar(20) DEFAULT NULL,
  `layer_visible` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Holds static layer information';

-- --------------------------------------------------------

--
-- Table structure for table `level`
--

DROP TABLE IF EXISTS `level`;
CREATE TABLE `level` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `level_title` varchar(200) DEFAULT NULL,
  `level_description` varchar(200) DEFAULT NULL,
  `level_weight` tinyint(4) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores level of trust assigned to reporters of the platform';

-- --------------------------------------------------------

--
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
CREATE TABLE `location` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `location_name` varchar(255) DEFAULT NULL,
  `country_id` int(11) NOT NULL DEFAULT '0',
  `latitude` double NOT NULL DEFAULT '0',
  `longitude` double NOT NULL DEFAULT '0',
  `location_visible` tinyint(4) NOT NULL DEFAULT '1',
  `location_date` datetime DEFAULT NULL,
  `pcode` varchar(255) DEFAULT NULL,
  `adm_level` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `country_id` (`country_id`),
  KEY `latitude` (`latitude`),
  KEY `longitude` (`longitude`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores location information';

-- --------------------------------------------------------

--
-- Table structure for table `location_filter`
--

DROP TABLE IF EXISTS `location_filter`;
CREATE TABLE `location_filter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_pcode` varchar(255) DEFAULT NULL,
  `pcode` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `adm_level` int(11) NOT NULL,
  `coord` longtext,
  `keyword` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `location_fix`
--

DROP TABLE IF EXISTS `location_fix`;
CREATE TABLE `location_fix` (
  `id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `location_name` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `country_id` int(11) NOT NULL DEFAULT '0',
  `latitude` double NOT NULL DEFAULT '0',
  `longitude` double NOT NULL DEFAULT '0',
  `location_visible` tinyint(4) NOT NULL DEFAULT '1',
  `location_date` datetime DEFAULT NULL,
  `pcode` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `adm_level` int(11) DEFAULT NULL,
  UNIQUE KEY `idx_location` (`latitude`,`longitude`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `maintenance`
--

DROP TABLE IF EXISTS `maintenance`;
CREATE TABLE `maintenance` (
  `allowed_ip` varchar(15) NOT NULL,
  PRIMARY KEY (`allowed_ip`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Puts a site in maintenance mode if data exists in this table';

-- --------------------------------------------------------

--
-- Table structure for table `media`
--

DROP TABLE IF EXISTS `media`;
CREATE TABLE `media` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `location_id` bigint(20) unsigned DEFAULT NULL,
  `incident_id` bigint(20) unsigned DEFAULT NULL,
  `message_id` bigint(20) unsigned DEFAULT NULL,
  `badge_id` int(11) DEFAULT NULL,
  `media_type` tinyint(4) DEFAULT NULL COMMENT '1 - IMAGES, 2 - VIDEO, 3 - AUDIO, 4 - NEWS, 5 - PODCAST',
  `media_title` varchar(255) DEFAULT NULL,
  `media_description` longtext,
  `media_link` varchar(255) DEFAULT NULL,
  `media_medium` varchar(255) DEFAULT NULL,
  `media_thumb` varchar(255) DEFAULT NULL,
  `media_date` datetime DEFAULT NULL,
  `media_active` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `incident_id` (`incident_id`),
  KEY `location_id` (`location_id`),
  KEY `badge_id` (`badge_id`),
  KEY `message_id` (`message_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores any media submitted along with a report';

-- --------------------------------------------------------

--
-- Table structure for table `message`
--

DROP TABLE IF EXISTS `message`;
CREATE TABLE `message` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` bigint(20) DEFAULT '0',
  `incident_id` bigint(20) unsigned DEFAULT '0',
  `user_id` int(11) unsigned DEFAULT '0',
  `reporter_id` bigint(20) unsigned DEFAULT NULL,
  `service_messageid` varchar(100) DEFAULT NULL,
  `message_from` varchar(100) DEFAULT NULL,
  `message_to` varchar(100) DEFAULT NULL,
  `message` text,
  `message_detail` text,
  `message_type` tinyint(4) DEFAULT '1' COMMENT '1 - INBOX, 2 - OUTBOX (From Admin), 3 - DELETED',
  `message_date` datetime DEFAULT NULL,
  `message_level` tinyint(4) DEFAULT '0' COMMENT '0 - UNREAD, 1 - READ, 99 - SPAM',
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `incident_id` (`incident_id`),
  KEY `reporter_id` (`reporter_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores tweets, emails and SMS messages';

-- --------------------------------------------------------

--
-- Table structure for table `openid`
--

DROP TABLE IF EXISTS `openid`;
CREATE TABLE `openid` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `openid` varchar(255) NOT NULL,
  `openid_email` varchar(127) NOT NULL,
  `openid_server` varchar(255) NOT NULL,
  `openid_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `openid` (`openid`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Stores usersâ€™ openid information';

-- --------------------------------------------------------

--
-- Table structure for table `page`
--

DROP TABLE IF EXISTS `page`;
CREATE TABLE `page` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `page_title` varchar(255) NOT NULL,
  `page_description` longtext,
  `page_tab` varchar(100) NOT NULL,
  `page_active` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores user created pages';

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Stores permissions used for access control';

-- --------------------------------------------------------

--
-- Table structure for table `permissions_roles`
--

DROP TABLE IF EXISTS `permissions_roles`;
CREATE TABLE `permissions_roles` (
  `role_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`role_id`,`permission_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Stores permissions assigned to roles';

-- --------------------------------------------------------

--
-- Table structure for table `placemark`
--

DROP TABLE IF EXISTS `placemark`;
CREATE TABLE `placemark` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `layer_id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `placemark` varchar(255) DEFAULT NULL,
  `coord` longtext,
  PRIMARY KEY (`id`),
  UNIQUE KEY `layer_placemark_id` (`layer_id`,`placemark`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `plugin`
--

DROP TABLE IF EXISTS `plugin`;
CREATE TABLE `plugin` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `plugin_name` varchar(100) NOT NULL,
  `plugin_url` varchar(250) DEFAULT NULL,
  `plugin_description` text,
  `plugin_priority` tinyint(4) DEFAULT '0',
  `plugin_active` tinyint(4) DEFAULT '0',
  `plugin_installed` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `plugin_name` (`plugin_name`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Holds a list of all plugins installed on a deployment';

-- --------------------------------------------------------

--
-- Table structure for table `private_message`
--

DROP TABLE IF EXISTS `private_message`;
CREATE TABLE `private_message` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) NOT NULL DEFAULT '0',
  `user_id` int(11) unsigned NOT NULL,
  `from_user_id` int(11) DEFAULT '0',
  `private_subject` varchar(255) NOT NULL,
  `private_message` text NOT NULL,
  `private_message_date` datetime NOT NULL,
  `private_message_new` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Stores private messages sent between Members';

-- --------------------------------------------------------

--
-- Table structure for table `rating`
--

DROP TABLE IF EXISTS `rating`;
CREATE TABLE `rating` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned DEFAULT '0',
  `incident_id` bigint(20) unsigned DEFAULT NULL,
  `comment_id` bigint(20) unsigned DEFAULT NULL,
  `rating` tinyint(4) DEFAULT '0',
  `rating_ip` varchar(100) DEFAULT NULL,
  `rating_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `incident_id` (`incident_id`),
  KEY `comment_id` (`comment_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores credibility ratings for reports and comments';

-- --------------------------------------------------------

--
-- Table structure for table `reporter`
--

DROP TABLE IF EXISTS `reporter`;
CREATE TABLE `reporter` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `location_id` bigint(20) unsigned DEFAULT NULL,
  `user_id` int(11) unsigned DEFAULT NULL,
  `service_id` int(10) unsigned DEFAULT NULL,
  `level_id` int(11) unsigned DEFAULT NULL,
  `service_account` varchar(255) DEFAULT NULL,
  `reporter_first` varchar(200) DEFAULT NULL,
  `reporter_last` varchar(200) DEFAULT NULL,
  `reporter_email` varchar(120) DEFAULT NULL,
  `reporter_phone` varchar(60) DEFAULT NULL,
  `reporter_ip` varchar(50) DEFAULT NULL,
  `reporter_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `location_id` (`location_id`),
  KEY `service_id` (`service_id`),
  KEY `level_id` (`level_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Information on report submitters via email, twitter and sms';

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `description` varchar(255) NOT NULL,
  `access_level` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_name` (`name`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Defines user access levels and privileges on a deployment';

-- --------------------------------------------------------

--
-- Table structure for table `roles_users`
--

DROP TABLE IF EXISTS `roles_users`;
CREATE TABLE `roles_users` (
  `user_id` int(11) unsigned NOT NULL,
  `role_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `fk_role_id` (`role_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Stores roles assigned to users registered on a deployment';

-- --------------------------------------------------------

--
-- Table structure for table `scheduler`
--

DROP TABLE IF EXISTS `scheduler`;
CREATE TABLE `scheduler` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `scheduler_name` varchar(100) NOT NULL,
  `scheduler_last` int(10) unsigned NOT NULL DEFAULT '0',
  `scheduler_weekday` smallint(6) NOT NULL DEFAULT '-1',
  `scheduler_day` smallint(6) NOT NULL DEFAULT '-1',
  `scheduler_hour` smallint(6) NOT NULL DEFAULT '-1',
  `scheduler_minute` smallint(6) NOT NULL,
  `scheduler_controller` varchar(100) NOT NULL,
  `scheduler_active` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores schedules for cron jobs';

-- --------------------------------------------------------

--
-- Table structure for table `scheduler_log`
--

DROP TABLE IF EXISTS `scheduler_log`;
CREATE TABLE `scheduler_log` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `scheduler_id` int(10) unsigned NOT NULL,
  `scheduler_status` varchar(20) DEFAULT NULL,
  `scheduler_date` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `scheduler_id` (`scheduler_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores a log of scheduler actions';

-- --------------------------------------------------------

--
-- Table structure for table `service`
--

DROP TABLE IF EXISTS `service`;
CREATE TABLE `service` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `service_name` varchar(100) DEFAULT NULL,
  `service_description` varchar(255) DEFAULT NULL,
  `service_url` varchar(255) DEFAULT NULL,
  `service_api` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Info on input sources i.e SMS, Email, Twitter';

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
CREATE TABLE `sessions` (
  `session_id` varchar(127) NOT NULL,
  `last_activity` int(10) unsigned NOT NULL,
  `data` text NOT NULL,
  PRIMARY KEY (`session_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Stores session information';

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
CREATE TABLE `settings` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(100) NOT NULL DEFAULT '' COMMENT 'Unique identifier for the configuration parameter',
  `value` text COMMENT 'Value for the settings parameter',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_settings_key` (`key`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `sharing`
--

DROP TABLE IF EXISTS `sharing`;
CREATE TABLE `sharing` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sharing_name` varchar(150) NOT NULL COMMENT 'name that appears on the front end',
  `sharing_url` varchar(255) NOT NULL COMMENT 'url of the deployment to share with',
  `sharing_color` varchar(20) DEFAULT 'CC0000' COMMENT 'color that shows the shared reports',
  `sharing_active` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'sharing active or inactive ',
  `sharing_date` datetime DEFAULT NULL COMMENT 'date the sharing was initiated',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `sharing_incident`
--

DROP TABLE IF EXISTS `sharing_incident`;
CREATE TABLE `sharing_incident` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sharing_id` int(10) unsigned NOT NULL,
  `incident_id` int(10) NOT NULL,
  `incident_title` varchar(255) NOT NULL COMMENT 'title of the report',
  `latitude` double NOT NULL COMMENT 'latitude of the report',
  `longitude` double NOT NULL COMMENT 'longitude of the report',
  `incident_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `sharing_log`
--

DROP TABLE IF EXISTS `sharing_log`;
CREATE TABLE `sharing_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sharing_id` int(11) NOT NULL,
  `sharing_log_date` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `smssync_message`
--

DROP TABLE IF EXISTS `smssync_message`;
CREATE TABLE `smssync_message` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `smssync_to` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `smssync_from` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `smssync_message` text COLLATE utf8_unicode_ci,
  `smssync_message_date` datetime DEFAULT NULL,
  `smssync_sent` tinyint(4) NOT NULL DEFAULT '0',
  `smssync_sent_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `smssync_settings`
--

DROP TABLE IF EXISTS `smssync_settings`;
CREATE TABLE `smssync_settings` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `smssync_secret` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ts_auth_table`
--

DROP TABLE IF EXISTS `ts_auth_table`;
CREATE TABLE `ts_auth_table` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `task_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  `permission_submit` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `indx_task_id` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `ts_category_table`
--

DROP TABLE IF EXISTS `ts_category_table`;
CREATE TABLE `ts_category_table` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `task_id` int(10) unsigned NOT NULL,
  `category_id` int(10) unsigned NOT NULL,
  `category_name` text NOT NULL,
  `is_parent` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `indx_task_id` (`task_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `ts_config_table`
--

DROP TABLE IF EXISTS `ts_config_table`;
CREATE TABLE `ts_config_table` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `parent_category` int(11) NOT NULL,
  `primary_category` int(11) NOT NULL,
  `completed_category` int(11) NOT NULL,
  `admin_role` int(11) NOT NULL,
  `import_reports` tinyint(1) NOT NULL DEFAULT '0',
  `import_sms` tinyint(1) NOT NULL DEFAULT '0',
  `import_twitter` tinyint(1) NOT NULL DEFAULT '0',
  `import_email` tinyint(1) NOT NULL DEFAULT '0',
  `default_latitude` double NOT NULL DEFAULT '0',
  `default_longitude` double NOT NULL DEFAULT '0',
  `title_type` int(11) NOT NULL DEFAULT '0',
  `title_string` varchar(200) DEFAULT NULL,
  `prioritization_module` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `ts_message_table`
--

DROP TABLE IF EXISTS `ts_message_table`;
CREATE TABLE `ts_message_table` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `expiration` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `message` longtext,
  PRIMARY KEY (`id`),
  KEY `indx_user_id` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `ts_module_table`
--

DROP TABLE IF EXISTS `ts_module_table`;
CREATE TABLE `ts_module_table` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `order` int(11) NOT NULL DEFAULT '1' COMMENT 'order that this module is fired',
  `task_name` text NOT NULL COMMENT 'name of the task',
  `task_description` text NOT NULL,
  `task_path` text NOT NULL COMMENT 'path to the modules controller',
  `task_information` longtext,
  `task_category` int(11) DEFAULT NULL COMMENT 'category id associated with this task',
  `task_role` int(11) NOT NULL COMMENT 'role for users who can submit reports',
  `is_active` tinyint(1) NOT NULL DEFAULT '0',
  `is_terminal` tinyint(4) NOT NULL DEFAULT '0',
  `strict_permissions` tinyint(1) NOT NULL DEFAULT '0',
  `has_options` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'are there module-specific options',
  `checkout_duration` int(11) DEFAULT NULL COMMENT 'time is seconds tasks will be locked for',
  PRIMARY KEY (`id`),
  UNIQUE KEY `task_category` (`task_category`),
  KEY `indx_task_category` (`task_category`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `ts_report_viewer`
--

DROP TABLE IF EXISTS `ts_report_viewer`;
CREATE TABLE `ts_report_viewer` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `incident_id` int(11) NOT NULL COMMENT 'incident_id of the incident report being viewed',
  `user_id` int(11) NOT NULL COMMENT 'user_id of the user viewing the incident report',
  `last_viewed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `first_viewed` datetime NOT NULL,
  `user_role` int(11) DEFAULT NULL COMMENT 'user role id for quick lookup and tasking by role',
  `task_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `indx_last_viewed` (`last_viewed`),
  KEY `indx_user_id` (`user_id`),
  KEY `indx_incident_id` (`incident_id`),
  KEY `indx_user_role` (`user_role`),
  KEY `indx_task_id` (`task_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `ts_scoreboard_table`
--

DROP TABLE IF EXISTS `ts_scoreboard_table`;
CREATE TABLE `ts_scoreboard_table` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `incident_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `task_id` int(10) unsigned NOT NULL,
  `score` tinyint(4) NOT NULL,
  `time_scored` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `indx_user_id` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `ts_time_table`
--

DROP TABLE IF EXISTS `ts_time_table`;
CREATE TABLE `ts_time_table` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `incident_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `task_id` int(10) unsigned NOT NULL,
  `status` enum('START','STOP') NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `indx_user_id` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `riverid` varchar(128) NOT NULL,
  `name` varchar(200) DEFAULT NULL,
  `email` varchar(127) NOT NULL,
  `username` varchar(100) NOT NULL DEFAULT '',
  `password` char(50) NOT NULL,
  `logins` int(10) unsigned NOT NULL DEFAULT '0',
  `last_login` int(10) unsigned DEFAULT NULL,
  `notify` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Flag incase admin opts in for email notifications',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `color` varchar(6) NOT NULL DEFAULT 'FF0000',
  `code` varchar(30) DEFAULT NULL,
  `confirmed` tinyint(1) NOT NULL DEFAULT '0',
  `public_profile` tinyint(1) NOT NULL DEFAULT '1',
  `approved` tinyint(1) NOT NULL DEFAULT '1',
  `needinfo` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_username` (`username`),
  UNIQUE KEY `uniq_email` (`email`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores registered usersâ€™ information';

-- --------------------------------------------------------

--
-- Table structure for table `user_tokens`
--

DROP TABLE IF EXISTS `user_tokens`;
CREATE TABLE `user_tokens` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `user_agent` varchar(40) NOT NULL,
  `token` varchar(64) NOT NULL,
  `created` int(10) unsigned NOT NULL,
  `expires` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_token` (`token`),
  KEY `fk_user_id` (`user_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores browser tokens assigned to users';

-- --------------------------------------------------------

--
-- Table structure for table `verified`
--

DROP TABLE IF EXISTS `verified`;
CREATE TABLE `verified` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `incident_id` bigint(20) unsigned DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `verified_date` datetime DEFAULT NULL,
  `verified_status` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `incident_id` (`incident_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Stores all verified reports';

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_placemark`
--
DROP VIEW IF EXISTS `vw_placemark`;
CREATE TABLE `vw_placemark` (
`location_id` bigint(20) unsigned
,`placemark_id` int(11)
,`lkey` varchar(267)
);
-- --------------------------------------------------------

--
-- Structure for view `vw_placemark`
--
DROP TABLE IF EXISTS `vw_placemark`;

CREATE ALGORITHM=UNDEFINED DEFINER=`htsolution`@`localhost` SQL SECURITY DEFINER VIEW `vw_placemark` AS select `l`.`id` AS `location_id`,`p`.`id` AS `placemark_id`,concat(`p`.`layer_id`,'_',`p`.`placemark`) AS `lkey` from (`location` `l` join `placemark` `p`) where `myWithin`(geometryfromtext(concat('POINT(',`l`.`latitude`,' ',`l`.`longitude`,')')),geometryfromtext(concat('POLYGON((',`p`.`coord`,'))')));

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
