# Coding Guidelines

## General Principles
- Keep controllers thin. Move business logic to models or service objects.
- Prefer Hotwire patterns (Turbo Frames, Turbo Streams, Stimulus controllers) over custom JavaScript.
- Use Tailwind utility classes for all styling. Avoid custom CSS unless absolutely necessary.
- Write clear, intention-revealing method names.

## Rails & Ruby Conventions
- Follow Rails 8 defaults and naming conventions.
- Use scopes, validations, and callbacks responsibly.
- Prefer `enum` for status and role fields.
- Keep model files focused — extract complex logic into concerns when appropriate.

## Hotwire Best Practices
- Use Turbo Frames for partial page updates (e.g., booking forms, availability checks).
- Leverage Turbo Streams for real-time list updates (e.g., class rosters).
- Keep Stimulus controllers small and focused on one interaction.

## Tailwind Usage
- Use the project's existing design tokens and component classes.
- Maintain consistency with spacing, colors, and typography.
- Mobile-first responsive design is required for all views.

## Testing
- Write tests for all new models and critical business logic.
- Use system tests for user-facing booking flows.

## File Organization
- Keep views organized by resource (e.g., `app/views/bookings/`, `app/views/class_schedules/`).
- Admin-specific views live under `app/views/admin/`.