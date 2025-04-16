#!/bin/bash

yum install -y mysql
yum update -y

# MySQL 명령어 실행
mysql -h "${db_endpoint}" -u "${db_username}" -p"${db_password}" <<EOF
CREATE DATABASE IF NOT EXISTS userDB;
CREATE DATABASE IF NOT EXISTS gameDB;

#Table생성
USE userDB;
DROP TABLE IF EXISTS userTBL;
CREATE TABLE userTBL ( 
    id VARCHAR(10) NOT NULL PRIMARY KEY, 
    uuid VARCHAR(255) NOT NULL,
    nickname VARCHAR(30) NOT NULL,
    password CHAR(60) NOT NULL,
    e_mail VARCHAR(320) NOT NULL, 
    phone_number VARCHAR(10) NOT NULL, 
    balance BIGINT DEFAULT 0,
    modified_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

USE gameDB;
DROP TABLE IF EXISTS gameinfoTBL;
CREATE TABLE gameinfoTBL ( 
    id VARCHAR(10) NOT NULL,
    type ENUM('soccer', 'basketball', 'baseball', 'ladder') NOT NULL, 
    gameDate DATETIME NOT NULL,
    home VARCHAR(20) NOT NULL,
    away VARCHAR(20) NOT NULL,
    wdl ENUM('win', 'draw', 'lose')  NOT NULL,
    odds DECIMAL(5,2) NOT NULL,
    price BIGINT DEFAULT 0, 
    status BOOLEAN DEFAULT TRUE
);

DROP TABLE IF EXISTS gameresultTBL;
CREATE TABLE gameresultTBL ( 
    id VARCHAR(10) NOT NULL,
    type ENUM('soccer', 'basketball', 'baseball', 'ladder') NOT NULL, 
    gameDate DATETIME NOT NULL,
    home VARCHAR(20) NOT NULL,
    away VARCHAR(20) NOT NULL,
    odds DECIMAL(5,2) NOT NULL,
    price BIGINT DEFAULT 0, 
    result ENUM('win', 'lose')  NOT NULL,
    resultPrice BIGINT DEFAULT 0,
    PRIMARY KEY (id, gameDate), 
    FOREIGN KEY (id, gameDate) REFERENCES gameinfoTBL(id, gameDate) ON DELETE CASCADE
);

USE userDB;
INSERT INTO userTBL (id, uuid, nickname, password, e_mail, phone_number, balance)
VALUES ('dummyuser', "${cognito_user_id}", 'dummy', '$2y$10$abcdefghijklmnopqrstuvwx', 'dummyuser@example.com', '01012345678', 10000)
ON DUPLICATE KEY UPDATE 
    uuid = VALUES(uuid),
    password = VALUES(password),
    nickname = VALUES(nickname),
    e_mail = VALUES(e_mail),
    phone_number = VALUES(phone_number),
    balance = VALUES(balance);
EOF