-- Full database initialization script for Forward Testing
-- Includes complete schema plus dummy seed data for roles, users, watchlist, price observations,
-- portfolio holdings, trade journals, AI extraction previews, provider job runs, admin sections, and subscriptions.

CREATE DATABASE IF NOT EXISTS forward_testing CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE forward_testing;

-- Roles and permissions
CREATE TABLE IF NOT EXISTS role (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(32) NOT NULL UNIQUE,
  description VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS permission (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(64) NOT NULL UNIQUE,
  description VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS role_permission (
  role_id INT UNSIGNED NOT NULL,
  permission_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (role_id, permission_id),
  FOREIGN KEY (role_id) REFERENCES role(id) ON DELETE CASCADE,
  FOREIGN KEY (permission_id) REFERENCES permission(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Users
CREATE TABLE IF NOT EXISTS user_account (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255) NULL,
  role_id INT UNSIGNED NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES role(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Watchlist stock entries
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
  FOREIGN KEY (user_id) REFERENCES user_account(id) ON DELETE CASCADE,
  UNIQUE KEY user_symbol_unique (user_id, symbol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Provider-sourced daily price observations
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
  FOREIGN KEY (watchlist_item_id) REFERENCES watchlist_item(id) ON DELETE CASCADE,
  UNIQUE KEY watchlist_date_unique (watchlist_item_id, market_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- AI extraction candidate previews for pasted input
CREATE TABLE IF NOT EXISTS ai_extraction_preview (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  original_text TEXT NOT NULL,
  extracted_json JSON NOT NULL,
  is_confirmed TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  confirmed_at DATETIME NULL,
  FOREIGN KEY (user_id) REFERENCES user_account(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Member trade journal entries
CREATE TABLE IF NOT EXISTS trade_journal_entry (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  entry_date DATE NOT NULL,
  notes TEXT NULL,
  outcome ENUM('win','loss','breakeven','pending') DEFAULT 'pending',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES user_account(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Portfolio holdings
CREATE TABLE IF NOT EXISTS portfolio_holding (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  symbol VARCHAR(32) NOT NULL,
  quantity DECIMAL(18,6) NOT NULL DEFAULT 0,
  average_cost DECIMAL(18,6) NULL,
  currency VARCHAR(16) NULL,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES user_account(id) ON DELETE CASCADE,
  UNIQUE KEY user_symbol_portfolio (user_id, symbol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Market data provider job runs
CREATE TABLE IF NOT EXISTS provider_job_run (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  provider VARCHAR(64) NOT NULL,
  job_type VARCHAR(64) NOT NULL,
  start_time DATETIME NOT NULL,
  completion_time DATETIME NULL,
  status ENUM('pending','running','success','failed','skipped') NOT NULL DEFAULT 'pending',
  provider_status_code INT NULL,
  failure_reason VARCHAR(255) NULL,
  context_json JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Admin content placeholders
CREATE TABLE IF NOT EXISTS admin_page_section (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  slug VARCHAR(64) NOT NULL UNIQUE,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Subscription state
CREATE TABLE IF NOT EXISTS subscription_plan (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(128) NOT NULL,
  price DECIMAL(12,2) NOT NULL DEFAULT 0,
  billing_interval ENUM('monthly','annual','one_time') NOT NULL DEFAULT 'monthly',
  description TEXT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS user_subscription (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  subscription_plan_id INT UNSIGNED NOT NULL,
  status ENUM('active','past_due','cancelled','trialing') NOT NULL DEFAULT 'active',
  started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ended_at DATETIME NULL,
  FOREIGN KEY (user_id) REFERENCES user_account(id) ON DELETE CASCADE,
  FOREIGN KEY (subscription_plan_id) REFERENCES subscription_plan(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed roles
INSERT INTO role (name, description) VALUES
  ('Member', 'Member access role'),
  ('Admin', 'Admin CMS access role')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Seed permissions
INSERT INTO permission (name, description) VALUES
  ('view_reports', 'Can view reports and analytics'),
  ('manage_watchlist', 'Can add or remove watchlist items'),
  ('manage_journal', 'Can manage trade journal entries'),
  ('manage_portfolio', 'Can manage portfolio holdings'),
  ('manage_users', 'Can manage users and roles'),
  ('manage_content', 'Can manage admin page sections')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Map permissions to roles
INSERT IGNORE INTO role_permission (role_id, permission_id)
SELECT r.id, p.id FROM role r CROSS JOIN permission p
WHERE r.name = 'Admin';

INSERT IGNORE INTO role_permission (role_id, permission_id)
SELECT r.id, p.id FROM role r JOIN permission p ON p.name IN ('view_reports','manage_watchlist','manage_journal','manage_portfolio')
WHERE r.name = 'Member';

-- Seed users
INSERT INTO user_account (email, password_hash, full_name, role_id)
VALUES
  ('admin@example.com', '$2y$12$adminexamplehashadminexamplehashadminha', 'Demo Admin', (SELECT id FROM role WHERE name = 'Admin')),
  ('member@example.com', '$2y$12$memberexamplehashmemberexamplehashmemberh', 'Demo Member', (SELECT id FROM role WHERE name = 'Member'))
ON DUPLICATE KEY UPDATE
  full_name = VALUES(full_name),
  role_id = VALUES(role_id);

-- Seed subscription plan
INSERT INTO subscription_plan (name, price, billing_interval, description)
VALUES
  ('Free', 0.00, 'monthly', 'Basic access for members'),
  ('Pro', 29.99, 'monthly', 'Paid access with advanced features')
ON DUPLICATE KEY UPDATE
  price = VALUES(price),
  billing_interval = VALUES(billing_interval),
  description = VALUES(description);

-- Seed user subscription for member
INSERT INTO user_subscription (user_id, subscription_plan_id, status, started_at)
VALUES (
  (SELECT id FROM user_account WHERE email = 'member@example.com'),
  (SELECT id FROM subscription_plan WHERE name = 'Free'),
  'active',
  NOW()
)
ON DUPLICATE KEY UPDATE
  status = VALUES(status),
  subscription_plan_id = VALUES(subscription_plan_id),
  started_at = VALUES(started_at);

-- Seed watchlist items
INSERT INTO watchlist_item (user_id, symbol, name, exchange, currency, notes)
VALUES
  ((SELECT id FROM user_account WHERE email = 'member@example.com'), 'BBCA', 'Bank Central Asia', 'IDX', 'IDR', 'Demo watchlist item for BBCA'),
  ((SELECT id FROM user_account WHERE email = 'member@example.com'), 'TLKM', 'Telkom Indonesia', 'IDX', 'IDR', 'Demo watchlist item for TLKM')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  exchange = VALUES(exchange),
  currency = VALUES(currency),
  notes = VALUES(notes);

-- Seed portfolio holding
INSERT INTO portfolio_holding (user_id, symbol, quantity, average_cost, currency)
VALUES (
  (SELECT id FROM user_account WHERE email = 'member@example.com'),
  'BBCA', 150.00, 8000.00, 'IDR'
)
ON DUPLICATE KEY UPDATE
  quantity = VALUES(quantity),
  average_cost = VALUES(average_cost),
  currency = VALUES(currency);

-- Seed trade journal entry
INSERT INTO trade_journal_entry (user_id, title, entry_date, notes, outcome)
VALUES (
  (SELECT id FROM user_account WHERE email = 'member@example.com'),
  'Test trade setup for BBCA',
  '2026-07-02',
  'Initial strategy notes for BBCA position.',
  'pending'
)
ON DUPLICATE KEY UPDATE
  notes = VALUES(notes),
  outcome = VALUES(outcome),
  updated_at = NOW();

-- Seed AI extraction preview
INSERT INTO ai_extraction_preview (user_id, original_text, extracted_json, is_confirmed)
VALUES (
  (SELECT id FROM user_account WHERE email = 'member@example.com'),
  'Watch BBCA and TLKM for breakout patterns. Update the trade journal with daily notes.',
  JSON_OBJECT('symbols', JSON_ARRAY('BBCA','TLKM'), 'intent', 'monitor', 'priority', 'high'),
  0
);

-- Seed admin page section
INSERT INTO admin_page_section (slug, title, body, is_active)
VALUES
  ('welcome', 'Welcome to Forward Testing', 'This admin page section is a placeholder for CMS-managed dashboard content.', 1)
ON DUPLICATE KEY UPDATE
  title = VALUES(title),
  body = VALUES(body),
  is_active = VALUES(is_active);

-- Seed provider job run
INSERT INTO provider_job_run (provider, job_type, start_time, completion_time, status, provider_status_code, context_json)
VALUES (
  'Twelve Data',
  'daily_price_sync',
  NOW() - INTERVAL 1 HOUR,
  NOW() - INTERVAL 30 MINUTE,
  'success',
  200,
  JSON_OBJECT('watchlist_count', 2, 'notes', 'Completed successful sync for member watchlist')
);

-- Seed price observations for watchlist items
INSERT INTO price_observation (watchlist_item_id, provider, symbol, company_name, exchange, currency, market_date, close_price, status, provider_response)
VALUES
  ((SELECT id FROM watchlist_item WHERE user_id = (SELECT id FROM user_account WHERE email = 'member@example.com') AND symbol = 'BBCA'),
   'Twelve Data', 'BBCA', 'Bank Central Asia', 'IDX', 'IDR', '2026-07-01', 8200.00, 'success', JSON_OBJECT('source', 'Twelve Data', 'raw_status', 'OK', 'note', 'Close price imported')),
  ((SELECT id FROM watchlist_item WHERE user_id = (SELECT id FROM user_account WHERE email = 'member@example.com') AND symbol = 'BBCA'),
   'Twelve Data', 'BBCA', 'Bank Central Asia', 'IDX', 'IDR', '2026-07-02', 8275.00, 'success', JSON_OBJECT('source', 'Twelve Data', 'raw_status', 'OK', 'note', 'Daily close imported')),
  ((SELECT id FROM watchlist_item WHERE user_id = (SELECT id FROM user_account WHERE email = 'member@example.com') AND symbol = 'TLKM'),
   'Twelve Data', 'TLKM', 'Telkom Indonesia', 'IDX', 'IDR', '2026-07-01', 3900.00, 'success', JSON_OBJECT('source', 'Twelve Data', 'raw_status', 'OK', 'note', 'Close price imported'))
ON DUPLICATE KEY UPDATE
  close_price = VALUES(close_price),
  status = VALUES(status),
  provider_response = VALUES(provider_response),
  updated_at = NOW();
