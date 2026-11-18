# Business Logic

## Project Details

- Company/Team Name: Hayag
- Project Code Name: Glass Squid
- Project Short Code: GS
- Short Description: A web app for transparent expense tracking and budget reporting for student organizations.
- Long Description:
  Student organizations often struggle to show where their money goes. Records are kept in notebooks or private spreadsheets, and members have no easy way to check them. Hayag fixes this. Officers record income and expenses in the app, and every expense must have a receipt. A second officer must verify each transaction before it counts in the totals. Members can see the budget, the spending, and the receipts at any time. Nothing is ever deleted. Officers void a transaction instead, and a history log records every important action. The app serves many organizations in one school. A student can belong to many organizations and can have a different role in each one. Each organization's data stays private from the others. Hayag only records money. It does not handle real payments. This is an academic project and not an official school app.

## User Levels

Roles belong to the membership, not to the user. A student can be an Officer in one organization and a Member in another. Visitors who are not logged in can only open the login and sign-up pages.

| User Level       | Description |
| ---------------- | ----------- |
| A. Admin         | Creates organizations, adds students to organizations, and sets or changes roles. Does not enter financial data. |
| B. Officer       | Sets up the budget and categories, adds income and expense transactions, uploads receipts, verifies or rejects transactions entered by other officers, voids transactions, and exports the CSV report. Can view everything a Member can view. |
| C. Member        | Views the dashboard, the transaction list, the receipts, and the history log of their organization. Cannot add, edit, verify, or void anything. |

## System Requirements

1. The app shall allow the users to authenticate using Google Sign-In integration.
2. The app shall allow the users to see a list of the organizations they belong to, choose one as the active organization, and switch to another at any time.
3. The app shall allow admins to create organizations, add students to organizations, and set or change their roles.
4. The app shall allow officers to create, edit, and remove budget categories, each with an allocated amount.
5. The app shall allow officers to record income and expense transactions with a date, amount, category, description, and payee or source.
6. The app shall allow officers to upload a receipt (JPG, PNG, or PDF, up to 5 MB) for a transaction, and shall require a receipt for every expense.
7. The app shall allow officers to verify or reject a pending transaction entered by a different officer, and shall require a reason for every rejection.
8. The app shall allow officers to void a transaction with a reason, and shall keep voided transactions visible in the records.
9. The app shall allow the members and officers to view a dashboard with the total budget, verified income, verified expenses, remaining balance, pending amount, and a chart of allocated versus spent for each category.
10. The app shall allow the members and officers to browse, search, filter, and sort the transactions of their organization and to open the full details of each transaction.
11. The app shall allow the members and officers to open receipts through short-lived private links.
12. The app shall allow the members and officers to read a history log that shows who did what and when, and that nobody can edit or delete.
13. The app shall allow officers to export the transactions of their organization as a CSV report.

## Required Solution Layers

1. Security and privacy by design. Data Privacy Act compliance, location protection, retention limits, no per-user trails, aggregation thresholds, and consent for any data resale.
2. Accountability log, not surveillance. The history log records only financial and role actions (who did what, and when). This is a deliberate, limited exception to "no per-user trails", because accountability for money is the main goal of the app. The app does not track browsing behavior, location, or any other activity. Only members of the same organization can read the log, and it is never shared outside the organization or sold.
3. Organization data isolation. Every query is filtered by organization, and the server checks that the user belongs to the active organization on every request.
4. Role enforcement on the server. Officer-only actions are checked on the server. An officer cannot verify or reject their own transaction.
5. Private receipt storage. Receipts stay in a private bucket and open only through short-lived signed links after a membership check.
6. Tamper-resistant records. Transactions are never hard-deleted, and the history log cannot be edited.
7. Server-side validation. File type, file size, and all form input are validated on the server. Money is stored in whole centavos, and totals are computed on the server.

## MVP Features and Access

> See the User Levels table for reference.

| Feature                                            | Access |
| -------------------------------------------------- | ------ |
| 1. Google Sign-In and logout                       | A,B,C  |
| 2. Organization picker and switching               | B,C    |
| 3. Dashboard with totals and category chart        | B,C    |
| 4. Transaction list with search, filter, and sort  | B,C    |
| 5. Transaction detail and receipt viewing          | B,C    |
| 6. History log                                     | B,C    |
| 7. Budget setup (categories and allocations)       | B      |
| 8. Add transaction and upload receipt              | B      |
| 9. Verify queue (verify or reject)                 | B      |
| 10. Void transaction                               | B      |
| 11. CSV export                                     | B      |
| 12. Manage organizations, members, and roles       | A      |

## Notes

- Key rule: An officer cannot verify their own transaction. A different officer must do it. Each organization needs at least two officers for the workflow to work.
- Only verified transactions count in the main totals. Pending transactions are shown separately. Rejected and voided transactions do not count.
- Joining an organization: For the MVP, the admin adds students to organizations (no join code). Demo data can be seeded by hand.
- Login: Users sign in with Google through Supabase Auth, as the course requires. Email and password login is not part of this version.
- Technical direction: Python with Flask, Supabase (PostgreSQL, Auth, and private Storage), Jinja templates with Bootstrap, and Chart.js. Flask uses the Supabase service key, so Flask must enforce privacy itself.
- Out of scope for the MVP: collecting payments, receipt text recognition (OCR), duplicate receipt or fraud detection, two-factor authentication, notifications, reimbursement requests, event or project budgets, PDF reports, offline mode, term locking and multi-year archives, and a public page for people outside the organization.
- Known limitation: Cash purchases with no receipt are not supported.
- Open questions to settle as a team: row-level security or Flask checks only, and which hosting service to use for the demo (Render or PythonAnywhere).