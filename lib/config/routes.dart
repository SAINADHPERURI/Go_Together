import 'package:flutter/material.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/onboarding_profile_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/dashboard/screens/main_navigation_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/search/screens/search_trips_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/trips/screens/create_trip_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String onboardingProfile = '/onboarding-profile';
  static const String mainNavigation = '/main';
  static const String createTrip = '/create-trip';
  static const String searchTrips = '/search-trips';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        forgotPassword: (_) => const ForgotPasswordScreen(),
        onboardingProfile: (_) => const OnboardingProfileScreen(),
        mainNavigation: (_) => const MainNavigationScreen(),
        createTrip: (_) => const CreateTripScreen(),
        searchTrips: (_) => const SearchTripsScreen(),
        notifications: (_) => const NotificationsScreen(),
        settings: (_) => const SettingsScreen(),
      };
}
