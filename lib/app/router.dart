import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/projects/presentation/pages/project_details_page.dart';
import '../features/projects/presentation/pages/projects_page.dart';
import '../features/projects/presentation/pages/project_timeline_page.dart';
import '../features/projects/presentation/pages/project_contacts_page.dart';
import '../features/projects/presentation/pages/project_quotations_page.dart';
import '../features/site_reports/presentation/pages/daily_site_reports_page.dart';
import '../features/workforce/presentation/pages/workers_page.dart';
import '../features/materials/presentation/pages/materials_page.dart';
import '../features/procurement/presentation/pages/suppliers_page.dart';
import '../features/procurement/presentation/pages/purchase_quotations_page.dart';
import '../features/procurement/presentation/pages/purchase_quotation_details_page.dart';
import '../features/procurement/presentation/pages/purchase_orders_page.dart';
import '../features/procurement/presentation/pages/purchase_order_details_page.dart';
import '../features/materials/presentation/pages/material_requirements_page.dart';
import '../features/materials/presentation/pages/project_material_deliveries_page.dart';
import '../features/materials/presentation/pages/project_material_inventory_page.dart';
import '../features/materials/presentation/pages/project_material_forecast_page.dart';
import '../features/finance/presentation/pages/project_finance_pages.dart';
import '../features/workforce/presentation/pages/worker_attendance_page.dart';
import '../features/workforce/presentation/pages/worker_allocation_page.dart';
import '../features/tasks/presentation/pages/project_tasks_page.dart';
import '../features/tasks/presentation/pages/project_task_details_page.dart';
import '../features/quality/presentation/pages/project_inspections_page.dart';
import '../features/quality/presentation/pages/project_defects_page.dart';
import '../features/quality/presentation/pages/project_punch_list_page.dart';
import '../features/quality/presentation/pages/project_corrective_actions_page.dart';
import '../features/quality/presentation/pages/project_reinspections_page.dart';
import '../features/quality/presentation/pages/project_quality_history_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
    GoRoute(
      path: '/projects',
      builder: (context, state) => const ProjectsPage(),
    ),
    GoRoute(
      path: '/projects/:projectId',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return ProjectDetailsPage(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/projects/:projectId/timeline',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return ProjectTimelinePage(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/projects/:projectId/contacts',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return ProjectContactsPage(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/projects/:projectId/quotations',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return ProjectQuotationsPage(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/projects/:projectId/daily-site-reports',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return DailySiteReportsPage(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/projects/:projectId/inspections',
      builder: (context, state) =>
          ProjectInspectionsPage(projectId: state.pathParameters['projectId']!),
    ),
    GoRoute(
      path: '/projects/:projectId/defects',
      builder: (context, state) =>
          ProjectDefectsPage(projectId: state.pathParameters['projectId']!),
    ),
    GoRoute(
      path: '/projects/:projectId/punch-list',
      builder: (context, state) =>
          ProjectPunchListPage(projectId: state.pathParameters['projectId']!),
    ),
    GoRoute(
      path: '/projects/:projectId/corrective-actions',
      builder: (context, state) => ProjectCorrectiveActionsPage(
        projectId: state.pathParameters['projectId']!,
      ),
    ),
    GoRoute(
      path: '/projects/:projectId/reinspections',
      builder: (context, state) => ProjectReinspectionsPage(
        projectId: state.pathParameters['projectId']!,
      ),
    ),
    GoRoute(
      path: '/projects/:projectId/quality-history',
      builder: (context, state) => ProjectQualityHistoryPage(
        projectId: state.pathParameters['projectId']!,
      ),
    ),
    GoRoute(path: '/workers', builder: (context, state) => const WorkersPage()),
    GoRoute(
      path: '/materials',
      builder: (context, state) => const MaterialsPage(),
    ),
    GoRoute(
      path: '/suppliers',
      builder: (context, state) => const SuppliersPage(),
    ),
    GoRoute(
      path: '/projects/:projectId/purchase-quotations',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return PurchaseQuotationsPage(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/projects/:projectId/purchase-quotations/:quotationId',
      builder: (context, state) {
        return PurchaseQuotationDetailsPage(
          projectId: state.pathParameters['projectId']!,
          quotationId: state.pathParameters['quotationId']!,
        );
      },
    ),
    GoRoute(
      path: '/projects/:projectId/purchase-orders',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return PurchaseOrdersPage(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/projects/:projectId/purchase-orders/:orderId',
      builder: (context, state) {
        return PurchaseOrderDetailsPage(
          projectId: state.pathParameters['projectId']!,
          orderId: state.pathParameters['orderId']!,
        );
      },
    ),
    GoRoute(
      path: '/projects/:projectId/material-requirements',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return MaterialRequirementsPage(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/projects/:projectId/material-deliveries',
      builder: (context, state) => ProjectMaterialDeliveriesPage(
        projectId: state.pathParameters['projectId']!,
      ),
    ),
    GoRoute(
      path: '/projects/:projectId/material-inventory',
      builder: (context, state) => ProjectMaterialInventoryPage(
        projectId: state.pathParameters['projectId']!,
      ),
    ),
    GoRoute(
      path: '/projects/:projectId/material-forecast',
      builder: (context, state) => ProjectMaterialForecastPage(
        projectId: state.pathParameters['projectId']!,
      ),
    ),
    GoRoute(
      path: '/projects/:projectId/supplier-bills',
      builder: (context, state) => ProjectSupplierBillsPage(
        projectId: state.pathParameters['projectId']!,
      ),
    ),
    GoRoute(
      path: '/projects/:projectId/supplier-payments',
      builder: (context, state) => ProjectSupplierPaymentsPage(
        projectId: state.pathParameters['projectId']!,
      ),
    ),
    GoRoute(
      path: '/projects/:projectId/client-invoices',
      builder: (context, state) => ProjectClientInvoicesPage(
        projectId: state.pathParameters['projectId']!,
      ),
    ),
    GoRoute(
      path: '/workers/:workerId/attendance',
      builder: (context, state) {
        final workerId = state.pathParameters['workerId']!;
        final workerName = state.uri.queryParameters['workerName'] ?? 'Worker';

        return WorkerAttendancePage(workerId: workerId, workerName: workerName);
      },
    ),
    GoRoute(
      path: '/workers/:workerId/allocations',
      builder: (context, state) {
        final workerId = state.pathParameters['workerId']!;
        final workerName = state.uri.queryParameters['workerName'] ?? 'Worker';

        return WorkerAllocationPage(workerId: workerId, workerName: workerName);
      },
    ),
    GoRoute(
      path: '/projects/:projectId/tasks/:taskId',
      builder: (context, state) {
        return ProjectTaskDetailsPage(
          projectId: state.pathParameters['projectId']!,
          taskId: state.pathParameters['taskId']!,
        );
      },
    ),
    GoRoute(
      path: '/projects/:projectId/tasks',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;

        return ProjectTasksPage(projectId: projectId);
      },
    ),
  ],
);
