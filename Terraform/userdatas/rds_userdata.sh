#!/bin/bash

yum install -y mysql
yum update -y

# MySQL 명령어 실행
mysql -h "${db_endpoint}" -u "${db_username}" -p"${db_password}" <<EOF
CREATE DATABASE IF NOT EXISTS userDB;
CREATE DATABASE IF NOT EXISTS gameDB;

#Table생성
USE userDB;
CREATE TABLE IF NOT EXISTS userTBL ( 
    id VARCHAR(10) NOT NULL PRIMARY KEY, 
    uid VARCHAR(255) NOT NULL,
    password CHAR(60) NOT NULL, 
    phone_number VARCHAR(10) NOT NULL, 
    balance BIGINT DEFAULT 0,
    modified_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

USE gameDB;
CREATE TABLE IF NOT EXISTS gameinfoTBL ( 
    id VARCHAR(10) NOT NULL,
    type ENUM('soccer', 'basketball', 'baseball', 'ladder') NOT NULL, 
    gameDate DATETIME NOT NULL,
    home VARCHAR(20) NOT NULL,
    away VARCHAR(20) NOT NULL,
    wdl ENUM('win', 'draw', 'lose')  NOT NULL,
    odds DECIMAL(5,2) NOT NULL,
    price BIGINT DEFAULT 0, 
    status BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id, gameDate)
);

CREATE TABLE IF NOT EXISTS gameresultTBL ( 
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
INSERT IGNORE INTO userTBL (id, uid, password, phone_number, balance)
VALUES ('user123', "${cognito_user_id}", '$2y$10$abcdefghijklmnopqrstuvwx', '01012345678', 10000);
ON DUPLICATE KEY UPDATE 
    uid = VALUES(uid),
    password = VALUES(password),
    phone_number = VALUES(phone_number),
    balance = VALUES(balance);
EOF