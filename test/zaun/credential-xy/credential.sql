SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for activity
-- ----------------------------
DROP TABLE IF EXISTS `activity`;
CREATE TABLE `activity` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `org_id` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `content` varchar(255) NOT NULL DEFAULT '',
  `template_id` int(11) unsigned NOT NULL DEFAULT '0',
  `state` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0：未颁发，1：已颁发',
  `zip_state` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0：不许打包，1：打包中，2：打包完成',
  `zip_url` varchar(255) NOT NULL DEFAULT '' COMMENT '压缩包下载地址',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `org_id_and_ template_id` (`org_id`,`template_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='活动';

-- ----------------------------
-- Table structure for medal
-- ----------------------------
DROP TABLE IF EXISTS `medal`;
CREATE TABLE `medal` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `org_id` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `url` varchar(255) NOT NULL DEFAULT '',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `org_id` (`org_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='公章';

-- ----------------------------
-- Table structure for member
-- ----------------------------
DROP TABLE IF EXISTS `member`;
CREATE TABLE `member` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `org_id` varchar(255) NOT NULL DEFAULT '',
  `user_id` int(11) unsigned NOT NULL DEFAULT '0',
  `mobile` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `is_manager` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `mobile` (`mobile`) USING BTREE,
  KEY `org_id` (`org_id`) USING BTREE,
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='账号';

-- ----------------------------
-- Table structure for receiver
-- ----------------------------
DROP TABLE IF EXISTS `receiver`;
CREATE TABLE `receiver` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `mobile` varchar(255) NOT NULL DEFAULT '',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `mobile` (`mobile`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='证书接受人';

-- ----------------------------
-- Table structure for template
-- ----------------------------
DROP TABLE IF EXISTS `template`;
CREATE TABLE `template` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `org_id` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '' COMMENT '模板标题',
  `height` float unsigned NOT NULL DEFAULT '0' COMMENT 'pdf长度',
  `width` float unsigned NOT NULL DEFAULT '0' COMMENT 'pdf宽度',
  `rule` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '编号规则：\r\n1、GUID 19位的复杂的数字型编号不会被人猜到\r\n2、年+自增长数字型，如十位：2020983727\r\n3、年+随机数字型，如十位：2020983727',
  `length` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '编号长度',
  `pdf_format_json` text COMMENT 'pdf格式配置项，json格式。变量名使用{{}}',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `org_id` (`org_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='模版';

-- ----------------------------
-- Table structure for template_key
-- ----------------------------
DROP TABLE IF EXISTS `template_key`;
CREATE TABLE `template_key` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `template_id` int(11) unsigned NOT NULL DEFAULT '0',
  `title` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `template_id` (`template_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='模版变量';

-- ----------------------------
-- Table structure for value
-- ----------------------------
DROP TABLE IF EXISTS `value`;
CREATE TABLE `value` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `activity_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '活动id',
  `activity_title` varchar(255) NOT NULL DEFAULT '' COMMENT '活动名称',
  `number` varchar(255) NOT NULL DEFAULT '' COMMENT '证书编号',
  `all_values` text NOT NULL COMMENT '参数的值',
  `pdf_url` varchar(255) NOT NULL DEFAULT '' COMMENT 'pdf真实地址',
  `mobile` varchar(255) NOT NULL DEFAULT '' COMMENT '手机号',
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT '接收者姓名',
  `id_number` varchar(255) NOT NULL DEFAULT '' COMMENT '身份证',
  `gender` varchar(255) NOT NULL DEFAULT '' COMMENT '性别',
  `email` varchar(255) NOT NULL DEFAULT '' COMMENT '邮箱',
  `addr` varchar(255) NOT NULL DEFAULT '' COMMENT '住址',
  `state` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '0：未颁发，1：已颁发',
  `download` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '接收者是否已下载',
  `sms` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '是否已发送短信',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `activity_id_and_mobile` (`activity_id`,`mobile`) USING BTREE,
  KEY `mobile` (`mobile`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='奖状';

SET FOREIGN_KEY_CHECKS = 1;
