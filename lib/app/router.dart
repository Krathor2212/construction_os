import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/projects/presentation/pages/project_details_page.dart';
import '../features/projects/presentation/pages/projects_page.dart';
import '../features/projects/presentation/pages/project_timeline_page.dart';
import '../features/projects/presentation/pages/project_contacts_page.dart';
import '../features/projects/presentation/pages/project_quotations_page.dart';
import '../features/workforce/presentation/pages/workers_page.dart';
import '../features/materials/presentation/pages/materials_page.dart';
import '../features/procurement/presentation/pages/suppliers_page.dart';
import '../features/procurement/presentation/pages/purchase_quotations_page.dart';
import '../features/procurement/presentation/pages/purchase_quotation_details_page.dart';
import '../features/procurement/presentation/pages/purchase_orders_page.dart';
import '../features/procurement/presentation/pages/purchase_order_details_page.dart';
import '../features/materials/presentation/pages/material_requirements_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardPage(),
    ),

    GoRoute(
      path: '/projects',
      builder: (context, state) => const ProjectsPage(),
    ),

    GoRoute(
      path: '/projects/:projectId',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;

        return ProjectDetailsPage(
          projectId: projectId,
        );
      },
    ),

    GoRoute(
      path: '/projects/:projectId/timeline',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;

        return ProjectTimelinePage(
          projectId: projectId,
        );
      },
    ),

    GoRoute(
      path: '/projects/:projectId/contacts',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;

        return ProjectContactsPage(
          projectId: projectId,
        );
      },
    ),

    GoRoute(
      path: '/projects/:projectId/quotations',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;

        return ProjectQuotationsPage(
          projectId: projectId,
        );
      },
    ),

    GoRoute(
      path: '/workers',
      builder: (context, state) => const WorkersPage(),
    ),

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

        return PurchaseQuotationsPage(
          projectId: projectId,
        );
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

        return PurchaseOrdersPage(
          projectId: projectId,
        );
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
        return MaterialRequirementsPage(
          projectId: projectId,
        );
      },
    ),
  ],
);
