-- Database initialization script for Forward Testing
-- Includes dummy price_observation seed data

CREATE DATABASE IF NOT EXISTS forward_testing CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE forward_testing;

CREATE TABLE IF NOT EXISTS role (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(32) NOT NULL UNIQUE,
  description VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS user_account (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255) NULL,
  role_id INT UNSIGNED NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY(role_id) REFERENCES role(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS watchlist_item (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  symbol VARCHAR(32) NOT NULL,
  name VARCHAR(255) NULL,
  exchange VARCHAR(64) NULL,
  currency VARCHAR(16) NULL,
  added_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notes TEXT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  FOREIGN KEY(user_id) REFERENCES user_account(id) ON DELETE CASCADE,
  UNIQUE KEY user_symbol_unique (user_id, symbol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS price_observation (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  watchlist_item_id INT UNSIGNED NOT NULL,
  provider VARCHAR(64) NOT NULL,
  symbol VARCHAR(32) NOT NULL,
  company_name VARCHAR(255) NULL,
  exchange VARCHAR(64) NULL,
  currency VARCHAR(16) NULL,
  market_date DATE NOT NULL,
  close_price DECIMAL(18,6) NULL,
  status ENUM('success','stale','failed','unavailable') NOT NULL DEFAULT 'success',
  provider_response JSON NULL,
  retrieved_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY(watchlist_item_id) REFERENCES watchlist_item(id) ON DELETE CASCADE,
  UNIQUE KEY watchlist_date_unique (watchlist_item_id, market_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed base roles
INSERT INTO role (name, description) VALUES
  ('Member', 'Member access role'),
  ('Admin', 'Admin CMS access role')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Seed one sample member user
INSERT INTO user_account (email, password_hash, full_name, role_id)
VALUES ('member@example.com', '$2y$12$examplehashexamplehashexamplehash', 'Demo Member', 1)
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name), role_id = VALUES(role_id);

-- Seed one sample watchlist item
INSERT INTO watchlist_item (user_id, symbol, name, exchange, currency, notes)
VALUES ((SELECT id FROM user_account WHERE email = 'member@example.com'), 'BBCA', 'Bank Central Asia', 'IDX', 'IDR', 'Demo watchlist item')
ON DUPLICATE KEY UPDATE name = VALUES(name), exchange = VALUES(exchange), currency = VALUES(currency), notes = VALUES(notes);

-- Seed dummy price observations for the watchlist item
INSERT INTO price_observation (watchlist_item_id, provider, symbol, company_name, exchange, currency, market_date, close_price, status, provider_response)
VALUES
  ((SELECT id FROM watchlist_item WHERE symbol = 'BBCA' AND user_id = (SELECT id FROM user_account WHERE email = 'member@example.com')),
   'Twelve Data', 'BBCA', 'Bank Central Asia', 'IDX', 'IDR', '2026-07-01', 8200.00, 'success', JSON_OBJECT('source', 'Twelve Data', 'raw_status', 'OK', 'note', 'Closed price imported')),
  ((SELECT id FROM watchlist_item WHERE symbol = 'BBCA' AND user_id = (SELECT id FROM user_account WHERE email = 'member@example.com')),
   'Twelve Data', 'BBCA', 'Bank Central Asia', 'IDX', 'IDR', '2026-07-02', 8275.00, 'success', JSON_OBJECT('source', 'Twelve Data', 'raw_status', 'OK', 'note', 'Daily close imported')),
  ((SELECT id FROM watchlist_item WHERE symbol = 'BBCA' AND user_id = (SELECT id FROM user_account WHERE email = 'member@example.com')),
   'Twelve Data', 'BBCA', 'Bank Central Asia', 'IDX', 'IDR', '2026-07-03', 8310.00, 'stale', JSON_OBJECT('source', 'Twelve Data', 'raw_status', 'DELAYED', 'note', 'Price data delayed'));
