import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local persistence
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('marketplace');
  
  // Seed initial data check
  final prefs = await SharedPreferences.getInstance();
  final hasSeeded = prefs.getBool('has_seeded_batchlive_data') ?? false;
  if (!hasSeeded) {
    // Only seed once
    await prefs.setBool('has_seeded_batchlive_data', true);
    // Real persistence of the data models into Hive/Prefs would happen here.
    // For this prototype, Riverpod Notifiers will load from MockData.
  }
  
  runApp(
    const ProviderScope(
      child: BatchLiveApp(),
    ),
  );
}

class BatchLiveApp extends StatelessWidget {
  const BatchLiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BatchLive',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
