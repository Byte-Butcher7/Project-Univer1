import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'data/db_factory.dart';
import 'providers/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initDatabaseFactory();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const StudyApp(),
    ),
  );
}

class StudyApp extends StatelessWidget {
  const StudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _Root(),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: state.isLoggedIn
          ? const HomeScreen(key: ValueKey('home'))
          : const AuthScreen(key: ValueKey('auth')),
    );
  }
}
