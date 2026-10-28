# Architecture Diagram

SuGoRa Construction OS is currently a Flutter mobile application for
construction project operations. The implemented system is a frontend and
domain prototype backed by realistic in-memory repositories; the diagrams also
show the planned offline-first and backend architecture that will replace those
repositories without requiring a rewrite of the UI.

## Application Architecture

<!-- mermaid-checked: no \n, no em-dash/en-dash, no {} in labels, subgraphs are id["label"], arrows are -->|"label"|, all subgraphs closed by end, ids unique -->
~~~mermaid
flowchart TD
    subgraph Client["Client Application"]
        Flutter["Flutter Android application"]
        Router["GoRouter navigation"]
        Riverpod["Riverpod state and DI"]
    end
    subgraph Features["Feature Modules"]
        Projects["Projects and phases"]
        Procurement["Procurement and suppliers"]
        Materials["Materials and inventory"]
        Workforce["Workforce and labour"]
        Execution["Tasks and site reports"]
        Quality["Inspections and quality"]
        Finance["Bills and invoices"]
    end
    subgraph Domain["Domain Layer"]
        Entities["Entities and value models"]
        Rules["Calculators and use cases"]
        Contracts["Repository contracts"]
    end
    subgraph CurrentData["Current Data Layer"]
        Mocks["Mock in-memory repositories"]
    end
    subgraph FutureLocal["Planned Offline Layer"]
        LocalDb[("Local database")]
        Sync["Synchronization engine"]
    end
    subgraph FutureBackend["Planned Backend"]
        ApiClient["Remote API client"]
        FastApi["FastAPI services"]
        Postgres[("PostgreSQL")]
        Cache[("Redis cache")]
        Storage[("Object storage")]
    end
    subgraph FuturePlatform["Planned Platform Services"]
        Auth["Authentication and RBAC"]
        Audit["Audit logging"]
        Backup["Backup and recovery"]
        Deploy["Production deployment"]
    end

    Flutter --> Router
    Router --> Riverpod
    Riverpod --> Features
    Features --> Entities
    Features --> Rules
    Rules --> Contracts
    Contracts --> Mocks
    Contracts -.->|"future local implementation"| LocalDb
    Contracts -.->|"future remote implementation"| ApiClient
    LocalDb -.->|"offline changes"| Sync
    Sync -.->|"queued synchronization"| ApiClient
    ApiClient -.->|"HTTPS API"| FastApi
    FastApi -.->|"transactional data"| Postgres
    FastApi -.->|"cache and jobs"| Cache
    FastApi -.->|"documents and media"| Storage
    FastApi -.->|"identity enforcement"| Auth
    FastApi -.->|"immutable activity records"| Audit
    Postgres -.->|"protected backups"| Backup
    FastApi -.->|"hosted services"| Deploy
~~~

### Technology Stack Summary

| Layer | Technology | Version | Purpose |
| --- | --- | --- | --- |
| Client | Flutter | 3.47.4 currently installed | Cross-platform application UI |
| Language | Dart | 3.13.3 | Application and domain implementation |
| State and DI | Riverpod | 3.4.3 | Providers, dependency injection, queries, and mutations |
| Navigation | GoRouter | 18.0.1 | Route-based project and feature navigation |
| HTTP foundation | Dio | 5.11.1 | Reserved API client foundation for backend integration |
| Secure storage foundation | flutter_secure_storage | 11.1.1 | Reserved secure token and credential storage |
| Domain design | Dart entities and services | Current | Business rules, calculations, and validation |
| Data access today | Mock repositories | Current | Deterministic in-memory development data |
| Android build | Gradle and Android plugin | Project-managed | Release APK packaging |
| Planned local persistence | SQLite-compatible local database | To be selected | Offline construction-site operation |
| Planned synchronization | Custom sync engine | To be designed | Conflict handling and queued writes |
| Planned backend | FastAPI | To be selected | REST API and server-side business boundary |
| Planned database | PostgreSQL | To be selected | Durable multi-user persistence |
| Planned cache and jobs | Redis | To be selected | Caching, queues, and short-lived coordination |
| Planned file storage | Object storage | To be selected | Drawings, photos, documents, and exports |

### Data Storage & External Services

The current application has no production database or external service
dependency. All feature repositories are mock and in-memory, so data resets
when the application process is restarted. The intended production design adds
a local database for offline use, a synchronization engine for queued changes,
and a FastAPI backend backed by PostgreSQL. Redis is reserved for caching and
background coordination, while object storage will hold drawings, site
photos, documents, and generated exports. Authentication, audit logging,
backup, and deployment are platform concerns to be introduced after the
frontend and domain roadmap is substantially complete.

### Key Architectural Decisions

- Uses a feature-first Flutter structure with separate presentation, domain,
  repository-contract, and data-implementation responsibilities.
- Uses Riverpod as the single state-management and dependency-injection
  mechanism; pages do not own persistence or backend logic.
- Keeps mock repositories behind stable contracts so local and remote
  implementations can be introduced later without rewriting feature screens.
- Uses stable project, phase, task, worker, material, bill, and invoice IDs to
  preserve cross-feature traceability.
- Treats offline-first support as a future architectural direction rather than
  adding premature persistence or synchronization code to the prototype.

## Component Relationships

<!-- mermaid-checked: no \n, no em-dash/en-dash, no {} in labels, subgraphs are id["label"], arrows are -->|"label"|, all subgraphs closed by end, ids unique -->
~~~mermaid
flowchart LR
    subgraph cPresentation["Presentation"]
        cPages["Feature pages"]
        cDialogs["Forms and dialogs"]
        cRouter["GoRouter"]
        cProviders["Riverpod providers"]
    end
    subgraph cBusiness["Business Logic"]
        cProjectDomain["Project domain"]
        cMaterialDomain["Material domain"]
        cProcurementDomain["Procurement domain"]
        cWorkDomain["Workforce domain"]
        cExecutionDomain["Execution domain"]
        cQualityDomain["Quality domain"]
        cFinanceDomain["Finance domain"]
        cCalculators["Calculators and use cases"]
    end
    subgraph cData["Data Access"]
        cProjectRepos["Project repositories"]
        cMaterialRepos["Material repositories"]
        cProcurementRepos["Procurement repositories"]
        cWorkRepos["Workforce repositories"]
        cExecutionRepos["Execution repositories"]
        cQualityRepos["Quality repositories"]
        cFinanceRepos["Finance repositories"]
        cMocks["Mock repository implementations"]
    end
    subgraph cInfrastructure["Infrastructure Boundary"]
        cContracts["Repository interfaces"]
        cFutureLocal["Future local database"]
        cFutureRemote["Future API implementation"]
    end

    cRouter -->|"opens screens"| cPages
    cPages -->|"reads and writes state"| cProviders
    cDialogs -->|"submits validated input"| cProviders
    cProviders -->|"queries and mutations"| cProjectDomain
    cProviders -->|"queries and mutations"| cMaterialDomain
    cProviders -->|"queries and mutations"| cProcurementDomain
    cProviders -->|"queries and mutations"| cWorkDomain
    cProviders -->|"queries and mutations"| cExecutionDomain
    cProviders -->|"queries and mutations"| cQualityDomain
    cProviders -->|"queries and mutations"| cFinanceDomain
    cMaterialDomain -->|"uses calculations"| cCalculators
    cWorkDomain -->|"uses calculations"| cCalculators
    cExecutionDomain -->|"uses calculations"| cCalculators
    cFinanceDomain -->|"uses balance rules"| cCalculators
    cProjectDomain -->|"uses contracts"| cContracts
    cMaterialDomain -->|"uses contracts"| cContracts
    cProcurementDomain -->|"uses contracts"| cContracts
    cWorkDomain -->|"uses contracts"| cContracts
    cExecutionDomain -->|"uses contracts"| cContracts
    cQualityDomain -->|"uses contracts"| cContracts
    cFinanceDomain -->|"uses contracts"| cContracts
    cContracts -->|"current implementation"| cMocks
    cMocks --> cProjectRepos
    cMocks --> cMaterialRepos
    cMocks --> cProcurementRepos
    cMocks --> cWorkRepos
    cMocks --> cExecutionRepos
    cMocks --> cQualityRepos
    cMocks --> cFinanceRepos
    cContracts -.->|"future replacement"| cFutureLocal
    cContracts -.->|"future replacement"| cFutureRemote
~~~

### Component Inventory

| Component | Layer | Type | Responsibility |
| --- | --- | --- | --- |
| Feature pages | Presentation | Flutter widgets | Display project-scoped data and user actions |
| Forms and dialogs | Presentation | Flutter widgets | Collect and validate create, edit, and status-change input |
| GoRouter | Presentation | Navigation | Maps dashboard, project, task, material, quality, and finance routes |
| Riverpod providers | Presentation | State and DI | Exposes repository queries, mutations, loading, error, and refresh state |
| Project domain | Business Logic | Entities and repositories | Projects, phases, contacts, quotations, and timelines |
| Material domain | Business Logic | Entities, services, repositories | Catalogue, requirements, delivery, receipts, inventory, consumption, wastage, and forecasts |
| Procurement domain | Business Logic | Entities, use cases, repositories | Suppliers, purchase quotations, purchase orders, line items, and conversion |
| Workforce domain | Business Logic | Entities, services, repositories | Workers, attendance, allocation, and labour cost calculations |
| Execution domain | Business Logic | Entities, services, repositories | Tasks, assignments, progress history, execution updates, and daily reports |
| Quality domain | Business Logic | Entities, services, repositories | Inspections, defects, punch lists, corrective actions, reinspections, and history |
| Finance domain | Business Logic | Entities and repositories | Supplier bills, supplier payments, client invoices, milestones, and balances |
| Calculators and use cases | Business Logic | Domain services | Procurement validation, stock balances, material forecasts, labour cost, and execution variance |
| Repository interfaces | Infrastructure boundary | Contracts | Stable data-access boundary shared by UI and future implementations |
| Mock repositories | Data access | In-memory implementations | Development data, filtering, ordering, create, and update behavior |
| Feature repository groups | Data access | Repository implementations | Project, material, procurement, workforce, execution, quality, and finance records |
| Future local database | Infrastructure boundary | Planned persistence | Durable offline reads and writes on construction sites |
| Future API implementation | Infrastructure boundary | Planned remote data source | Authenticated synchronization with FastAPI services |

## Implemented System Scope

The implemented application currently covers the operational core:

- Project and phase management
- Project contacts, quotations, timelines, and navigation
- Material catalogue and phase-linked material requirements
- Supplier management, purchase quotations, purchase orders, and conversion
- Material deliveries, receipts, inventory, consumption, wastage, and forecasting
- Workers, attendance, allocation, and labour costing
- Daily site reports linked to tasks
- Task details, execution updates, worker assignment, and progress history
- Planned-versus-actual execution and schedule variance
- Inspections, defects, punch lists, corrective actions, reinspections, and
  unified quality history
- Supplier bills, supplier payments, and client milestone invoices
- Android release packaging through Flutter and Gradle

## Planned System Scope

The planned product expands the current operational core in the following
sequence:

1. **Finance completion:** client payments, expenses, ledger, cash flow,
   project profitability, and cost variance.
2. **Planning and design:** BOQ, design management, drawing revisions,
   engineers and designers, and planned-versus-actual quantities.
3. **Business operations:** client CRM, supplier performance, documents,
   reminders, notifications, communication, WhatsApp planning, and phone CRM.
4. **Production platform:** authentication, RBAC, PostgreSQL, local offline
   database, synchronization, audit logs, cloud storage, backups, and
   production deployment.
5. **Intelligence:** analytics, cost and schedule forecasting, procurement
   recommendations, labour optimization, risk detection, document extraction,
   an AI project assistant, and project health scoring.

## Target End-to-End Data Flow

```text
Project setup
  -> phases and requirements
  -> procurement and purchase orders
  -> delivery and material receipt
  -> inventory, consumption, and wastage
  -> workforce attendance and task execution
  -> daily reports and progress history
  -> inspections, defects, and corrective actions
  -> supplier bills and client milestone invoices
  -> payments, expenses, ledger, and profitability
  -> completion, reporting, and project health
```

The most important future traceability path is:

```text
Material requirement
  -> purchase quotation
  -> purchase order
  -> delivery
  -> receipt
  -> inventory
  -> task consumption
  -> execution progress
  -> labour and material cost
  -> project profitability
```

## Current Architectural Boundary

The app is not yet a multi-user production system. It currently has no real
API calls, backend services, PostgreSQL database, authentication, RBAC,
offline database, synchronization engine, audit log service, or production
deployment infrastructure. Those components are intentionally planned behind
the repository contracts and should be introduced only after their related
frontend and domain workflows are complete and validated.
