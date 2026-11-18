# Business Logic (v1.1 proposal)

> Proposed revision of `business-logic-v1.0.md`. This version tightens the
> product position, clarifies MVP behavior, and keeps later-stage ideas out of
> the first release. Team decisions that still block launch are listed at the
> end.

## Project Details

- **Company/team:** Hayag
- **Product:** Glass Squid
- **Short description:** A shared, receipt-backed expense and budget tracker
  for student organizations.
- **Positioning:** Glass Squid gives student organizations one transparent
  record of their funds: officers record transactions, a different officer
  verifies them, and members can see the same budget and supporting receipts.
- **Primary users:** Student-organization officers who manage funds and members
  who need to see how those funds are used. An organization needs at least two
  active officers to use transaction verification.
- **Problem solved:** Financial records kept in private spreadsheets or
  notebooks are difficult for members to inspect and difficult for officers to
  verify consistently.
- **Core value:** A clear, shared view of recorded income, spending, budget
  allocations, and receipts, with a second-officer check and a traceable
  history.
- **Boundaries:** Glass Squid records and reports transactions; it does not
  hold money, move funds, or replace official accounting, school approval, or
  audit processes. It is an academic project, not an official school app.

## User Levels

Roles are assigned per organization, not globally. A person's role and access
in one organization do not grant access to another organization's data.

| Role | Responsibilities and access |
| --- | --- |
| **Admin** | Creates and manages an organization, adds members, and assigns or changes organization roles. The management-only role cannot create, verify, or void financial transactions. |
| **Officer** | Sets category allocations; records and corrects transactions; attaches receipts; verifies or rejects transactions entered by another officer; voids transactions with a reason; and exports the organization's CSV. Can use all Member features. |
| **Member** | Read-only access to the organization's dashboard, transaction records, receipts, and history. |

An authenticated user with no membership can access no organization data. Removing
a membership or changing a role takes effect on the next server request. An
Admin who needs financial access must also be assigned the appropriate
financial role in that organization.

## System Requirements

1. **Sign-in:** Users sign in with Google and can sign out. Unauthenticated
   visitors see only sign-in and sign-up entry points.
2. **Organization access:** Users can select and switch among organizations
   where they have an active membership. Every request is authorized against
   that membership and role; a selected organization is not itself proof of
   access.
3. **Organization management:** Admins create organizations, add users by
   their Google account email, and assign or change roles. Role and membership
   changes are recorded in the history. No public join code is included in the
   MVP.
4. **Budget setup:** Officers create and update named categories with
   non-negative allocations. The MVP has one active budget per organization;
   the total budget is the sum of its category allocations. A category already
   used by a transaction cannot be hard-deleted; it can be made inactive so
   past transactions remain understandable.
5. **Transaction entry:** Officers record income or expense with a date,
   positive amount in Philippine pesos, category, description, and source or
   payee. Income may have a receipt; every expense must have one.
6. **Transaction lifecycle:** New transactions are pending. A different
   officer may verify or reject a pending transaction; rejection requires a
   reason. Rejected transactions remain visible with their reason and may be
   corrected and resubmitted, preserving the prior decision in the history.
   Verified transactions cannot be edited; an officer corrects one by voiding
   it with a reason and recording a replacement. Voided records remain visible
   and excluded from totals.
7. **Receipts:** Officers attach JPG, PNG, or PDF receipts no larger than
   5 MB. Files are stored privately and can be opened only by current
   organization members through short-lived links. A file must be validated
   server-side; a browser-provided type or filename is not sufficient.
8. **Dashboard:** Members and officers see category allocations, verified
   income, verified expenses, available cash (verified income minus verified
   expenses), and pending amounts shown separately by income and expense.
   Pending, rejected, and voided transactions do not affect verified totals.
   The category chart compares each allocation with verified expenses in that
   category; it does not imply a bank balance or payment reconciliation.
9. **Transaction records:** Members and officers can view transaction details,
   search descriptions and payees/sources, and filter by date, type, category,
   and status. Receipt access follows the same membership checks as other
   organization data.
10. **History:** Members and officers can read an append-only history of
    financial and membership actions, including actor and time. It records
    transaction creation, edits, verification, rejection and voiding, plus
    budget, membership, and role changes. It does not record browsing
    behavior.
11. **CSV export:** Officers can export the current organization's transaction
    records, including dates, amounts, categories, descriptions,
    payees/sources, and statuses. The export contains no receipt links or
    records from other organizations.
12. **Money and input validation:** The server validates all inputs and
    permissions. Store money as whole centavos, reject invalid or negative
    transaction amounts, and compute displayed totals on the server.

## Trust, Privacy, and Implementation Constraints

1. **Organization isolation:** Check organization membership and role on every
   server request, including receipt access and CSV export. Never trust a
   client-supplied organization ID or role.
2. **Credential safety:** Keep the Supabase service key on the server only.
   The Flask server is responsible for authorization when using this
   privileged key; do not expose it in browser code or responses.
3. **Private records:** Store receipts in a private bucket. Issue short-lived
   links only after checking current membership. Do not put links in CSV files
   or the history log.
4. **Limited accountability logging:** Record only the financial and
   membership actions needed to explain the records. Do not collect location,
   browsing activity, or unrelated per-user analytics. Do not sell or share
   organization records for advertising.
5. **Privacy transparency:** Collect only the account and organization data
   needed to operate the service. Show a concise privacy notice explaining
   what is stored, who in the organization can see it, and how long it is
   retained. Confirm applicable privacy obligations and retention periods
   before real-user deployment; do not claim legal compliance until reviewed.
6. **Tamper resistance:** Do not hard-delete transactions or edit/delete
   history entries through the application. Correct financial mistakes with
   the void-and-replacement process.
7. **Usable first release:** The core flows must work on common mobile and
   desktop browsers, with clear validation and permission errors. Use the
   existing Flask, Supabase, Jinja, Bootstrap, and Chart.js direction unless
   the team decides otherwise.

## MVP Features and Access

| Feature | Admin | Officer | Member |
| --- | :---: | :---: | :---: |
| Sign in/out and switch among member organizations | Yes | Yes | Yes |
| Manage organization membership and roles | Yes | No | No |
| View dashboard and transaction list/details | No* | Yes | Yes |
| View receipts and history | No* | Yes | Yes |
| Set budget categories and allocations | No | Yes | No |
| Record transactions and attach receipts | No | Yes | No |
| Verify/reject another officer's transaction | No | Yes | No |
| Void a transaction with a reason | No | Yes | No |
| Export organization transactions to CSV | No | Yes | No |

`*` An Admin with a separate Officer or Member role may use the features for
that assigned role. Admin permissions alone do not grant financial-data access.

## Notes and Scope

- **MVP includes:** Google sign-in; organization and role management;
  transaction entry and verification; required expense receipts; budget
  categories; dashboard; searchable/filterable records; action history; and
  CSV export.
- **Not in the MVP:** Payments or bank connections, receipt OCR, fraud or
  duplicate detection, notifications, reimbursement workflows, event-level
  budgets, PDF reports, offline mode, join codes, public organization pages,
  multi-year archives, and automated term locking.
- **Known limitation:** Cash purchases without a receipt are not supported.
- **Technical direction:** Python with Flask, Supabase (PostgreSQL, Auth, and
  private Storage), Jinja templates with Bootstrap, and Chart.js. The server
  must enforce organization and role checks because it uses the Supabase
  service key.
- **Decisions required before launch:** Select the demo hosting provider and
  document the backup/recovery approach. Confirm the privacy notice and data
  retention period. Document and test the authorization approach, including
  protection against cross-organization access. These are launch decisions,
  not reasons to add new MVP features.
