import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/firebase_options.dart';
import 'config/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_loading.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/onboarding_profile_screen.dart';
import 'features/dashboard/screens/main_navigation_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  runApp(
    const ProviderScope(
      child: GoTogetherApp(),
    ),
  );
}

class GoTogetherApp extends ConsumerWidget {
  const GoTogetherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeSettingsProvider);

    return MaterialApp(
      title: 'GoTogether',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(isSeniorMode: themeState.isSeniorAccessibleMode),
      darkTheme: AppTheme.darkTheme(isSeniorMode: themeState.isSeniorAccessibleMode),
      themeMode: themeState.themeMode,
      routes: AppRoutes.routes,
      home: const AuthGate(),
    );
  }
}

/// Dynamic authentication gate that automatically directs user to:
/// 1. LoginScreen if unauthenticated
/// 2. OnboardingProfileScreen if authenticated but profile is not completed
/// 3. MainNavigationScreen if authenticated with complete profile
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateChangesProvider);

    return authStateAsync.when(
      data: (authUser) {
        if (authUser == null) {
          return const LoginScreen();
        }

        final userProfileAsync = ref.watch(currentUserProfileProvider);

        return userProfileAsync.when(
          data: (userProfile) {
            if (userProfile == null) {
              return const OnboardingProfileScreen();
            }
            return const MainNavigationScreen();
          },
          loading: () => const Scaffold(
            body: AppLoading(message: 'Verifying traveler profile...'),
          ),
          error: (error, _) => Scaffold(
            body: Center(
              child: Text('Profile error: $error'),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: AppLoading(message: 'Loading GoTogether...'),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('Authentication error: $error'),
        ),
      ),
    );
  }
}
