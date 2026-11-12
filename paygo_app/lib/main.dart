/// EventTreasury AI — Main App Entry Point
/// Powered by PayPal (PayPal AI Hackathon Edition)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const ProviderScope(child: EventTreasuryApp()));
}

class EventTreasuryApp extends ConsumerWidget {
  const EventTreasuryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'EventTreasury AI — Powered by PayPal',
      debugShowCheckedModeBanner: false,
      theme: EventTreasuryTheme.lightTheme,
      darkTheme: EventTreasuryTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRoutes.router,
    );
  }
}

// Backward compatibility alias
typedef PayGoApp = EventTreasuryApp;
