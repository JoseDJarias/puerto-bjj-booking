# AI Assistant Context – Puerto BJJ Booking

## Project Summary
Rails 8.1 application for managing class bookings, memberships, and drop-in access at Puerto Jiu-Jitsu Academy.

**Current Tech Stack** (from README.md)
- Ruby 4.0.1 + Rails 8.1.2
- Tailwind CSS 4
- Hotwire (Turbo + Stimulus + Importmap)
- SQLite (dev & production)
- Kamal 2.x for deployment

## Core Guidelines
- Always follow the coding guidelines defined in the project's README.md.
- Prefer Hotwire patterns and Tailwind utilities.
- Keep controllers thin and move logic to models or concerns when appropriate.
- Use enums for roles and statuses.
- Maintain mobile-first responsive design.

## Important Reminders
- This is a 100% Rails project. Avoid introducing non-Rails patterns unless explicitly requested.
- When working with authorization, membership validation, or booking logic, reference the established patterns in the codebase.
- Class schedules include capacity checks (e.g., `full?` method).
- Do not mention internal implementation details from specific files unless directly necessary for the task.

## How to Use This File
This document provides high-level context. For detailed rules, always cross-reference:
- `README.md` (current open file in editor)
- `docs/coding_guidelines.md`
- `docs/authorization_and_memberships.md`

Keep responses concise, helpful, and aligned with the existing project conventions.