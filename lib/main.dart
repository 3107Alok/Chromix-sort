import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'data/storage/hive_storage.dart';
import 'presentation/providers/storage_provider.dart';
import 'presentation/providers/stats_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Lock screen orientation to Portrait Mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 2. Initialize local storage (Hive)
  final storage = HiveStorage();
  await storage.init();

  // 3. Create the Riverpod container
  final container = ProviderContainer(
    overrides: [
      storageProvider.overrideWithValue(storage),
    ],
  );

  // 4. Start background play time tracker (ticks every 5 seconds)
  Timer.periodic(const Duration(seconds: 5), (timer) {
    container.read(statsProvider.notifier).addPlayTime(5);
  });

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BottleSortApp(),
    ),
  );
}

class BottleSortApp extends StatelessWidget {
  const BottleSortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chromix',
      theme: GameTheme.darkTheme,
      darkTheme: GameTheme.darkTheme,
      themeMode: ThemeMode.dark, // Always dark space mode
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
