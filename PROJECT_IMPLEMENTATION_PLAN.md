# SuGoRa Construction OS - Implementation Plan

> This plan incorporates the detailed product context in
> [chatgpt-update.md](./chatgpt-update.md). That file is the source context;
> this document is the working implementation reference.

## Purpose

This document is the durable product and implementation reference for SuGoRa
Construction OS. Read it before adding or changing a feature. The current
priority is to finish and validate the application features using mock
repositories. Do not start backend/API/database integration until the planned
frontend and domain feature stages are complete.

Current release target: `v2.0.0-beta`.

Current state: development prototype with mock/local repositories; not
production-ready.

## Product vision

SuGoRa is a construction management and operations OS. It should eventually
connect the complete project lifecycle:

```text
Client -> Project -> Design/Planning -> BOQ -> Materials/Procurement
-> Delivery/Inventory -> Workforce -> Tasks/Execution -> Quality
-> Bills/Payments -> Finance/Profitability -> Completion
```

The value comes from connected operational data. For example, a task can
require a quantity of steel; the requirement feeds procurement, purchase
orders, delivery, inventory, workforce consumption, task progress, cost, and
project financials.

## Current product position

The app is approximately at the first major third of the full product vision.

| Area | Status |
| --- | --- |
| Company | Pending |
| Clients | Foundation/partial |
| Projects | Strong foundation |
| Phases and timeline | Implemented |
| Tasks and execution | Basic lifecycle implemented; execution being built |
| Design and BOQ | Pending |
| Materials | Good foundation |
| Procurement and suppliers | Strong foundation |
| Workforce | Strong foundation |
| Daily site operations | Foundation |
| Quality | Pending |
| Logistics | Pending |
| Finance | Pending |
| Analytics | Foundation |
| Communication, documents, notifications | Pending |
| Backend and sync | Pending; intentionally deferred |
| AI | Future |

## What is implemented

### Projects and phases

Projects are the central object and are connected through `projectId` to:

- Project information and client relationship
- Phases
- Contacts
- Timeline
- Quotations
- Purchase quotations and purchase orders
- Material requirements
- Workforce records
- Daily site reports
- Tasks

Phases support planned and actual dates, status, progress, notes, and archive
state. This is the foundation for schedule variance, cost tracking, task
planning, labour allocation, material requirements, and profitability.

### Materials and procurement

Implemented foundations include:

- Material catalogue
- Phase-linked material requirements
- Procurement allocation against requirements
- Suppliers
- Purchase quotations and quotation line items
- Purchase orders and purchase-order line items
- Quotation-to-purchase-order conversion
- Duplicate conversion prevention
- Quantity and financial validation

The intended future material flow is:

```text
Required -> Ordered -> Dispatched -> Delivered -> Received -> Stored
-> Consumed -> Wasted
```

### Workforce and labour costing

Workers support name, phone, role, daily wage, overtime rate, active state, and
notes. Attendance supports present, half-day, absent, leave, hours worked, and
overtime hours.

Current costing rules:

- Present: full daily wage
- Half day: 50% of daily wage
- Absent/leave: zero base cost
- Overtime: overtime hours multiplied by the worker overtime rate
- No overtime multiplier is invented; the configured overtime rate is used

Implemented summaries include daily labour cost and labour cost by project
phase. These calculations are domain services and have automated tests.

### Daily site reports

Daily reports capture:

- Work completed
- Work planned for the next day
- Issues and delays
- Safety notes
- Quality notes
- General notes
- Project and date filtering

Reports are intended to become the project's operational memory.

### Tasks and basic lifecycle

Tasks currently support:

- Project and phase association
- Name and description
- Planned start/end
- Actual start/end
- Status: not started, in progress, completed, delayed, on hold
- Priority: low, medium, high, critical
- Progress percentage
- Notes
- Archive state
- Create, view, edit, archive
- Validation, loading, error, empty, and refresh states

The task lifecycle is the current implementation focus. The task should evolve
from a checklist into an execution record containing:

```text
What?         Foundation excavation
Where?        Foundation phase
When?         Planned and actual dates
Who?          Assigned crew
How much?     Planned quantity
Done?         Completed quantity
Materials?    Used quantities
Labour?       Assigned/costed labour
Issues?       Execution issues
Quality?      Inspection/quality information
Progress?     Daily progress updates
Completion?   Expected completion date
```

## Implementation sequence

Do not jump randomly between modules. Work in this order.

### Stage 1 - Finish execution

1. Task details
2. Task execution updates
3. Worker assignment to tasks
4. Task-level labour
5. Task progress history
6. Connect tasks with daily site reports
7. Planned versus actual execution

### Stage 2 - Quality

8. Inspections
9. Defects
10. Snag/punch lists
11. Corrective actions
12. Reinspection
13. Quality history

### Stage 3 - Materials and logistics

14. Delivery management
15. Inventory
16. Material receipt
17. Material consumption
18. Wastage
19. Material forecasting

### Stage 4 - Finance

20. Supplier bills
21. Supplier payments
22. Client invoices and milestones
23. Client payments
24. Expenses
25. Ledger
26. Cash flow
27. Project profitability
28. Cost variance

### Stage 5 - Planning

29. BOQ
30. Design management
31. Drawing revisions
32. Engineers and designers
33. Planned versus actual quantities

### Stage 6 - Business operations

34. Client CRM
35. Supplier performance
36. Documents
37. Reminders
38. Notifications
39. Communication
40. WhatsApp integration planning
41. Phone CRM

### Stage 7 - Production infrastructure

42. Authentication
43. Role-based access control
44. PostgreSQL backend
45. Offline database
46. Synchronization engine
47. Audit logs
48. Cloud storage
49. Backup and recovery
50. Production deployment

### Stage 8 - Intelligence

51. Advanced analytics
52. Cost forecasting
53. Schedule forecasting
54. Procurement recommendations
55. Labour optimization
56. Risk detection
57. Invoice/document extraction
58. AI project assistant
59. Project health score

## Architecture rules

The Flutter app uses a feature-first structure:

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

Each feature should follow:

```text
presentation -> domain -> repository -> data
```

Keep UI, business rules, and data access separate. Reuse existing entities,
repository interfaces, Riverpod providers, validation patterns, and domain
services before introducing new abstractions.

Do not introduce another dependency-injection framework. Riverpod remains the
dependency-injection and state-management mechanism.

## Backend deferral rule

The current repositories are intentionally mock/in-memory repositories. This
is not throwaway architecture: repository interfaces and provider wiring allow
remote implementations to replace mocks later.

Until the feature roadmap reaches the production-infrastructure stage:

- Do not add API calls.
- Do not create a backend service.
- Do not add database persistence.
- Do not add authentication or token handling.
- Do not change mock repositories to remote repositories.
- Do continue making entities and repository contracts realistic enough for
  future persistence.
- Do validate business behavior through domain and widget tests.
- Design new features so they do not assume permanent internet connectivity.
- Preserve the eventual offline-first direction:

  ```text
  Flutter UI -> Local database -> Sync engine -> Backend API -> PostgreSQL
  ```

When backend work eventually begins, the expected direction is:

```text
Flutter -> API client -> FastAPI -> PostgreSQL
                         -> Redis/storage/integrations
```

An offline database and synchronization layer may be added later.

## Development quality rules

- Build the feature completely through the UI, domain model, provider, and
  mock repository before moving on.
- Preserve project/phase relationships using stable IDs.
- Add validation for dates, quantities, progress, and lifecycle transitions.
- Keep business calculations in domain services rather than pages.
- Add focused tests for each new business rule.
- Handle loading, empty, error, retry, and refresh states.
- Prefer small reusable widgets over continually growing page files.
- Never silently lose data, overwrite unrelated records, create duplicate
  financial records, accept invalid quantities/date ranges, or associate
  records with nonexistent projects/phases.
- Financial records should eventually be auditable and should not be treated
  as ordinary destructively deletable records.
- Do not implement future AI, finance, quality, logistics, or backend behavior
  prematurely as placeholders unless the current feature explicitly needs a
  contract for it.
- Run `flutter analyze` and `flutter test` after coherent feature changes.

## Immediate working position

The project has:

```text
Project foundation
  -> Procurement foundation
  -> Workforce foundation
  -> Daily site report foundation
  -> Basic task lifecycle
  -> NEXT: Task execution management
```

The next implementation work should therefore focus on Stage 1, starting with
task details and execution updates, while keeping all data in the existing
mock-repository architecture.

### Completed Stage 1 slice: task details and execution update

Implemented in the current application:

- Dedicated task details route:
  `/projects/:projectId/tasks/:taskId`
- Tappable task cards from the project task list
- Task execution summary with progress and status
- Planned and actual date display
- Schedule variance display:
  on schedule, early, late, or overdue
- Description and execution-notes display
- Execution update dialog for:
  status
  actual start date
  actual end date
  progress
  execution notes
- Validation that progress stays within 0-100
- Validation that completed tasks are at 100%
- Validation that actual end is not before actual start

The next Stage 1 slice is worker assignment to tasks. That should introduce
task-worker relationships without adding backend integration or bypassing the
existing repository/provider architecture.

### Completed Stage 1 slice: worker assignment to tasks

Implemented in the current application:

- `ProjectTask.assignedWorkerIds` relationship field
- Existing active worker list reused through `workersProvider`
- Assigned workers shown on the task details page
- Worker role labels shown with each assignment
- Assign-workers dialog with active-worker selection
- Individual worker removal
- Assignment preservation through task creation, editing, execution updates,
  and archive operations
- Sample excavation task seeded with two worker assignments

The next Stage 1 slice is task-level labour tracking. It should build on these
worker assignments and existing attendance/labour-cost calculations without
adding backend integration.
