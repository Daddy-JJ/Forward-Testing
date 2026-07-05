# Database Schema & CRUD Specifications

## Platform Context
Project: Forward Testing Strategy Platform
Database server: MariaDB 10.4.28 (Localhost via UNIX socket)
Character set: `utf8mb4`

## Data model overview
Target users:
- Guest
- Member
- Admin

Key domains:
- Authentication / Authorization
- Member watchlist and monitored stock prices
- Trade journal entries
- Portfolio holdings
- AI paste extraction preview history
- Market-data provider observations and job runs
- Admin CMS controls and subscription state

---

## MySQL schema

```sql
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
  PRIMARY KEY(role_id, permission_id),
  FOREIGN KEY(role_id) REFERENCES role(id) ON DELETE CASCADE,
  FOREIGN KEY(permission_id) REFERENCES permission(id) ON DELETE CASCADE
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
  FOREIGN KEY(role_id) REFERENCES role(id) ON DELETE RESTRICT
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
  FOREIGN KEY(user_id) REFERENCES user_account(id) ON DELETE CASCADE,
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
  FOREIGN KEY(watchlist_item_id) REFERENCES watchlist_item(id) ON DELETE CASCADE,
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
  FOREIGN KEY(user_id) REFERENCES user_account(id) ON DELETE CASCADE
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
  FOREIGN KEY(user_id) REFERENCES user_account(id) ON DELETE CASCADE
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
  FOREIGN KEY(user_id) REFERENCES user_account(id) ON DELETE CASCADE,
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

-- Admin-managed content placeholders
CREATE TABLE IF NOT EXISTS admin_page_section (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  slug VARCHAR(64) NOT NULL UNIQUE,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Optional: subscription state for future billing
CREATE TABLE IF NOT EXISTS subscription_plan (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(128) NOT NULL,
  price DECIMAL(12,2) NOT NULL DEFAULT 0,
  interval ENUM('monthly','annual','one_time') NOT NULL DEFAULT 'monthly',
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
  FOREIGN KEY(user_id) REFERENCES user_account(id) ON DELETE CASCADE,
  FOREIGN KEY(subscription_plan_id) REFERENCES subscription_plan(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## CRUD Specifications

### 1. User Account

**Create**
- Register new member with `email`, `password_hash`, optional `full_name`.
- Assign default role `Member`.

**Read**
- Retrieve user profile by `id` or `email`.
- Return `email`, `full_name`, `role_id`, `is_active`, timestamps.

**Update**
- Update `full_name`, `password_hash`, `role_id`, and `is_active`.
- Admin can change user role and activation state.

**Delete**
- Soft delete by setting `is_active = 0`, or hard delete user account row.

```sql
INSERT INTO user_account (email, password_hash, full_name, role_id)
VALUES ('member@example.com', '<hash>', 'Member Name', 2);

SELECT id, email, full_name, role_id, is_active, created_at FROM user_account WHERE email = 'member@example.com';

UPDATE user_account SET full_name = 'Updated Name', updated_at = NOW() WHERE id = 1;

DELETE FROM user_account WHERE id = 1;
```

### 2. Role / Permission

**Create**
- Add admin roles, member roles, and role permissions.

**Read**
- List roles and assigned permissions.

**Update**
- Change role descriptions or permission assignments.

**Delete**
- Remove role-permission mapping or delete role if unused.

```sql
INSERT INTO role (name, description) VALUES ('Member', 'Member access');
INSERT INTO role (name, description) VALUES ('Admin', 'Admin CMS access');

INSERT INTO permission (name, description) VALUES ('manage_users', 'Can manage users');
INSERT INTO role_permission (role_id, permission_id) VALUES (2, 1);
```

### 3. Watchlist Item

**Create**
- Add a stock symbol to a member watchlist.
- Include optional `name`, `exchange`, `currency`, and `notes`.

**Read**
- Retrieve watchlist items by `user_id`.
- Include latest provider observation and status.

**Update**
- Edit `name`, `exchange`, `currency`, `notes`, or `is_active`.

**Delete**
- Remove watchlist item and its price observations.

```sql
INSERT INTO watchlist_item (user_id, symbol, name, exchange, currency, notes)
VALUES (1, 'BBCA', 'Bank Central Asia', 'IDX', 'IDR', 'Long-term blue chip');

SELECT wi.*, po.close_price, po.market_date, po.status
FROM watchlist_item wi
LEFT JOIN price_observation po ON po.watchlist_item_id = wi.id
WHERE wi.user_id = 1
ORDER BY po.market_date DESC LIMIT 1;

UPDATE watchlist_item SET notes = 'Updated notes' WHERE id = 1;

DELETE FROM watchlist_item WHERE id = 1;
```

### 4. Price Observation

**Create**
- Store provider-sourced daily close price after successful retrieval.
- Record `provider_response` for diagnostics.

**Read**
- Fetch price history for a watchlist item.
- Filter by `market_date` or `status`.

**Update**
- Refresh observation status or close price when scheduler reruns.

**Delete**
- Delete stale or invalid observations if needed.

```sql
INSERT INTO price_observation (watchlist_item_id, provider, symbol, company_name, exchange, currency, market_date, close_price, status, provider_response)
VALUES (1, 'Twelve Data', 'BBCA', 'Bank Central Asia', 'IDX', 'IDR', '2026-07-04', 8200.00, 'success', JSON_OBJECT('raw', '...'));

SELECT * FROM price_observation WHERE watchlist_item_id = 1 ORDER BY market_date DESC;

UPDATE price_observation SET status = 'stale', updated_at = NOW() WHERE id = 1;

DELETE FROM price_observation WHERE id = 1;
```

### 5. AI Extraction Preview

**Create**
- Save pasted-content preview results before user confirmation.

**Read**
- Retrieve previews created by a member.

**Update**
- Mark `is_confirmed = 1` and set `confirmed_at` when user confirms.

**Delete**
- Remove preview history when discarded.

```sql
INSERT INTO ai_extraction_preview (user_id, original_text, extracted_json)
VALUES (1, 'BBCA, 8,200', JSON_OBJECT('symbol', 'BBCA', 'price', '8200', 'currency', 'IDR'));

SELECT * FROM ai_extraction_preview WHERE user_id = 1;

UPDATE ai_extraction_preview SET is_confirmed = 1, confirmed_at = NOW() WHERE id = 1;

DELETE FROM ai_extraction_preview WHERE id = 1;
```

### 6. Trade Journal

**Create**
- Add journal entries for a member's trades.

**Read**
- List entries by `user_id`.

**Update**
- Change notes, outcome, or title.

**Delete**
- Remove entry.

```sql
INSERT INTO trade_journal_entry (user_id, title, entry_date, notes, outcome)
VALUES (1, 'BBCA review', '2026-07-04', 'Entry analysis text', 'pending');

SELECT * FROM trade_journal_entry WHERE user_id = 1 ORDER BY entry_date DESC;

UPDATE trade_journal_entry SET outcome = 'win' WHERE id = 1;

DELETE FROM trade_journal_entry WHERE id = 1;
```

### 7. Portfolio Holding

**Create**
- Add or update a holding.

**Read**
- Query holdings for portfolio view.

**Update**
- Adjust `quantity`, `average_cost`, and `currency`.

**Delete**
- Remove a holding.

```sql
INSERT INTO portfolio_holding (user_id, symbol, quantity, average_cost, currency)
VALUES (1, 'BBCA', 100, 7800.00, 'IDR');

SELECT * FROM portfolio_holding WHERE user_id = 1;

UPDATE portfolio_holding SET quantity = 120, average_cost = 7900.00 WHERE id = 1;

DELETE FROM portfolio_holding WHERE id = 1;
```

### 8. Provider Job Run

**Create**
- Record scheduler run start.

**Read**
- Inspect recent job history and failure reasons.

**Update**
- Set completion time, status, response code, and failure reason.

**Delete**
- Archive or delete old jobs if retention policy requires it.

```sql
INSERT INTO provider_job_run (provider, job_type, start_time, status, context_json)
VALUES ('Twelve Data', 'watchlist_refresh', NOW(), 'running', JSON_OBJECT('comment', 'daily IDX update'));

UPDATE provider_job_run
SET completion_time = NOW(), status = 'success', provider_status_code = 200
WHERE id = 1;

SELECT * FROM provider_job_run ORDER BY start_time DESC LIMIT 50;

DELETE FROM provider_job_run WHERE id = 1;
```

### 9. Admin Page Section

**Create**
- Add content section for CMS-managed landing or help pages.

**Read**
- Retrieve content by `slug`.

**Update**
- Edit page `title` or `body`.

**Delete**
- Remove unused CMS section.

```sql
INSERT INTO admin_page_section (slug, title, body)
VALUES ('faq', 'FAQ', 'Frequently asked questions content.');

SELECT * FROM admin_page_section WHERE slug = 'faq';

UPDATE admin_page_section SET body = 'Updated content' WHERE slug = 'faq';

DELETE FROM admin_page_section WHERE slug = 'faq';
```

### 10. Subscription

**Create**
- Add plans and assign user subscriptions.

**Read**
- Query plan catalog and member subscriptions.

**Update**
- Change plan status or subscription state.

**Delete**
- Remove inactive plans if no subscriptions exist.

```sql
INSERT INTO subscription_plan (name, price, interval, description)
VALUES ('Basic', 0.00, 'monthly', 'Free member plan');

INSERT INTO user_subscription (user_id, subscription_plan_id, status)
VALUES (1, 1, 'active');

SELECT us.*, sp.name AS plan_name
FROM user_subscription us
JOIN subscription_plan sp ON sp.id = us.subscription_plan_id
WHERE us.user_id = 1;

UPDATE user_subscription SET status = 'cancelled', ended_at = NOW() WHERE id = 1;

DELETE FROM subscription_plan WHERE id = 1;
```

---

## Notes & Implementation Guidance

- Store API credentials and provider secrets only on the backend. Do not expose them to browser code.
- Normalize provider responses before saving to `price_observation`.
- Keep AI preview data separate from provider-sourced monitored prices.
- Use `role_permission` for admin-like feature gating rather than hard-coded role checks.
- Record scheduler job metadata for observability and retry diagnosis.
- Use `utf8mb4` on all tables for compatibility with international text.

---

## Recommended next step

Implement backend service layers for:
- user authentication and role enforcement,
- watchlist management,
- scheduled price refresh jobs,
- AI extraction preview workflow,
- provider job logging,
- admin CMS content management.
