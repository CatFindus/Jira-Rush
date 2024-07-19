--liquibase formatted sql

--changeset apuchinec:drop_all

DROP TABLE IF EXISTS USER_ROLE;
DROP TABLE IF EXISTS CONTACT;
DROP TABLE IF EXISTS MAIL_CASE;
DROP
SEQUENCE IF EXISTS MAIL_CASE_ID_SEQ;
DROP TABLE IF EXISTS PROFILE;
DROP TABLE IF EXISTS TASK_TAG;
DROP TABLE IF EXISTS USER_BELONG;
DROP
SEQUENCE IF EXISTS USER_BELONG_ID_SEQ;
DROP TABLE IF EXISTS ACTIVITY;
DROP
SEQUENCE IF EXISTS ACTIVITY_ID_SEQ;
DROP TABLE IF EXISTS TASK;
DROP
SEQUENCE IF EXISTS TASK_ID_SEQ;
DROP TABLE IF EXISTS SPRINT;
DROP
SEQUENCE IF EXISTS SPRINT_ID_SEQ;
DROP TABLE IF EXISTS PROJECT;
DROP
SEQUENCE IF EXISTS PROJECT_ID_SEQ;
DROP TABLE IF EXISTS REFERENCE;
DROP
SEQUENCE IF EXISTS REFERENCE_ID_SEQ;
DROP TABLE IF EXISTS ATTACHMENT;
DROP
SEQUENCE IF EXISTS ATTACHMENT_ID_SEQ;
DROP TABLE IF EXISTS USERS;
DROP
SEQUENCE IF EXISTS USERS_ID_SEQ;

--changeset apuchinec:create_tables

create table PROJECT
(
    ID bigserial primary key,
    CODE        varchar(32)   not null
        constraint UK_PROJECT_CODE unique,
    TITLE       varchar(1024) not null,
    DESCRIPTION varchar(4096) not null,
    TYPE_CODE   varchar(32)   not null,
    STARTPOINT  timestamp,
    ENDPOINT    timestamp,
    PARENT_ID   bigint,
    constraint FK_PROJECT_PARENT foreign key (PARENT_ID) references PROJECT (ID) on delete cascade
);

create table MAIL_CASE
(
    ID bigserial primary key,
    EMAIL     varchar(255) not null,
    NAME      varchar(255) not null,
    DATE_TIME timestamp    not null,
    RESULT    varchar(255) not null,
    TEMPLATE  varchar(255) not null
);

create table SPRINT
(
    ID bigserial primary key,
    STATUS_CODE varchar(32)   not null,
    STARTPOINT  timestamp,
    ENDPOINT    timestamp,
    CODE       varchar(32) not null,
    PROJECT_ID  bigint        not null,
    constraint FK_SPRINT_PROJECT foreign key (PROJECT_ID) references PROJECT (ID) on delete cascade,
    constraint UK_SPRINT_PROJECT_CODE unique(PROJECT_ID, CODE)
);

create table REFERENCE
(
    ID bigserial primary key,
    CODE       varchar(32)   not null,
    REF_TYPE   smallint      not null,
    ENDPOINT   timestamp,
    STARTPOINT timestamp,
    TITLE      varchar(1024) not null,
    AUX        varchar,
    constraint UK_REFERENCE_REF_TYPE_CODE unique (REF_TYPE, CODE)
);

create table USERS
(
    ID bigserial primary key,
    DISPLAY_NAME varchar(32)  not null
        constraint UK_USERS_DISPLAY_NAME unique,
    EMAIL        varchar(128) not null
        constraint UK_USERS_EMAIL unique,
    FIRST_NAME   varchar(32)  not null,
    LAST_NAME    varchar(32),
    PASSWORD     varchar(128) not null,
    ENDPOINT     timestamp,
    STARTPOINT   timestamp
);

create table PROFILE
(
    ID                 bigint primary key,
    LAST_LOGIN         timestamp,
    LAST_FAILED_LOGIN  timestamp,
    MAIL_NOTIFICATIONS bigint,
    constraint FK_PROFILE_USERS foreign key (ID) references USERS (ID) on delete cascade
);


create table TASK
(
    ID bigserial primary key,
    TITLE         varchar(1024) not null,
    TYPE_CODE     varchar(32)   not null,
    STATUS_CODE   varchar(32)   not null,
    PROJECT_ID    bigint        not null,
    SPRINT_ID     bigint,
    PARENT_ID     bigint,
    STARTPOINT    timestamp,
    ENDPOINT      timestamp,
    constraint FK_TASK_SPRINT foreign key (SPRINT_ID) references SPRINT (ID) on delete set null,
    constraint FK_TASK_PROJECT foreign key (PROJECT_ID) references PROJECT (ID) on delete cascade,
    constraint FK_TASK_PARENT_TASK foreign key (PARENT_ID) references TASK (ID) on delete cascade
);

create table ACTIVITY
(
    ID bigserial primary key,
    AUTHOR_ID     bigint not null,
    TASK_ID       bigint not null,
    UPDATED       timestamp,
    COMMENT       varchar(4096),
--     history of task field change
    TITLE         varchar(1024),
    DESCRIPTION   varchar(4096),
    ESTIMATE      integer,
    TYPE_CODE     varchar(32),
    STATUS_CODE   varchar(32),
    PRIORITY_CODE varchar(32),
    constraint FK_ACTIVITY_USERS foreign key (AUTHOR_ID) references USERS (ID) on delete cascade ,
    constraint FK_ACTIVITY_TASK foreign key (TASK_ID) references TASK (ID) on delete cascade
);

create table TASK_TAG
(
    TASK_ID bigint      not null,
    TAG     varchar(32) not null,
    constraint UK_TASK_TAG unique (TASK_ID, TAG),
    constraint FK_TASK_TAG foreign key (TASK_ID) references TASK (ID) on delete cascade
);

create table USER_BELONG
(
    ID bigserial primary key,
    OBJECT_ID      bigint      not null,
    OBJECT_TYPE    smallint    not null,
    USER_ID        bigint      not null,
    USER_TYPE_CODE varchar(32) not null,
    STARTPOINT     timestamp,
    ENDPOINT       timestamp,
    constraint FK_USER_BELONG foreign key (USER_ID) references USERS (ID) on delete cascade,
    constraint UK_USER_BELONG unique(OBJECT_ID, OBJECT_TYPE, USER_ID, USER_TYPE_CODE)
);
create index IX_USER_BELONG_USER_ID on USER_BELONG (USER_ID);

create table ATTACHMENT
(
    ID bigserial primary key,
    NAME        varchar(128)  not null,
    FILE_LINK   varchar(2048) not null,
    OBJECT_ID   bigint        not null,
    OBJECT_TYPE smallint      not null,
    USER_ID     bigint        not null,
    DATE_TIME   timestamp,
    constraint FK_ATTACHMENT foreign key (USER_ID) references USERS (ID) on DELETE cascade
);

create table USER_ROLE
(
    USER_ID bigint   not null,
    ROLE    smallint not null,
    constraint UK_USER_ROLE unique (USER_ID, ROLE),
    constraint FK_USER_ROLE foreign key (USER_ID) references USERS (ID) on delete cascade
);

--changeset apuchinec:populate_data
--============ References =================
insert into REFERENCE (CODE, TITLE, REF_TYPE)
-- TASK
values ('task', 'Task', 2),
       ('story', 'Story', 2),
       ('bug', 'Bug', 2),
       ('epic', 'Epic', 2),
-- SPRINT_STATUS
       ('planning', 'Planning', 4),
       ('active', 'Active', 4),
       ('finished', 'Finished', 4),
-- USER_TYPE
       ('project_author', 'Author', 5),
       ('project_manager', 'Manager', 5),
       ('sprint_author', 'Author', 5),
       ('sprint_manager', 'Manager', 5),
       ('task_author', 'Author', 5),
       ('task_developer', 'Developer', 5),
       ('task_reviewer', 'Reviewer', 5),
       ('task_tester', 'Tester', 5),
-- PROJECT
       ('scrum', 'Scrum', 1),
       ('task_tracker', 'Task tracker', 1),
-- CONTACT
       ('skype', 'Skype', 0),
       ('tg', 'Telegram', 0),
       ('mobile', 'Mobile', 0),
       ('phone', 'Phone', 0),
       ('website', 'Website', 0),
       ('vk', 'VK', 0),
       ('linkedin', 'LinkedIn', 0),
       ('github', 'GitHub', 0),
-- PRIORITY
       ('critical', 'Critical', 7),
       ('high', 'High', 7),
       ('normal', 'Normal', 7),
       ('low', 'Low', 7),
       ('neutral', 'Neutral', 7);

insert into REFERENCE (CODE, TITLE, REF_TYPE, AUX)
-- MAIL_NOTIFICATION
values ('assigned', 'Assigned', 6, '1'),
       ('three_days_before_deadline', 'Three days before deadline', 6, '2'),
       ('two_days_before_deadline', 'Two days before deadline', 6, '4'),
       ('one_day_before_deadline', 'One day before deadline', 6, '8'),
       ('deadline', 'Deadline', 6, '16'),
       ('overdue', 'Overdue', 6, '32'),
-- TASK_STATUS
       ('todo', 'ToDo', 3, 'in_progress,canceled|'),
       ('in_progress', 'In progress', 3, 'ready_for_review,canceled|task_developer'),
       ('ready_for_review', 'Ready for review', 3, 'in_progress,review,canceled|'),
       ('review', 'Review', 3, 'in_progress,ready_for_test,canceled|task_reviewer'),
       ('ready_for_test', 'Ready for test', 3, 'review,test,canceled|'),
       ('test', 'Test', 3, 'done,in_progress,canceled|task_tester'),
       ('done', 'Done', 3, 'canceled|'),
       ('canceled', 'Canceled', 3, null);
create table CONTACT
(
    ID    bigint       not null,
    CODE  varchar(32)  not null,
    VAL varchar(256) not null,
    primary key (ID, CODE),
    constraint FK_CONTACT_PROFILE foreign key (ID) references PROFILE (ID) on delete cascade
);