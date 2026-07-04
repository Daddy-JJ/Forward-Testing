# Front End Product Requirement Document (FE-PRD)

Version: 1.1
Status: Approved

## Project
Forward Testing Strategy Platform

## Objectives
- Responsive HTML + Tailwind CSS Play CDN
- Modern light branding
- Frontend-first development
- Admin CMS
- Component-driven architecture
- Backend integration and scheduled jobs for approved market-data workflows

## Target Users
- Guest
- Member
- Admin

## Modules
### Public
Home, Features, Pricing, FAQ, About, Login, Register

### Member
Dashboard, Forward Testing, Strategies, Watchlist, Trade Journal, Reports, Portfolio, Profile, Billing

#### Watchlist - Daily Stock Monitoring

- Members can add stocks to a Watchlist.
- The system retrieves and stores the latest available daily stock price.
- A backend scheduler refreshes monitored prices once per applicable trading day after the market close.
- Each stored observation includes symbol, company name when available, exchange, currency, price, market date, provider, and retrieval status.
- The canonical monitored price is the provider's latest available end-of-day close for the applicable market date.
- The interface identifies stale, unavailable, or failed price updates.
- Market data is informational and must not be presented as investment advice or guaranteed real-time data.

#### Watchlist - Copy/Paste AI Extraction

- Members can paste plain text, copied tables, or CSV-like content containing stock names, symbols, and prices.
- AI extracts candidate company name, symbol, price, currency, and market date when those values are present.
- Extracted values are displayed in an editable preview before being added to the Watchlist.
- Users must explicitly confirm the preview; AI output must never be stored automatically.
- Missing or ambiguous values are flagged instead of invented.
- Candidate symbols are validated against the selected market-data provider before confirmation.
- A price extracted from pasted content is stored only as user-provided reference data and must remain distinct from the provider-sourced monitored price.
- Original pasted content is not retained after processing unless a later approved requirement states otherwise.

### Admin CMS
Dashboard, Users, Roles, Permissions, Pricing, Subscription, Landing Page, Blog, FAQ, Media, Analytics, Settings

## Non Functional
Responsive, Accessible, SEO-ready, Fast Loading, Component Based, Tailwind Native, No Frontend Build Tools, Secure Server-side Secrets, Observable Scheduled Jobs

## Market Data Provider

Primary provider: Twelve Data official API.

Selection rationale: Twelve Data documents official endpoints for symbol search, exchange metadata, latest/end-of-day prices, and daily time series, with international exchange coverage that includes Indonesia Stock Exchange instruments.

Approved capabilities:

- Symbol discovery and validation
- Exchange and instrument metadata
- Daily time-series or end-of-day prices
- Latest available price for fallback validation
- IDX and international market coverage subject to the subscribed plan

Provider requirements:

- API credentials must be stored and used only by the backend.
- Provider responses must be normalized before reaching the frontend.
- Rate limits, subscription entitlements, exchange delays, and redistribution rights must be verified against the selected Twelve Data plan before production release.
- Provider failures must not overwrite the last valid stored observation.
- A future provider replacement must preserve the normalized internal market-data contract.

Official references:

- API documentation: https://twelvedata.com/docs
- Market-data coverage: https://twelvedata.com/market-data

## Backend and Scheduler

- Backend services are permitted for market-data retrieval, AI extraction, validation, persistence, and scheduled jobs.
- The scheduler runs in the exchange timezone and skips non-trading days when exchange calendar data is available.
- Scheduled jobs must be idempotent and safe to retry.
- Job runs must record start time, completion time, status, provider response status, and failure reason.
- Backend language, framework, database, deployment target, and queue technology require approval before Phase 5 implementation.

## AI Processing

- AI processing runs through the backend; provider credentials are never exposed to the browser.
- AI output must use a structured schema and be validated by deterministic application logic.
- AI does not replace market-data-provider validation.
- The AI provider and model require approval before Phase 5 implementation.
- Pasted input must be treated as untrusted content and must not be interpreted as system instructions.

## Components
Navbar, Sidebar, Cards, Tables, Charts, Forms, Modal, Drawer, Toast, Pagination, Empty State, Skeleton

## Status
Approved
