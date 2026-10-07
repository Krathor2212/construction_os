# SuGoRa Construction OS — Project Context

## 1. Project Identity

**Product name:** SuGoRa Construction OS
**Repository:** `construction_os`
**Technology:** Flutter + Dart
**Current release:** `v2.0.0-beta`
**Current state:** Development prototype with mock/local repositories. Not production-ready.

SuGoRa Construction OS is a **Construction Management and Operations OS** designed from the perspective of a civil contractor / construction company.

The goal is to manage the complete operational lifecycle of a construction project in one system.

The system should eventually cover:

```text
Client
  ↓
Project
  ↓
Design / Planning
  ↓
BOQ / Material Requirements
  ↓
Suppliers / Quotations
  ↓
Purchase Orders
  ↓
Logistics / Delivery
  ↓
Inventory
  ↓
Workers / Labour
  ↓
Tasks / Execution
  ↓
Quality
  ↓
Bills / Payments
  ↓
Project Finance
  ↓
Profitability
  ↓
Completion
```

The application must eventually connect these areas rather than treating them as unrelated CRUD modules.

---

# 2. Product Vision

The system should answer five questions for a construction company:

### Money

* How much money came in?
* How much went out?
* What is outstanding?
* What is the project costing?
* Are we still profitable?

### Work

* What work is planned?
* What is currently happening?
* What is delayed?
* What is completed?
* What needs attention?

### Materials

* What materials are required?
* What has been ordered?
* What has arrived?
* What is currently available?
* What has been consumed?
* What has been wasted?

### Labour

* Who is working?
* Where are they working?
* How much are they costing?
* What is their attendance?
* How much overtime is being incurred?

### Problems

* What is delayed?
* What material is missing?
* What quality issue exists?
* Which payment is overdue?
* Which supplier is late?
* Which task is at risk?

The ultimate product should become the **operational control center for construction companies**.

---

# 3. Current Architecture

Flutter feature-first architecture:

```text
lib/
  app/
    app.dart
    router.dart
    theme/
      app_theme.dart
      app_colors.dart
      app_typography.dart
      app_spacing.dart

  core/
    constants/
    errors/
    network/
    storage/
    utils/
    logging/
    widgets/

  features/
    authentication/
    dashboard/
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

Feature structure:

```text
feature/
  data/
    datasources/
    models/
    repositories/

  domain/
    entities/
    repositories/
    usecases/

  presentation/
    pages/
    widgets/
    providers/
```

Use this structure consistently.

Do not introduce a completely different architecture for individual features.

---

# 4. Technology Stack

Current:

* Flutter
* Dart
* Riverpod
* go_router
* Dio
* json_serializable
* flutter_secure_storage

Planned:

* Drift / SQLite for offline-first storage
* FastAPI backend
* PostgreSQL
* Redis where required
* Object storage
* Push notifications
* Official WhatsApp Business/API integrations
* Authorized banking/payment integrations

Riverpod is currently used for dependency injection and state management.

Do not introduce another dependency injection framework unless there is a strong architectural reason.

---

# 5. Important Architectural Principles

## Repository abstraction

The UI/domain layer should not depend directly on mock implementations.

Example:

```dart
abstract interface class ProjectTaskRepository {
  Future<List<ProjectTask>> getTasks({
    required String projectId,
  });

  Future<ProjectTask> getTask(String id);

  Future<ProjectTask> createTask(ProjectTask task);

  Future<ProjectTask> updateTask(ProjectTask task);

  Future<void> deleteTask(String id);
}
```

Mock repositories are currently used.

Later they will be replaced with remote/local implementations without rewriting the UI.

---

## Offline-first

The eventual application should work even when site connectivity is poor.

Construction sites may have unreliable internet.

Long-term architecture:

```text
Flutter UI
   ↓
Local Database
   ↓
Sync Engine
   ↓
Backend API
   ↓
PostgreSQL
```

Do not design features in a way that assumes permanent internet connectivity.

---

## Financial correctness

Financial data is sensitive.

Never casually calculate or invent financial rules.

Examples:

* Worker daily wage must come from worker configuration.
* Overtime must use the configured overtime rate.
* Do not invent overtime multipliers.
* Supplier totals must be derived from actual line items.
* Payments must be auditable.
* Financial records should not be silently deleted.

Eventually financial changes should have audit history.

---

## Dynamic relationships

Do not hardcode:

```text
Project A
Phase 1
Supplier X
Worker Y
```

Use IDs and providers.

Examples:

```text
projectId
phaseId
workerId
supplierId
materialId
taskId
```

Display names should be loaded dynamically.

---

# 6. Current Major Features

## Projects

Implemented foundation:

* Project creation
* Project editing
* Project details
* Project phases
* Project timeline
* Project contacts
* Project quotations
* Purchase quotations
* Purchase orders
* Material requirements
* Workforce
* Daily site reports
* Tasks

Projects are the central parent entity.

---

# 7. Project Phases

Current entity:

```dart
class ProjectPhase {
  const ProjectPhase({
    required this.id,
    required this.projectId,
    required this.name,
    required this.plannedStartDate,
    required this.plannedEndDate,
    required this.status,
    this.actualStartDate,
    this.actualEndDate,
    this.progress = 0,
    this.notes,
    this.isArchived = false,
  });

  final String id;
  final String projectId;
  final String name;

  final DateTime plannedStartDate;
  final DateTime plannedEndDate;

  final DateTime? actualStartDate;
  final DateTime? actualEndDate;

  final ProjectPhaseStatus status;
  final double progress;

  final String? notes;
  final bool isArchived;
}
```

Statuses:

```text
notStarted
inProgress
completed
delayed
onHold
```

Phases are used by:

* Tasks
* Labour
* Material requirements
* Procurement
* Site reports
* Future quality
* Future financial analysis

---

# 8. Materials

Implemented foundation:

* Material management
* Material requirements
* Requirements linked to phases
* Procurement tracking foundation
* Procurement allocation
* Allocation validation
* Purchase order linking

Example:

```text
Foundation

Cement       300 bags
Steel        2500 kg
Sand         30 m³
Aggregate    25 m³
```

Long-term material lifecycle:

```text
Required
  ↓
Ordered
  ↓
Dispatched
  ↓
Delivered
  ↓
Received
  ↓
Stored
  ↓
Consumed
  ↓
Wasted
```

---

# 9. Suppliers & Procurement

Implemented:

* Supplier management
* Purchase quotations
* Quotation line items
* Financial correctness for quotation lines
* Purchase orders
* Purchase order CRUD
* Purchase order details
* Purchase order line items
* Quotation → PO conversion
* Duplicate conversion prevention
* PO financial correctness
* Material procurement allocation
* Allocation validation

Future:

* Supplier bills
* Supplier payments
* Credit
* Outstanding balances
* Delivery performance
* Supplier quality history
* Supplier reliability
* Historical pricing
* Supplier recommendation

---

# 10. Workforce

Worker entity contains:

```text
id
name
role
phone
dailyWage
overtimeRate
isActive
notes
```

Roles include:

```text
mason
helper
carpenter
electrician
plumber
painter
welder
supervisor
siteEngineer
other
```

Implemented:

* Worker management
* Project linking
* Attendance
* Phase allocation
* Daily allocation
* Labour cost calculation
* Labour cost by date
* Labour cost by phase
* Labour summaries

Attendance:

```text
Present
Half Day
Absent
Leave
```

Overtime is only valid for Present attendance.

Cost calculation:

```text
Present = daily wage
Half Day = daily wage × 0.5
Absent = 0
Leave = 0
Overtime = overtimeHours × overtimeRate
```

Do not invent additional labour-cost rules unless explicitly specified.

---

# 11. Daily Site Reports

Implemented.

A Daily Site Report contains:

```text
id
projectId
phaseId
date
workCompleted
workPlannedForNextDay
issuesAndDelays
safetyNotes
qualityNotes
generalNotes
```

The module supports:

* Create
* View
* Update
* Delete
* Project linking
* Phase linking
* Date filtering
* Polished detail view

Daily reports are intended to become an important operational source for future analytics and AI.

---

# 12. Tasks & Execution

This is the current active development area.

Task entity:

```dart
class ProjectTask {
  const ProjectTask({
    required this.id,
    required this.projectId,
    required this.phaseId,
    required this.name,
    required this.plannedStartDate,
    required this.plannedEndDate,
    required this.status,
    required this.priority,
    this.description,
    this.actualStartDate,
    this.actualEndDate,
    this.progress = 0,
    this.notes,
    this.isArchived = false,
  });

  final String id;
  final String projectId;
  final String phaseId;

  final String name;
  final String? description;

  final DateTime plannedStartDate;
  final DateTime plannedEndDate;

  final DateTime? actualStartDate;
  final DateTime? actualEndDate;

  final ProjectTaskStatus status;
  final ProjectTaskPriority priority;

  final double progress;

  final String? notes;
  final bool isArchived;
}
```

Statuses:

```text
notStarted
inProgress
completed
delayed
onHold
```

Priorities:

```text
low
medium
high
critical
```

Currently implemented:

* Task entity
* Task repository
* Mock repository
* Riverpod providers
* Task list page
* Task creation
* Task editing
* Task archive
* Task form
* Phase linking
* Planned dates
* Status
* Priority
* Progress
* Validation
* Task UI

Current task lifecycle:

```text
Create
  ↓
View
  ↓
Edit
  ↓
Archive
```

The next goal is to turn Tasks into actual **construction execution management**.

---

# 13. Immediate Next Task Area

Do NOT jump directly to unrelated modules.

First expand Tasks into execution tracking.

Planned:

## Task Details

A task should eventually show:

```text
Task
Phase
Description
Planned dates
Actual dates
Status
Priority
Progress
Assigned workers
Labour cost
Material usage
Execution notes
Issues
Quality information
Daily progress
```

Example:

```text
Foundation excavation

Phase:
Foundation

Planned:
22 Sep → 24 Sep

Actual:
22 Sep → ?

Progress:
45%

Workers:
2 Excavators
3 Helpers

Material:
...

Issues:
...

Quality:
...

Latest update:
...
```

---

# 14. Task Execution

Eventually tasks should track actual work.

For example:

```text
Planned quantity:
500 m³

Completed:
225 m³

Remaining:
275 m³

Progress:
45%
```

This should eventually support quantity-based progress, not just manually entered percentages.

---

# 15. Worker Assignment to Tasks

Tasks should eventually connect directly to workers.

Example:

```text
Task:
Foundation excavation

Assigned:
Worker A
Worker B
Worker C
```

This should allow:

* assignment
* removal
* daily workforce
* labour cost
* productivity analysis

Long-term:

```text
Task
 ↓
Workers
 ↓
Attendance
 ↓
Labour Cost
```

---

# 16. Task ↔ Daily Site Report

Daily reports and tasks should eventually connect.

Example:

```text
Daily Report — 24 Sep

Completed:
Foundation excavation reached Grid D.

Task:
Foundation excavation

Progress:
45% → 68%
```

This should create a historical execution trail.

---

# 17. Planned vs Actual

Eventually compare:

```text
Planned:
22 Sep → 24 Sep

Actual:
22 Sep → 27 Sep

Variance:
+3 days
```

This becomes the foundation for schedule analytics.

---

# 18. Quality Management

After execution foundation is stable, implement:

## Inspections

* Inspection
* Date
* Task/phase
* Inspector
* Result
* Notes

## Defects

* Defect
* Severity
* Location
* Description
* Photos/documents later
* Assigned person
* Due date
* Status

## Snag/Punch list

Track incomplete/defective work.

## Corrective actions

```text
Defect
 ↓
Action
 ↓
Correction
 ↓
Reinspection
 ↓
Pass / Fail
```

Quality must be traceable.

---

# 19. Logistics

Future module:

* Deliveries
* Vehicles
* Drivers
* Dispatch
* Expected arrival
* Actual arrival
* Transport cost
* Delivery status
* Material receiving

Lifecycle:

```text
PO
 ↓
Dispatch
 ↓
Transit
 ↓
Arrival
 ↓
Receiving
 ↓
Inventory
```

---

# 20. Inventory & Material Consumption

Future:

* Stock
* Receipts
* Issues
* Consumption
* Wastage
* Transfers
* Stock adjustments

System should eventually answer:

> How much cement is currently available?

> How much steel has been consumed?

> Is consumption higher than BOQ?

---

# 21. Finance

Future major module.

Client side:

* Contract value
* Milestones
* Invoices
* Client payments
* Outstanding amount

Supplier side:

* Bills
* Payments
* Credit
* Outstanding

Project side:

* Labour
* Materials
* Transport
* Equipment
* Miscellaneous expenses

---

# 22. Project Ledger

Every financial event should eventually become a transaction.

Example:

```text
Client payment       +₹500,000
Steel purchase       -₹120,000
Labour               -₹35,000
Transport             -₹12,000
```

Then calculate:

```text
Total inflow
Total outflow
Current balance
Outstanding
```

Financial records must be auditable.

Avoid destructive deletion of financial history.

---

# 23. Project Profitability

Eventually:

```text
Contract Value
Expected Cost
Actual Cost
Remaining Expected Cost
Forecast Final Cost
Expected Profit
Profit Margin
```

The system should detect cost overruns.

Example:

```text
Planned labour: ₹500,000
Current trend:  ₹620,000

Warning:
Labour cost is trending above plan.
```

---

# 24. Design Management

Future:

* Architects
* Structural engineers
* Electrical engineers
* Plumbing engineers
* Drawings
* Drawing versions
* Revisions
* Approval status
* Current approved revision

Example:

```text
Structural Drawing

Revision 01
Revision 02
Revision 03 ← Approved
```

---

# 25. BOQ

Future major module.

Example:

```text
Item             Quantity     Unit

Cement           500          Bags
Steel            12,000       Kg
Brick            30,000       Nos
Sand             100          m³
```

BOQ should connect:

```text
Design
 ↓
BOQ
 ↓
Material Requirements
 ↓
Procurement
 ↓
Consumption
 ↓
Cost
```

---

# 26. Client Management

Future:

```text
Client
 ├── Contact details
 ├── Projects
 ├── Contract
 ├── Payments
 ├── Outstanding
 ├── Documents
 ├── Communication
 └── History
```

---

# 27. Communication

Future integrations:

## WhatsApp

Use official WhatsApp Business/API ecosystem.

Possible future flow:

```text
Supplier message
      ↓
"Steel will arrive tomorrow"
      ↓
Potential delivery update
      ↓
User confirmation
      ↓
System update
```

Do not automatically create important financial/operational records from messages without appropriate confirmation.

---

# 28. Phone CRM

Eventually record:

```text
Contact
Call date
Call duration
Outcome
Notes
Follow-up
```

Contacts may include:

* Client
* Supplier
* Worker
* Engineer
* Architect

---

# 29. Documents

Future project document center:

```text
Project
 ├── Agreement
 ├── Architectural drawings
 ├── Structural drawings
 ├── BOQ
 ├── Purchase Orders
 ├── Bills
 ├── Receipts
 ├── Inspection reports
 └── Completion documents
```

Need versioning and access control eventually.

---

# 30. Notifications & Reminders

Future examples:

```text
Inspection tomorrow
Supplier payment due
Worker attendance missing
Material below requirement
Task deadline approaching
Client payment overdue
PO delivery delayed
```

---

# 31. Dashboard & Analytics

Main dashboard should eventually answer:

```text
MONEY
WORK
MATERIALS
LABOUR
PROBLEMS
```

Project health could eventually look like:

```text
Project Health: 82%

Schedule       GREEN
Materials      GREEN
Labour         YELLOW
Cost           GREEN
Quality        GREEN
Procurement    RED
```

The system should explain why a project has a poor health score.

---

# 32. AI — Future Only

Do not build AI before the underlying data model is reliable.

Future AI capabilities:

### Procurement assistant

Recommend suppliers based on:

* price
* quality
* delivery time
* reliability
* payment terms

### Cost forecasting

Predict final project cost.

### Schedule forecasting

Predict delays.

### Labour optimization

Recommend worker allocation.

### Risk detection

Detect unusual:

* cost increases
* material consumption
* delays
* labour inefficiency
* supplier problems

### Document extraction

Extract structured data from:

* invoices
* quotations
* bills
* drawings metadata
* reports

### Project AI assistant

Eventually allow queries like:

> "Why is this project delayed?"

> "How much have we spent on foundation?"

> "Which supplier is costing us the most?"

> "What materials do we need next week?"

---

# 33. Long-Term Development Sequence

Preferred implementation order:

```text
1. Tasks & Execution
2. Quality Management
3. Logistics / Material Delivery
4. Inventory / Material Consumption
5. Supplier Bills & Payments
6. Project Finance / Ledger
7. Project Profitability
8. Design Management
9. BOQ
10. Client Management
11. Documents
12. Reminders / Notifications
13. Communication
14. Backend / Authentication / RBAC
15. Offline Database + Sync
16. Advanced Analytics
17. Integrations
18. AI
```

Do not skip foundational dependencies just to build advanced features.

---

# 34. Current Development Philosophy

This project is being developed incrementally.

For each feature:

```text
Entity
 ↓
Repository contract
 ↓
Mock repository
 ↓
Provider
 ↓
UI
 ↓
CRUD
 ↓
Validation
 ↓
Business rules
 ↓
Integration with other modules
 ↓
Tests
```

Prefer small, verifiable checkpoints.

After meaningful changes:

```powershell
flutter analyze
flutter test
```

Then manually test the relevant UI.

Commit working milestones frequently.

---

# 35. Git Commit Philosophy

Use meaningful commits.

Examples:

```text
feat: add project task management
feat: add task editing
feat: add task archiving
feat: add daily site reports
feat: add purchase order management
fix: validate material procurement allocations
```

Do not make giant unrelated commits.

---

# 36. UI Principles

The UI should be:

* professional
* clean
* construction-business oriented
* readable on mobile
* easy for site engineers
* minimal data-entry friction
* visually consistent

Avoid overcomplicated UI.

Prefer:

* clear cards
* meaningful icons
* concise labels
* useful empty states
* loading states
* error states
* confirmation dialogs for destructive/archive operations

Forms should be practical for field users.

---

# 37. Data Integrity Rules

Never silently:

* lose data
* overwrite unrelated records
* create duplicate financial records
* create duplicate PO conversions
* accept invalid quantities
* accept invalid date ranges
* associate records with nonexistent projects/phases
* invent financial rules

Use validation at the appropriate domain/UI boundaries.

---

# 38. Important Current State

The current project has a functioning foundation for:

```text
Projects
Phases
Timeline
Contacts
Quotations
Purchase Quotations
Purchase Orders
Materials
Material Requirements
Procurement Allocation
Suppliers
Workers
Attendance
Labour Cost
Daily Site Reports
Tasks
```

The current active development area is:

```text
TASKS → EXECUTION MANAGEMENT
```

The immediate next feature should be **Task Details / Execution Tracking**, followed by worker assignment and execution history.

---

# 39. Critical Rule for Copilot

Before changing code:

1. Inspect the existing architecture.
2. Reuse existing entities/providers/repositories where appropriate.
3. Do not duplicate functionality.
4. Do not create hardcoded project/phase data.
5. Do not introduce unnecessary dependencies.
6. Preserve repository abstraction.
7. Keep business logic out of presentation when it belongs in domain/application logic.
8. Follow existing naming conventions.
9. Run `flutter analyze` after meaningful changes.
10. Run `flutter test`.
11. Make incremental changes.
12. Do not refactor unrelated files while implementing a feature.

When uncertain about an existing implementation, inspect the relevant file before modifying it.

The goal is to build a **production-scalable Construction Operations OS**, not a collection of disconnected demo screens.
