# Phase 4 Landing Website Specification

Version: 1.0
Status: Approved

## Scope

Phase 4 implements the approved Public modules: Home, Features, Pricing, FAQ, About, Login, and Register.

## Routes

| Page | Static Route |
|------|--------------|
| Home | `index.html` |
| Features | `features.html` |
| Pricing | `pricing.html` |
| FAQ | `faq.html` |
| About | `about.html` |
| Login | `login.html` |
| Register | `register.html` |

## Shared Structure

- Desktop navigation includes Home, Features, Pricing, FAQ, About, Login, and Register.
- Mobile navigation uses an accessible disclosure menu.
- Public content pages use a shared footer.
- Login and Register use the shared public header and focused form layouts.

## Content Policy

- Draft marketing copy may be derived from approved product modules and objectives.
- Copy must not claim capabilities outside the approved FE-PRD.
- Pricing names, availability, and values remain draft until commercial approval.
- Login and Register forms are frontend-only in Phase 4 and do not imply backend behavior.

## Visual Asset

The Home hero uses a generated product-dashboard mockup representing the approved financial dashboard direction. It is illustrative and does not define final member-dashboard requirements.

## Technology

- HTML5
- Tailwind CSS Play CDN
- Vanilla JavaScript
- Lucide browser CDN
- Shared JavaScript components for repeated public navigation and footer markup
