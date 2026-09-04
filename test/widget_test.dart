import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_together/core/constants/age_group.dart';
import 'package:go_together/core/widgets/app_badge.dart';
import 'package:go_together/core/widgets/app_button.dart';
import 'package:go_together/features/auth/screens/login_screen.dart';

void main() {
  group('GoTogether Widget Tests', () {
    testWidgets('AppButton renders text and triggers callback', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Find Companions',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Find Companions'), findsOneWidget);

      await tester.tap(find.text('Find Companions'));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('AppBadge renders age group pills correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppBadge.ageGroup(AgeGroup.g18_24),
                AppBadge.ageGroup(AgeGroup.g51_plus),
                AppBadge.tripStatus('open'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('18–24 yrs'), findsOneWidget);
      expect(find.text('51+ yrs'), findsOneWidget);
      expect(find.text('OPEN'), findsOneWidget);
    });

    testWidgets('LoginScreen renders brand elements and input fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('GoTogether'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });
  });
}
