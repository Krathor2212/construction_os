import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/pages/dashboard_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
  ],
);
