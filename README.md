# Puerto BJJ Booking System

Web application for managing class bookings and memberships at Puerto Jiu-Jitsu Academy.

## Tech Stack

- **Ruby**: 4.0.1
- **Rails**: 8.1.2
- **CSS**: Tailwind CSS 4
- **JavaScript**: Stimulus + Importmap
- **Database**: SQLite (development & production)
- **Deployment**: Kamal 2.x
## Features

- 🔐 User authentication system

## Development Setup

```bash
# Install dependencies
bundle install

# Setup database
bin/rails db:setup

# Start development server
bin/dev
```

## Deployment

Deploy to production using Kamal:

```bash
kamal setup
kamal deploy
```

**Live URL**: https://booking.puertojiujitsu.com

All rights reserved © Puerto Jiu-Jitsu Academy
