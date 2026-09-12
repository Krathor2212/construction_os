import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';

class SuGoRaApp extends ConsumerWidget {
  const SuGoRaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'SuGoRa Construction OS',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
