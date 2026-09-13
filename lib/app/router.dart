import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/projects/presentation/pages/project_details_page.dart';
import '../features/projects/presentation/pages/projects_page.dart';
import '../features/projects/presentation/pages/project_timeline_page.dart';
import '../features/projects/presentation/pages/project_contacts_page.dart';

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
  ],
);