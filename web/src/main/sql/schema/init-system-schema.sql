drop table if exists `sys_user`;
drop table if exists `sys_user_status_history`;
drop trigger if exists `trigger_sys_user_off_online`;
drop table if exists `sys_user_online`;
drop table if exists `sys_user_last_online`;
drop table if exists `sys_organization`;
drop table if exists `sys_job`;
drop table if exists `sys_menu`;
##user
create table `sys_user`(
  `id`         bigint not null auto_increment,
  `username`  varchar(100),
  `email`  varchar(100),
  `mobile_phone_number`  varchar(20),
  `password`  varchar(100),
  `salt`       varchar(10),
  `create_date` timestamp,
  `status`    varchar(50),
  `deleted`   bool,
  `admin`     bool,
  constraint `pk_sys_user` primary key(`id`),
  constraint `unique_sys_user_username` unique(`username`),
  constraint `unique_sys_user_email` unique(`email`),
  constraint `unique_sys_user_mobile_phone_number` unique(`mobile_phone_number`),
  index `idx_sys_user_status` (`status`)
) charset=utf8 ENGINE=InnoDB;
alter table `sys_user` auto_increment=1000;

create table `sys_user_status_history`(
  `id`         bigint not null auto_increment,
  `user_id`    bigint,
  `status`    varchar(50),
  `reason`     varchar(200),
  `op_user_id`  bigint,
  `op_date`    timestamp ,
  constraint `pk_sys_user_block_history` primary key(`id`),
  index `idx_sys_user_block_history_user_id_block_date` (`user_id`,`op_date`),
  index `idx_sys_user_block_history_op_user_id_op_date` (`op_user_id`, `op_date`)
) charset=utf8 ENGINE=InnoDB;


create table `sys_user_online`(
  `id`         varchar(100) not null,
  `user_id`    bigint default 0,
  `username`    varchar(100),
  `host`  varchar(100),
  `system_host`  varchar(100),
  `user_agent` varchar(200),
  `status`  varchar(50),
  `start_timestsamp`    timestamp ,
  `last_access_time`    timestamp ,
  `timeout`    bigint ,
  `session` mediumtext,
  constraint `pk_sys_user_online` primary key(`id`),
  index `idx_sys_user_online_sys_user_id` (`user_id`),
  index `idx_sys_user_online_username` (`username`),
  index `idx_sys_user_online_host` (`host`),
  index `idx_sys_user_online_system_host` (`system_host`),
  index `idx_sys_user_online_start_timestsamp` (`start_timestsamp`),
  index `idx_sys_user_online_last_access_time` (`last_access_time`),
  index `idx_sys_user_online_user_agent` (`user_agent`)
) charset=utf8 ENGINE=InnoDB;


create table `sys_user_last_online`(
  `id`         bigint not null auto_increment,
  `user_id`    bigint,
  `username`    varchar(100),
  `uid`        varchar(100),
  `host`    varchar(100),
  `user_agent` varchar(200),
  `system_host`  varchar(100),
  `last_login_timestamp`    timestamp ,
  `last_stop_timestamp`    timestamp ,
  `login_count`    bigint ,
  `total_online_time` bigint,
  constraint `pk_sys_user_last_online` primary key(`id`),
  constraint `unique_sys_user_last_online_sys_user_id` unique(`user_id`),
  index `idx_sys_user_last_online_username` (`username`),
  index `idx_sys_user_last_online_host` (`host`),
  index `idx_sys_user_last_online_system_host` (`system_host`),
  index `idx_sys_user_last_online_last_login_timestamp` (`last_login_timestamp`),
  index `idx_sys_user_last_online_last_stop_timestamp` (`last_stop_timestamp`),
  index `idx_sys_user_last_online_user_agent` (`user_agent`)
) charset=utf8 ENGINE=InnoDB;

create trigger `trigger_sys_user_off_online`
after delete
on `sys_user_online`for each row
begin
   if OLD.`user_id` is not null then
      if not exists(select `user_id` from `sys_user_last_online` where `user_id` = OLD.`user_id`) then
        insert into `sys_user_last_online`
                  (`user_id`, `username`, `uid`, `host`, `user_agent`, `system_host`,
                   `last_login_timestamp`, `last_stop_timestamp`, `login_count`, `total_online_time`)
                values
                   (OLD.`user_id`,OLD.`username`, OLD.`id`, OLD.`host`, OLD.`user_agent`, OLD.`system_host`,
                    OLD.`start_timestsamp`, OLD.`last_access_time`,
                    1, (OLD.`last_access_time` - OLD.`start_timestsamp`));
      else
        update `sys_user_last_online`
          set `username` = OLD.`username`, `uid` = OLD.`id`, `host` = OLD.`host`, `user_agent` = OLD.`user_agent`,
            `system_host` = OLD.`system_host`, `last_login_timestamp` = OLD.`start_timestsamp`,
             `last_stop_timestamp` = OLD.`last_access_time`, `login_count` = `login_count` + 1,
             `total_online_time` = `total_online_time` + (OLD.`last_access_time` - OLD.`start_timestsamp`)
        where `user_id` = OLD.`user_id`;
      end if ;
   end if;
end;


create table `sys_organization`(
  `id`         bigint not null auto_increment,
  `name`      varchar(100),
  `type`      varchar(20),
  `parent_id` bigint,
  `parent_ids`  varchar(200) default '',
  `icon`       varchar(200),
  `weight`    int,
  `show`       bool,
  constraint `pk_sys_organization` primary key(`id`),
  index idx_sys_organization_name (`name`),
  index idx_sys_organization_type (`type`),
  index idx_sys_organization_parentId (`parent_id`),
  index idx_sys_organization_parentIds_weight (`parent_ids`, `weight`)
) charset=utf8 ENGINE=InnoDB;
alter table `sys_organization` auto_increment=1000;


create table `sys_job`(
  `id`         bigint not null auto_increment,
  `name`      varchar(100),
  `parent_id` bigint,
  `parent_ids`  varchar(200) default '',
  `icon`       varchar(200),
  `weight`    int,
  `show`       bool,
  constraint `pk_sys_job` primary key(`id`),
  index idx_sys_job_name (`name`),
  index idx_sys_job_parentId (`parent_id`),
  index idx_sys_job_parentIds_weight (`parent_ids`, `weight`)
) charset=utf8 ENGINE=InnoDB;
alter table `sys_job` auto_increment=1000;


create table `sys_user_organization`(
  `id`         bigint not null auto_increment,
  `user_id`   bigint,
  `organization_id` bigint,
  constraint `pk_sys_user_organization` primary key(`id`),
  constraint `unique_sys_user_organization` unique(`user_id`, `organization_id`)
) charset=utf8 ENGINE=InnoDB;

create table `sys_user_organization_job`(
  `id`         bigint not null auto_increment,
  `user_organization_id`   bigint,
  `job_id` bigint,
  constraint `pk_sys_user_organization_job` primary key(`id`),
  constraint `unique_sys_user_organization_job` unique(`user_organization_id`, `job_id`)
) charset=utf8 ENGINE=InnoDB;

create table `sys_resources_menu`(
  `id`         bigint not null auto_increment,
  `name`      varchar(100),
  `parent_id` bigint,
  `parent_ids`  varchar(200) default '',
  `icon`       varchar(200),
  `weight`    int,
  `show`       bool,
  constraint `pk_sys_resources_menu` primary key(`id`),
  index idx_sys_resources_menu_parentId (`parent_id`),
  index idx_sys_resources_menu_parentIds_weight (`parent_ids`, `weight`)
) charset=utf8 ENGINE=InnoDB;
alter table `sys_resources_menu` auto_increment=1000;
