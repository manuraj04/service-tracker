import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'services/firebase_service.dart';

import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'db/app_database.dart';
import 'services/theme_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and local services
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseService.instance.initialize();
    print('Firebase initialized successfully!');
  } catch (e) {
    print('Firebase initialization failed - app will continue in offline mode: $e');
  }

  // Initialize local DB and seed demo banks
  await AppDatabase.instance.seedSampleBanks();

  runApp(const ProviderScope(child: ServiceEngineerTrackerApp()));
}

class ServiceEngineerTrackerApp extends ConsumerWidget {
  const ServiceEngineerTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Service Engineer Tracker',
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: const _Root(),
    );
  }
}

class _Root extends ConsumerStatefulWidget {
  const _Root();

  @override
  ConsumerState<_Root> createState() => _RootState();
}

class _RootState extends ConsumerState<_Root> {
  late Future<bool> _firstTime;

  @override
  void initState() {
    super.initState();
    _firstTime = AuthService.isFirstTime();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _firstTime,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final isFirst = snapshot.data ?? true;
        if (isFirst) {
          return WelcomeScreen(onComplete: () {
            // once welcome completes it will navigate to home itself
          });
        }

        return const HomeScreen();
      },
    );
  }
}
