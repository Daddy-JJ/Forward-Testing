# Front End Information Architecture

Version: 1.1
Status: Approved

## Scope

This document organizes the approved users and modules from FE-PRD.md. It does not define new features, URL paths, workflows, or permissions.

## User Areas

### Guest

Public-facing area available to unauthenticated users.

### Member

Member application area for authenticated members.

### Admin

Administration area for authenticated administrators.

## Page Inventory

### Public

- Home
- Features
- Pricing
- FAQ
- About
- Login
- Register

### Member

- Dashboard
- Forward Testing
- Strategies
- Watchlist
- Trade Journal
- Reports
- Portfolio
- Profile
- Billing

### Admin CMS

- Dashboard
- Users
- Roles
- Permissions
- Pricing
- Subscription
- Landing Page
- Blog
- FAQ
- Media
- Analytics
- Settings

## Navigation Hierarchy

### Public Navigation

- Home
- Features
- Pricing
- FAQ
- About
- Login
- Register

### Member Navigation

- Dashboard
- Forward Testing
- Strategies
- Watchlist
- Trade Journal
- Reports
- Portfolio
- Profile
- Billing

### Watchlist Functional Views

- Monitored stocks list
- Daily price status
- Add stock
- Copy/paste import
- AI extraction preview and confirmation
- Update failure or stale-data state

These views remain within the approved Watchlist module and do not add a new top-level navigation item.

### Admin Navigation

- Dashboard
- Users
- Roles
- Permissions
- Pricing
- Subscription
- Landing Page
- Blog
- FAQ
- Media
- Analytics
- Settings

The grouping, ordering, and nesting of navigation items remain subject to review.

## Access Boundaries

| Area | Guest | Member | Admin |
|------|-------|--------|-------|
| Public | Yes | Not specified | Not specified |
| Member | No | Yes | Not specified |
| Admin CMS | No | No | Yes |

Values marked `Not specified` require an explicit product decision before implementation.

## Shared UI Context

The approved component inventory includes Navbar, Sidebar, Cards, Tables, Charts, Forms, Modal, Drawer, Toast, Pagination, Empty State, and Skeleton. Assignment of these components to specific pages belongs to Phase 3 and later implementation phases.

## Open Decisions

- URL and route naming conventions
- Default destination after Login
- Whether Member and Admin can access Public pages while authenticated
- Whether Admin can access Member pages
- Navigation grouping, ordering, and nesting
- Mobile navigation structure
- Breadcrumb requirements
- Error and access-denied pages

These decisions are intentionally unresolved because they are not specified in the approved FE-PRD.
