# Business Logic

## Project Details

- Company/Team Name: Hayag
- Project Code Name: Glass Squid
- Project Short Code: GS
- Short Description: A web app for transparent expense tracking and budget reporting for student organizations.
- Long Description:
  Student organizations often struggle to show where their money goes. Records live in notebooks or private spreadsheets, and members cannot easily check them. Hayag fixes this. Officers record income and expenses, and every expense needs a receipt. A second officer must verify each transaction before it counts in the totals. Members can see the budget, the spending, and the receipts at any time. Nothing is deleted. Officers void a transaction instead, and a history log records every important action. Organizations also collect fines from students, such as fines for absences or late arrivals. Each fine belongs to one student, and amounts can differ from student to student. A fine adds to the fund only after the student pays and a second officer verifies the payment. The app serves many organizations in one school. A student can belong to many organizations and have a different role in each. Each organization's data stays private from the others. Hayag only records money. It does not handle real payments. This is an academic project, not an official school app.

## User Levels

> Note: Modify/rename the list of users based on the actual users that you expect to use the system.

Admin is a system-wide account. It is not tied to one organization. Officer and Member roles belong to the membership, not to the user. A student can be an Officer in one organization and a Member in another. Visitors who are not logged in can only open the login page.

| User Level | Description |
| ---------- | ----------- |
| A. Admin | A system-wide account that creates organizations, adds students to organizations, marks memberships inactive, and sets or changes roles. Does not enter financial data. |
| B. Officer | Sets up the budget and categories, adds income and expense transactions, uploads receipts, verifies or rejects transactions entered by other officers, voids transactions, and exports the CSV report. Sets up fine types, issues fines, records fine payments, and waives fines. Can view everything a Member can view, including every student's fines. |
| C. Member | Views the dashboard, the transaction list, the receipts, and the history log of their organization. Views their own fines and the fine totals of the organization. Cannot add, edit, verify, or void anything. |

## System Requirements

1. The app shall allow the users to authenticate using Google Sign-In integration.
2. The app shall allow the users to see a list of the organizations they belong to, choose one as the active organization, and switch to another at any time.
3. The app shall allow admins to create organizations, add students to organizations, mark memberships inactive, and set or change their roles. An inactive member cannot open that organization. Their fines and records shall stay.
4. The app shall allow officers to create, edit, and remove budget categories. Every category shall have a type: income or expense. Only an expense category shall have an allocated amount. The Fines category shall be a system-created income category. Officers shall not edit or remove it.
5. The app shall allow officers to record income and expense transactions with a date, amount, category, description, and payee or source.
6. The app shall allow officers to upload a receipt (JPG, PNG, or PDF, up to 5 MB) for a transaction, and shall require a receipt for every expense.
7. The app shall allow officers to verify or reject a pending transaction entered by a different officer, and shall require a reason for every rejection.
8. The app shall allow officers to void a transaction with a reason, and shall keep voided transactions visible in the records. If an officer voids a verified fine payment, the fine shall return to Unpaid. The history log shall record the payment verification and the voiding action.
9. The app shall allow the members and officers to view a dashboard with the total budget, fund balance, verified income, verified expenses, remaining budget, pending amount, fines collected, fines outstanding, and a chart of allocated versus spent for each expense category. The chart shall not include Fines.
10. The app shall allow the members and officers to browse, search, filter, and sort the transactions of their organization and to open the full details of each transaction.
11. The app shall allow the members and officers to open receipts through short-lived private links. For fine payments, only officers and the fined student shall see the payee, reference number, and proof file. Other members shall see only "Fine payment" and the amount.
12. The app shall allow the members and officers to read a history log that shows who did what and when, and that nobody can edit or delete.
13. The app shall allow officers to export the transactions of their organization as a CSV report.
14. The app shall allow officers to create fine types, each with a name and a default amount (for example, "Absent, ₱50").
15. The app shall allow officers to issue a fine to one or many students at once. Each fine uses the default amount of its type. An officer can change the amount for one student only while the fine is Unpaid and has no payment recorded. The officer shall give a reason when doing so.
16. The app shall allow the members and officers to open a "My Fines" page that lists their own fines, with the reason, date, amount, status, and the total they still owe.
17. The app shall allow officers to record a payment for a fine with the full fine amount and the payment method. The app shall require a reference number or proof for digital payments. The server shall reject any payment that is not the full fine amount. The app shall create a pending income transaction from that payment in the "Fines" category, which every organization gets by default.
18. The app shall mark a fine as Paid only after a different officer verifies the payment. If the payment is rejected, the fine shall return to Unpaid.
19. The app shall allow officers to waive a fine with a reason. An officer shall not waive their own fine.
20. The app shall allow officers to view the full list of fines and the fined students. Other members shall see only their own fines and the totals of fines collected and outstanding.
21. The app shall use Admin as a system-wide account. It shall not tie an Admin to one organization.
22. The app shall allow an admin to add a student by school email address before the student's first login. When the student signs in with Google, the app shall link the account to that email.
23. The app shall restrict sign-in to school email addresses.
24. The app shall show a signed-in user with no organization this message: "Ask your admin to add you to an organization."

## Required Solution Layers

1. Security and privacy by design. Data Privacy Act compliance, location protection, retention limits, no per-user trails, aggregation thresholds, and consent for any data resale.
2. Accountability log, not surveillance. The history log records only financial and role actions (who did what, and when). Issuing, paying, verifying, voiding, and waiving fines count as financial actions. This is a deliberate, limited exception to "no per-user trails", because accountability for money is the main goal of the app. The app does not track browsing behavior, location, or any other activity. Only members of the same organization can read the log, and it is never shared outside the organization or sold.
3. Organization data isolation. Every query is filtered by organization, and the server checks that the user belongs to the active organization on every request.
4. Role enforcement on the server. Officer-only actions are checked on the server. An officer cannot verify or reject their own transaction, and an officer cannot waive their own fine.
5. Private receipt storage. Receipts stay in a private bucket and open only through short-lived signed links after a membership check.
6. Tamper-resistant records. Transactions and fines are never hard-deleted, and the history log cannot be edited.
7. Server-side validation. File type, file size, and all form input are validated on the server. Money is stored in whole centavos, and totals are computed on the server.
8. Fine privacy. A fine is personal data about one student. Only officers and the fined student can see the individual fine. Other members see totals only. This also applies to the transaction list and the history log: entries linked to a fine show the student's name only to officers, and other members see a generic "Fine payment" or "Fine issued". For a fine payment, the payee, reference number, and proof file are visible only to officers and the fined student. Other members see "Fine payment" and the amount. Fines always link to a user account, never to a typed name.

## MVP Features and Access

> See the User Levels table for reference.

| Feature | Access |
| ------- | ------ |
| 1. Google Sign-In, school-email linking, and logout | A,B,C |
| 2. Organization picker and switching | B,C |
| 3. Dashboard with defined totals, fines, and expense-category chart | B,C |
| 4. Transaction list with search, filter, and sort | B,C |
| 5. Transaction detail and receipt viewing | B,C |
| 6. History log | B,C |
| 7. Budget setup (income and expense categories and expense allocations) | B |
| 8. Add transaction and upload receipt | B |
| 9. Verify queue (verify or reject) | B |
| 10. Void transaction or verified fine payment | B |
| 11. CSV export | B |
| 12. Manage organizations, memberships, inactive status, and roles | A |
| 13. Fine types setup | B |
| 14. Issue fines (single or bulk) | B |
| 15. Fines list, record payment, and waive fine | B |
| 16. My Fines (own fines and total owed) | B,C |
| 17. No-organization access message | A,B,C |

## Fines

A fine is first an amount a student owes. It becomes fund money only after the student pays and a second officer verifies the payment. Unpaid fines never count in the fund balance. Fund balance is verified income minus verified expenses.

### Why amounts differ

- Each fine type has its own default amount. A late arrival costs less than an absence.
- A student with three absences has three fine records.
- An officer can change the amount on one fine only while it is Unpaid and has no payment recorded. The officer must write a reason.

### Flow

1. **Set up fine types.** An officer adds types such as "Late to meeting, ₱20" and "Absent, ₱50".
2. **Issue fines.** An officer picks the fine type, the date, and the students. The app creates one fine per student, each starting as Unpaid.
3. **Student sees the fine.** The student opens My Fines and sees each fine and the total still owed.
4. **Student pays.** The student pays an officer in cash or by e-wallet. The officer records the full payment. For a digital payment, the app requires a reference number or proof.
5. **Payment waits for verification.** The app creates a Pending income transaction. The fine shows "Payment pending".
6. **Second officer verifies.** The fine changes to Paid, and the income now counts in the fund balance.
7. **Payment rejected.** The fine returns to Unpaid, and the rejection reason is saved.
8. **Verified payment voided.** If an officer voids a verified fine payment, the fine returns to Unpaid. The history log records the verification and the voiding action.
9. **Waiving.** An officer waives a fine issued by mistake, or another fine, with a reason. The fine changes to Waived and no longer counts as owed.

### Fine statuses

| Status | Meaning | Counts in fund? |
| ------ | ------- | --------------- |
| Unpaid | Student owes the full amount | No |
| Payment pending | Payment recorded and waiting for a second officer | No |
| Paid | Payment verified by a different officer | Yes |
| Waived | Officer cancelled it with a reason | No |

### Who sees what

| Role | Sees |
| ---- | ---- |
| Officer | Every fine, every student, and every payment, including the payee, reference number, and proof file |
| Student with a fine | Only their own fines and payments, including the payee, reference number, and proof file |
| Other members | Only the totals: fines collected and fines outstanding. In transaction and history entries for a fine payment, they see "Fine payment" and the amount only. |

### Rules

- A fine always links to a user account, never to a typed name.
- A fine is never deleted. It is paid, waived, or left unpaid.
- An officer cannot verify a payment they recorded.
- An officer cannot waive their own fine.
- Each fine has exactly one payment, for the full amount. The server rejects any other amount. Installments are out of scope.
- A fine issued by mistake is waived with a reason.
- When a student leaves an organization, their unpaid fines stay in the records. The membership is marked inactive, not deleted.

## Notes

### Definitions

- Total budget: the sum of all expense allocations.
- Fund balance: verified income minus verified expenses.
- Remaining budget: allocated minus spent, per expense category.
- Pending amount: the total of transactions awaiting verification.
- Fines outstanding: the total of fines that are Unpaid or Payment pending.
- Fines collected: the total of verified fine payments.

- Key rule: An officer cannot verify their own transaction. A different officer must do it. Each organization needs at least two officers for the workflow to work.
- Only verified transactions count in the main totals. Pending transactions are shown separately. Rejected and voided transactions do not count.
- Joining an organization: For the MVP, the admin adds students to organizations by school email address before their first login (no join code). Demo data can be seeded by hand.
- Login: Users sign in with a school email address through Google and Supabase Auth, as the course requires. The app links the Google account to the email the admin added. Email and password login is not part of this version. A signed-in user with no organization sees: "Ask your admin to add you to an organization."
- Technical direction: Python with Flask, Supabase (PostgreSQL, Auth, and private Storage), Jinja templates with Bootstrap, and Chart.js. Flask uses the Supabase service key, so Flask must enforce privacy itself.
- Out of scope for the MVP: collecting payments, receipt text recognition (OCR), duplicate receipt or fraud detection, two-factor authentication, notifications, reimbursement requests, event or project budgets, PDF reports, offline mode, term locking and multi-year archives, a public page for people outside the organization, fine installments, fine disputes or comments, and automatic fines.
- Known limitation: Cash purchases with no receipt are not supported.
- Known limitation: Cash fine payments depend on the officer recording them honestly. A student who paid in cash but still sees "Unpaid" in My Fines can report it to another officer. The app has no dispute feature in this version.
- Open questions to settle as a team: row-level security or Flask checks only, which hosting service to use for the demo (Render or PythonAnywhere), and whether fined students should stay private (current choice) or be visible to all members.
