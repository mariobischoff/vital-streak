import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/presentation/profile_screen.dart';
import 'features/readings/presentation/camera_scanner_screen.dart';
import 'features/readings/presentation/dashboard_screen.dart';
import 'features/readings/presentation/manual_entry_screen.dart';
import 'core/design_system/app_theme.dart';
import 'package:pressao_arterial_historico/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: MyApp()));
}

// RouterProvider to allow router to read auth state
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isGoingToAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      final isGoingToSplash = state.matchedLocation == '/splash';

      return authState.when(
        data: (session) {
          final isLoggedIn = session != null;
          if (isGoingToSplash) {
            return isLoggedIn ? '/' : '/login';
          }
          if (isLoggedIn && isGoingToAuth) {
            return '/';
          }
          if (!isLoggedIn && !isGoingToAuth && !isGoingToSplash) {
            return '/login';
          }
          return null; // no redirect
        },
        loading: () => '/splash',
        error: (err, stack) => '/login',
      );
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const CameraScannerScreen(),
      ),
      GoRoute(
        path: '/manual',
        builder: (context, state) => const ManualEntryScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Vital Streak',
      theme: AppTheme.light,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

// Removed unused _router
