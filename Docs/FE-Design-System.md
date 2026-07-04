# Front End Design System

Version: 1.0
Status: Approved

## Scope

This document translates the approved FE-UI-Guideline into shared design-system rules. It defines semantic roles and component standards without adding product features or implementation code.

## Design Principles

- Light visual foundation
- Modern and clean presentation
- Financial-dashboard clarity
- Clear information hierarchy
- Reusable, component-driven patterns
- Responsive-first behavior
- Accessible interaction and content

## Design Tokens

### Typography

- Font family: Inter
- Hierarchy roles: page title, section title, component title, body, supporting text, and label
- Type treatments must preserve a clear hierarchy and readable contrast.
- Use the native Tailwind CSS type scale, font weights, and line heights.

### Color Roles

| Role | Approved Family | Intended Use |
|------|-----------------|--------------|
| Primary | Blue | Primary actions, active navigation, and focus emphasis |
| Neutral | Slate | Text, borders, surfaces, and supporting UI |
| Success | Green | Successful or positive status |
| Warning | Amber | Warning or attention status |
| Danger | Red | Destructive actions, errors, or negative status |

Color shades use the native Tailwind CSS palette. Primary actions use Blue 600 with Blue 700 for hover, Neutral uses the Slate family, and status colors use Green, Amber, and Red 600 with adjacent native shades for interaction states. Color must not be the only means of communicating status.

### Radius

Approved radius tokens:

- sm
- md
- lg
- xl
- 2xl

Controls and compact UI use `md`; content cards use `lg`; smaller or larger approved tokens may be used when the component context requires them.

### Spacing and Sizing

- Use the native Tailwind CSS spacing scale.
- Repeated components must share consistent spacing rules.
- Controls must provide accessible interaction targets.
- Use consistent native Tailwind CSS spacing assignments within repeated components.

## Component Standards

All components must support reusable structure, consistent naming, responsive behavior, keyboard access where interactive, visible focus, and WCAG-friendly contrast.

### Navigation

- Covers Navbar and Sidebar patterns.
- Must communicate current location visually and accessibly.
- Must support the Public, Member, and Admin contexts defined in the approved information architecture.
- Public mobile navigation uses a disclosure menu controlled by a labeled icon button.

### Buttons

- Used for clear user actions.
- Must define primary, neutral, and destructive semantic treatments where required by approved workflows.
- Must expose visible hover, focus, active, and disabled states.

### Inputs and Forms

- Every input must have an accessible label.
- Help and validation messages must be associated with their controls.
- Required, invalid, disabled, and read-only states must be distinguishable.
- Forms must remain keyboard operable.

### Cards

- Group directly related information or actions.
- Must not replace page hierarchy or create unnecessary nested containers.
- Repeated cards must use consistent internal spacing and heading structure.

### Tables

- Use semantic headers and preserve understandable row-column relationships.
- Provide a responsive treatment without hiding essential information.
- Sorting, filtering, selection, and actions are included only when required by an approved module.

### Charts

- Must include a textual label or equivalent context.
- Must not rely on color alone to distinguish data.
- Data visualization type and interaction remain module-level decisions.

### Modal and Drawer

- Must manage focus, support keyboard dismissal when appropriate, and return focus to the trigger.
- Must include an accessible name and a clear close action.
- Usage depends on an approved workflow.

### Toast

- Communicates transient feedback without taking focus unexpectedly.
- Message urgency must use an appropriate accessible announcement behavior.

### Pagination

- Must identify the current page and expose accessible controls.
- Page size and pagination rules remain module-level decisions.

### Empty State

- Must state that content is unavailable or absent.
- An action is included only when supported by an approved workflow.

### Skeleton

- Represents loading structure without presenting false content.
- Must not create disruptive layout shifts.
- Motion, if used, must respect reduced-motion preferences.

## Responsive Principles

The approved responsive contexts are Mobile, Tablet, Laptop, and Desktop.

- Start with the Mobile content and interaction model.
- Preserve content hierarchy across every context.
- Adapt navigation, tables, charts, forms, and overlays to available space.
- Avoid horizontal page overflow.
- Do not remove essential actions or information at smaller widths.
- Exact breakpoint values follow Tailwind CSS Play CDN defaults unless the SOT later approves custom values.

## Accessibility Requirements

- Full keyboard navigation for interactive controls
- Visible focus ring
- WCAG-friendly foreground and background contrast
- Semantic HTML as the implementation foundation
- Accessible names for controls and landmarks
- Programmatic labels and messages for forms
- Non-color indicators for status and validation
- Reduced-motion consideration for animated feedback

## Component State Baseline

Interactive components must define applicable default, hover, focus, active, disabled, loading, error, and success states. A state is implemented only when relevant to the component and an approved workflow.

## Open Decisions

- Chart palette and visualization conventions

Chart conventions remain deferred until a phase implements functional charts.

## Implementation Defaults

- Breakpoints: Tailwind CSS Play CDN defaults
- Icons: Lucide icons loaded from its browser CDN
- Styling: Tailwind CSS utility classes without a build step
- Shared behavior: Vanilla JavaScript
