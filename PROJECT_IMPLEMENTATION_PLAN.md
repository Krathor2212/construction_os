# SuGoRa Construction OS

## Product implementation plan

> **Document status:** Active implementation source of truth
> **Release target:** `v2.0.0-beta`
> **Last updated:** 10 October 2026
> **Application state:** Development prototype

This document records the product direction, implementation order, architecture
constraints, completed feature slices, and the current definition of done.
Read it before starting a new feature or changing an existing domain model.

---

## Contents

- [1. Product vision](#1-product-vision)
- [2. Current project snapshot](#2-current-project-snapshot)
- [3. Product scope](#3-product-scope)
- [4. Architecture](#4-architecture)
- [5. Backend and persistence boundary](#5-backend-and-persistence-boundary)
- [6. Implementation roadmap](#6-implementation-roadmap)
- [7. Completed implementation](#7-completed-implementation)
- [8. Quality and engineering rules](#8-quality-and-engineering-rules)
- [9. Current working position](#9-current-working-position)
- [10. Definition of done](#10-definition-of-done)

---

## 1. Product vision

SuGoRa is a construction management and operations OS. It should connect the
complete project lifecycle:

```text
Client -> Project -> Planning/Design -> BOQ -> Materials/Procurement
-> Delivery/Inventory -> Workforce -> Tasks/Execution -> Quality
-> Bills/Payments -> Finance/Profitability -> Completion
```

The long-term value comes from connected operational data. For example, a
task's steel requirement should be traceable through procurement, purchase
orders, delivery, inventory, workforce consumption, progress, cost, and project
profitability.

### Guiding product principles

1. Build the operational workflow before the infrastructure.
2. Keep records connected by stable IDs.
3. Make schedule, cost, labour, and quality information visible at project and
   task level.
4. Preserve a path to offline-first use on construction sites.
5. Prefer explicit validation and auditable state changes over convenience.

---

## 2. Current project snapshot

| Area | Current state |
| --- | --- |
| Projects and phases | Strong foundation |
| Materials | Good foundation |
| Procurement and suppliers | Strong foundation |
| Workforce and labour costing | Strong foundation |
| Daily site operations | Foundation |
| Tasks and execution | Core execution slices implemented |
| Quality management | Full quality workflow implemented through unified quality history |
| Finance | Pending |
| Logistics and inventory | Delivery, inventory, stock movement, and forecasting foundations |
| Finance | Supplier bills, supplier payments, and client milestone invoicing foundations |
| Planning, BOQ, and design | Pending |
| Communication and documents | Pending |
| Backend, authentication, and sync | Intentionally deferred |
| AI and advanced intelligence | Future |

### Validation baseline

- Flutter static analysis: passing
- Automated test suite: **51 tests passing**
- Last validated: **10 October 2026**
- Data source: mock/in-memory repositories
- Production readiness: not yet ready
- Backend API: not yet integrated
- Authentication and authorization: not yet integrated

---

## 3. Product scope

### 3.1 Projects and phases

Projects are the central object. Current project relationships include:

- Client and project information
- Phases and timeline
- Contacts
- Quotations
- Purchase quotations and purchase orders
- Material requirements
- Workforce records
- Daily site reports
- Tasks
- Quality records

Phases support planned and actual dates, status, progress, notes, and archive
state. These relationships are the foundation for schedule variance, labour
allocation, material planning, quality tracking, and future profitability.

### 3.2 Materials and procurement

Implemented foundations include:

- Material catalogue
- Phase-linked material requirements
- Procurement allocation against requirements
- Suppliers
- Purchase quotations and line items
- Purchase orders and line items
- Quotation-to-purchase-order conversion
- Duplicate conversion prevention
- Quantity and financial validation

The intended material lifecycle is:

```text
Required -> Ordered -> Dispatched -> Delivered -> Received -> Stored
-> Consumed -> Wasted
```

### 3.3 Workforce and labour costing

Workers support name, phone, role, daily wage, overtime rate, active state, and
notes. Attendance supports present, half-day, absent, leave, hours worked, and
overtime hours.

Current costing rules:

- Present: full daily wage
- Half day: 50% of daily wage
- Absent or leave: zero base cost
- Overtime: overtime hours multiplied by the configured worker overtime rate
- No unconfigured overtime multiplier is invented

Daily labour, phase labour, and task labour summaries are calculated through
domain services and covered by automated tests.

### 3.4 Daily site reports

Daily reports capture:

- Work completed
- Work planned for the next day
- Issues and delays
- Safety notes
- Quality notes
- General notes
- Project and date filters
- Linked task IDs

Reports are intended to become the project's operational memory.

### 3.5 Task execution model

Tasks are evolving from checklist items into execution records:

```text
What?          Foundation excavation
Where?         Foundation phase
When?          Planned and actual dates
Who?           Assigned crew
How much?      Planned quantity
Done?          Completed quantity
Materials?     Used quantities
Labour?        Assigned and costed labour
Issues?        Execution issues
Quality?       Inspection and quality information
Progress?      Daily progress updates
Completion?    Expected completion date
```

---

## 4. Architecture

### 4.1 Feature-first structure

```text
lib/
  app/
  core/
    constants/
    errors/
    network/
    storage/
    utils/
    logging/
    widgets/
  features/
    projects/
    clients/
    procurement/
    suppliers/
    materials/
    workforce/
    finance/
    logistics/
    quality/
    tasks/
    communication/
```

Each feature should keep responsibilities separated:

```text
Presentation -> Domain -> Repository contract -> Data implementation
```

### 4.2 State management and dependency injection

Riverpod is the project's state-management and dependency-injection mechanism.
Do not introduce another dependency-injection framework.

The normal flow for a feature is:

```text
Page/widget
  -> Riverpod query or action provider
  -> Repository interface
  -> Mock repository today
  -> Remote/local implementation later
```

### 4.3 Relationship conventions

Use stable IDs for relationships:

- `projectId`
- `phaseId`
- `taskId`
- `workerId`

Examples already used in the application:

- Tasks use `assignedWorkerIds`.
- Daily reports use `taskIds`.
- Quality records can reference a project, phase, and optional task.

---

## 5. Backend and persistence boundary

### 5.1 Current decision

Backend integration is deliberately deferred. The current priority is to finish
and validate frontend and domain features using realistic mock repositories.

Do **not** add the following yet:

- API calls
- Backend services
- PostgreSQL persistence
- Authentication or token handling
- Role-based access control
- Offline database
- Synchronization engine
- Production deployment infrastructure

This is a sequencing decision, not a rejection of the backend architecture.
Repository interfaces and provider wiring are being kept realistic so data
implementations can be replaced later without rewriting the UI.

### 5.2 Target architecture

The eventual offline-first direction is:

```text
Flutter UI -> Local database -> Sync engine -> Backend API -> PostgreSQL
```

The expected backend direction is:

```text
Flutter -> API client -> FastAPI -> PostgreSQL
                         -> Redis/storage/integrations
```

When backend work begins, it should be introduced behind the existing
repository contracts rather than directly inside pages.

---

## 6. Implementation roadmap

Features are implemented in sequence. Do not jump to backend work or unrelated
infrastructure while the current feature stages are incomplete.

### Stage 1 - Execution

- [x] Task details
- [x] Task execution updates
- [x] Worker assignment
- [x] Task-level labour tracking
- [x] Task progress history
- [x] Task links to daily site reports
- [x] Planned versus actual execution

### Stage 2 - Quality

- [x] Inspections
- [x] Defects
- [x] Snag/punch lists
- [x] Corrective actions
- [x] Reinspection
- [x] Quality history

### Stage 3 - Materials and logistics

- [x] Delivery management
- [x] Inventory
- [x] Material receipt
- [x] Material consumption
- [x] Wastage
- [x] Material forecasting

### Stage 4 - Finance

- [x] Supplier bills
- [x] Supplier payments
- [x] Client invoices and milestones
- [ ] Client payments
- [ ] Expenses
- [ ] Ledger
- [ ] Cash flow
- [ ] Project profitability
- [ ] Cost variance

### Stage 5 - Planning

- [ ] BOQ
- [ ] Design management
- [ ] Drawing revisions
- [ ] Engineers and designers
- [ ] Planned versus actual quantities

### Stage 6 - Business operations

- [ ] Client CRM
- [ ] Supplier performance
- [ ] Documents
- [ ] Reminders
- [ ] Notifications
- [ ] Communication
- [ ] WhatsApp integration planning
- [ ] Phone CRM

### Stage 7 - Production infrastructure

- [ ] Authentication
- [ ] Role-based access control
- [ ] PostgreSQL backend
- [ ] Offline database
- [ ] Synchronization engine
- [ ] Audit logs
- [ ] Cloud storage
- [ ] Backup and recovery
- [ ] Production deployment

### Stage 8 - Intelligence

- [ ] Advanced analytics
- [ ] Cost forecasting
- [ ] Schedule forecasting
- [ ] Procurement recommendations
- [ ] Labour optimization
- [ ] Risk detection
- [ ] Invoice and document extraction
- [ ] AI project assistant
- [ ] Project health score

---

## 7. Completed implementation

### Stage 1: Task details and execution updates

- Dedicated task details route:
  `/projects/:projectId/tasks/:taskId`
- Tappable task cards from project task lists
- Execution summary with status and progress
- Planned and actual date display
- Schedule variance and overdue display
- Description and execution notes
- Execution update dialog
- Progress validation from 0 to 100
- Completed-task validation requiring 100% progress
- Actual end date validation
- Completed-task handling when the actual end date is missing

### Stage 1: Worker assignment

- `ProjectTask.assignedWorkerIds` relationship field
- Active worker list reused through existing providers
- Assigned workers and roles shown on task details
- Assign-workers dialog
- Individual worker removal
- Assignment preservation through create, edit, execution update, and archive
- Sample task assignments

### Stage 1: Task-level labour tracking

- Task labour summary entity and calculator
- Assigned-worker and attendance matching
- Project, phase, and task date-window filtering
- Base wage and overtime calculation
- Attendance count, hours, overtime, and total cost display
- Focused calculator tests

### Stage 1: Task progress history

- Progress update entity and repository abstraction
- In-memory history repository with sample data
- Riverpod history query and mutation providers
- Newest-first progress timeline on task details
- Automatic history entry after successful execution updates
- Ordering and persistence tests

### Stage 1: Daily site report connection

- Daily reports support linked task IDs
- Create and edit forms support task multi-selection
- Existing task links are preserved during editing
- Task details show linked reports
- Report details resolve and display linked task names
- Linked reports are sorted newest-first
- Repository coverage for linked report data

### Stage 1: Planned versus actual execution

- Planned date range and inclusive planned duration
- Actual date range and inclusive actual duration
- On-schedule, early, late, and overdue states
- Color-coded variance presentation
- Domain calculator and focused tests
- Completed tasks do not appear as in progress when the actual end date is
  missing; they show `Actual end date missing`

### Stage 2: Inspections

- Project inspection entity with phase/task association
- Results: passed, failed, and requires attention
- Mock repository with newest-first ordering
- Riverpod query and create action
- Project inspections screen
- Inspection form with inspector, phase, task, result, and notes
- Project navigation entry and route

### Stage 2: Defects

- Defect entity with project, phase, optional task, location, description,
  severity, status, and reported date
- Severity: low, medium, high, and critical
- Status: open, in progress, and resolved
- Mock repository with newest-first ordering
- Riverpod query, create, and update-status actions
- Project defects screen and creation form
- Inline status controls and project route

### Stage 2: Snag/punch lists

- Punch-list entity with phase/task association and location
- Priority: low, medium, high, and critical
- Status: open, in progress, and completed
- Mock repository with newest-first ordering
- Riverpod query, create, and update-status actions
- Project snag/punch-list screen and creation form
- Inline status controls and task context display

### Stage 2: Corrective actions

- Corrective-action entity with phase/task context
- Due date and responsible-person fields
- Priority: low, medium, high, and critical
- Status: open, in progress, and completed
- Mock repository with newest-first ordering
- Riverpod query, create, and update-status actions
- Project corrective-actions screen and creation form
- Due-date and overdue display
- Inline status controls and project route

### Stage 2: Reinspection

- Reinspection entity linked to the originating corrective action
- Original inspection result, follow-up result, inspector, date, and notes
- Optional phase and task context
- Reinspection repository with newest-first ordering
- Riverpod query and create-action providers
- Project reinspection screen and creation form
- Corrective-action selection when recording a follow-up inspection
- Project navigation entry and route

### Stage 2: Quality history

- Unified quality-history entry entity and type classification
- Project-level aggregation of inspections, defects, punch lists, corrective
  actions, and reinspections
- Newest-first chronological ordering
- Human-readable status and summary mapping for each quality record
- Riverpod project history provider
- Project quality-history screen and navigation route
- Repository coverage for aggregation, ordering, and project filtering

### Stage 3: Material delivery management

- Material delivery entity linked to the project, material requirement, and
  material
- Delivery lifecycle statuses: expected, in transit, partially received,
  received, and cancelled
- Quantity, unit, delivery date, supplier, delivery reference, notes, and
  optional purchase-order fields
- Mock repository with newest-first project delivery ordering
- Riverpod project query plus create and update actions
- Project material-deliveries screen with loading, empty, error, and success
  states
- Delivery form with requirement selection, positive quantity validation,
  supplier, reference, status, date, and notes
- Inline delivery status updates from each delivery card
- Material ID-to-name resolution in delivery cards
- Repository tests for project filtering/order and status updates
- Route and project-navigation integration
- Validated with `flutter analyze`, `flutter test`, and `git diff --check`

### Stage 3: Inventory, receipts, consumption, and wastage

- Material receipt entity linked to a project, material, and optional delivery
- Material consumption entity with optional phase/task context
- Material wastage entity with damage, excess, spoilage, quality-issue, and
  other reasons
- Mock repositories with project filtering and newest-first ordering
- Riverpod providers for receipts, consumption, wastage, and calculated stock
- Inventory calculator that derives received, consumed, wasted, and available
  quantities per material
- Project inventory screen with available-stock summaries
- Stock movement menu for recording receipts, consumption, and wastage
- Positive quantity and required-person validation for all stock movements
- Material catalog name and unit resolution in inventory forms and summaries
- Project route and navigation entry for material inventory
- Focused calculator and repository tests
- Validated with `flutter analyze`, `flutter test` (**51 tests passing**), and
  `git diff --check`

### Stage 3: Material forecasting

- Material forecast entity combining planned requirements with current stock
- Forecast calculator grouped by material
- Required, received, available, and projected-shortfall quantities
- Covered versus short status for each material
- Project forecast screen with material-name resolution
- Riverpod provider combining requirement and inventory providers
- Focused shortfall calculation test

### Stage 4: Supplier bills

- Supplier bill entity with bill number, supplier, dates, amount, paid amount,
  status, and outstanding balance
- Bill statuses: draft, submitted, partially paid, paid, overdue, and
  cancelled
- Project-scoped mock repository and Riverpod provider
- Supplier-bill list screen and create form
- Project navigation entry and route

### Stage 4: Supplier payments

- Supplier payment entity linked to a supplier bill
- Payment date, amount, method, reference, and notes
- Project-scoped mock repository and Riverpod provider
- Supplier-payment list screen and record-payment form
- Project navigation entry and route

### Stage 4: Client invoices and milestones

- Client invoice entity linked to a project milestone
- Invoice number, milestone, issue/due dates, amount, paid amount, status,
  and outstanding balance
- Invoice statuses: draft, issued, partially paid, paid, overdue, and
  cancelled
- Project-scoped mock repository and Riverpod provider
- Client invoice and milestone list screen with create form
- Project navigation entry and route
- Focused repository coverage for all three finance repositories
- Validated with `flutter analyze`, `flutter test` (**51 tests passing**), and
  `git diff --check`

---

## 8. Quality and engineering rules

### Feature completion

Before moving to the next feature, complete the full vertical slice:

1. Domain entity and business rules
2. Repository interface
3. Mock repository implementation
4. Riverpod query and mutation providers
5. Project navigation and route
6. UI for loading, empty, error, and success states
7. Create/edit/update interactions where applicable
8. Focused automated tests
9. `flutter analyze`
10. `flutter test`

### Data integrity

- Preserve project/phase/task relationships through stable IDs.
- Validate dates, quantities, progress, and lifecycle transitions.
- Keep calculations in domain services instead of pages.
- Never silently discard records or overwrite unrelated records.
- Prevent duplicate financial records.
- Reject invalid quantities and date ranges.
- Do not associate records with nonexistent projects or phases.
- Treat financial records as auditable records; do not design them around
  destructive deletion.

### UI reliability

Every data-driven screen should have intentional handling for:

- Loading
- Empty data
- Error
- Retry or refresh where relevant
- Successful create/update feedback

Prefer small reusable widgets over allowing page files to grow indefinitely.

### Scope discipline

Do not implement future AI, finance, logistics, backend, or synchronization
behaviour as disconnected placeholders. Add only the contracts needed by the
current feature.

---

## 9. Current working position

The current implementation position is:

```text
Project foundation
  -> Procurement foundation
  -> Workforce and labour costing
  -> Daily site report foundation
  -> Task execution foundation
  -> Quality management foundation
  -> Delivery management foundation
  -> Inventory, receipts, consumption, and wastage foundations
  -> Material forecasting foundation
  -> Supplier bills, payments, and client milestone invoicing foundations
  -> NEXT: Client payments
```

The quality stage is now complete for the current roadmap scope. The next
planned feature is **client payments**, building on issued client invoices and
milestone balances.

Before implementing inventory, preserve the current decisions:

- Keep it project-scoped.
- Build on material requirements and recorded deliveries.
- Use a mock repository and Riverpod providers.
- Do not introduce backend APIs or authentication.
- Add focused repository/domain tests.
- Keep received quantities separate from planned requirement quantities.
- Treat receipts as the point at which inbound deliveries become usable stock.
- Derive available stock as receipts minus consumption and wastage.
- Keep stock movement records auditable through stable IDs and dates.
- Keep supplier bills and payments as separate records linked by bill IDs.
- Keep client invoices tied to explicit project milestones.

Open design questions for the materials stage:

- Should delivery creation update the material requirement procurement status?
- Should delivery quantities be capped by the remaining requirement quantity?
- Should received deliveries automatically create inventory stock records?
- Should purchase orders be linked directly to delivery records?
- Should supplier payments automatically update linked bill balances?
- Should client payments automatically update invoice balances?
- Should quality history be shown directly on task details?

Resolve these questions when the relevant feature is implemented, not by adding
unrelated infrastructure now.

---

## 10. Definition of done

A feature is complete when:

- Its domain model represents the required business data.
- Its repository contract can later support a real data source.
- Its mock repository supports realistic create/read/update behaviour.
- Its Riverpod providers expose queries and mutations cleanly.
- Its UI is reachable from the appropriate project screen.
- Its loading, empty, error, and success states are handled.
- Invalid input is rejected visibly.
- Focused tests cover the important business rules.
- `flutter analyze` passes.
- `flutter test` passes.
- This document is updated with the completed slice and the next intended
  feature.

The backend phase begins only after the planned feature roadmap is substantially
complete and the project has a stable set of domain contracts to persist.
