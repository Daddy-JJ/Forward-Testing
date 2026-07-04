# AGENTS.md

## Project Mode
Source of Truth (SOT) Driven

## Role
- Frontend Developer
- System Analyst
- Prompt Engineer

## Technology
- HTML5
- Tailwind CSS Play CDN (Native)
- Vanilla JavaScript
- Responsive-first
- Backend services and schedulers only for workflows explicitly approved in FE-PRD.md
- Server-side storage for all external API credentials

## Development Rules
1. Follow FE-PRD.md as the primary functional specification.
2. Follow FE-UI-Guideline.md as the visual design source of truth.
3. Track progress exclusively in FE-Implementation-Plan.md.
4. Do not implement code without explicit approval.
5. Update phase status before starting the next phase.
6. Build reusable components.
7. Keep files modular and maintainable.
8. Prioritize accessibility and responsive layouts.
9. Use light modern branding consistently.
10. Record any scope changes in the implementation plan.
11. Never call credentialed market-data or AI APIs directly from browser code.
12. Require user confirmation before persisting AI-extracted financial data.

## AI/Codex Guidelines
- Treat `FE-PRD.md` as the authoritative product definition and `FE-UI-Guideline.md` as the design authority.
- Use Codex-style reasoning to infer reusable component patterns but do not change feature scope without explicit approval.
- Prefer simple static HTML, Tailwind CSS, and vanilla JavaScript unless a documented dependency requires otherwise.
- Keep user-facing behavior consistent with approved wireframes and accessibility best practices.
- Do not expose API keys, secrets, or external service credentials in browser code or static assets.
- If a requested change impacts layout, data flow, or phase status, document the impact in `FE-Implementation-Plan.md`.
- When asked to continue content, preserve current project structure and add only what is needed for clarity or implementation.
- Use Indonesian for project annotations and developer-facing notes when the rest of the docs are in Indonesian.
- Keep design language modern, light, and responsive across mobile, tablet, and desktop breakpoints.

## Interaction Protocol
- Ajukan pertanyaan klarifikasi bila ruang lingkup atau persyaratan tidak jelas.
- Jawab permintaan dengan fokus pada deliverable yang dapat langsung dieksekusi.
- Hindari menambahkan fitur baru di luar kebutuhan yang disetujui.
- Gunakan bahasa Indonesia untuk catatan, kecuali nama teknis dan istilah produk perlu tetap dalam bahasa Inggris.

## Approval & Review
- Hentikan pekerjaan bila ada perubahan scope mayor dan minta persetujuan sebelum melanjutkan.
- Laporkan setiap ketergantungan baru pada `FE-Implementation-Plan.md` dan `FE-PRD.md`.
- Berikan ringkasan perubahan saat meminta review, termasuk efek pada layout, aksesibilitas, dan responsivitas.
- Prioritaskan perbaikan bug dan kualitas tampilan pada fase Review.

## Notes for Developers
- Gunakan komentar kode ringan hanya bila membantu pemahaman tim.
- Simpan markup HTML semantik dan pastikan elemen navigasi dapat diakses.
- Validasi setiap halaman di browser modern tanpa bergantung pada framework berat.
- Hindari `inline script` jika bisa dipisah ke file `app.js` di `assets/js/`.
