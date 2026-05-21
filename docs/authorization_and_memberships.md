# Authorization & Membership Logic

## Roles & Permissions
The application uses a hierarchical role system:
- **Member** – basic user with limited access
- **Instructor** – can manage classes and check-ins
- **Admin** – full access to all administrative features

Users also have an approval status that determines whether they are considered "eligible" for booking.

## Memberships
Memberships are the primary way users gain ongoing access to classes. They are linked to plans and packages that define duration, pricing, and which class types are covered.

Key concepts:
- A membership is active only when its end date is in the future.
- Packages determine which classes a membership covers.
- Capacity checks on class schedules prevent overbooking.

## Drop-in Access
Users without an active membership can use drop-in tickets for single-class access. These tickets provide flexible entry and are validated on the day of the class.

## Access Rules
When determining whether a user can book a class, the system checks (in order):
1. Admin or instructor override
2. Active and approved status (eligibility)
3. Coverage through a current membership
4. Availability of a valid drop-in ticket

Class schedules enforce their own capacity limits regardless of access method.

## Recommendations
- When adding new class types or packages, update authorization logic carefully.
- Always consider both membership and drop-in paths when modifying booking rules.
- Keep eligibility and access checks centralized for consistency.