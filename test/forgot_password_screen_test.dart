import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/pages/login/screen/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('validates email before sending', (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
      home: ForgotPasswordScreen(sendRequest: (_) async => calls++),
    ));

    await tester.tap(find.text('Send Request'));
    await tester.pump();
    expect(find.text('Please enter your email.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'invalid');
    await tester.tap(find.text('Send Request'));
    await tester.pump();
    expect(find.text('Please enter a valid email address.'), findsOneWidget);
    expect(calls, 0);
  });

  testWidgets('sends trimmed email once and displays success', (tester) async {
    final request = Completer<void>();
    final emails = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: ForgotPasswordScreen(sendRequest: (email) {
        emails.add(email);
        return request.future;
      }),
    ));

    await tester.enterText(find.byType(TextFormField), ' user@example.com ');
    await tester.tap(find.text('Send Request'));
    await tester.pump();
    expect(emails, ['user@example.com']);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    request.complete();
    await tester.pumpAndSettle();
    expect(find.text('Back to Login'), findsOneWidget);
  });

  testWidgets('displays server error and allows retry', (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
      home: ForgotPasswordScreen(sendRequest: (_) async {
        calls++;
        if (calls == 1) {
          final options = RequestOptions(path: '/password/forgot');
          throw DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 422,
              data: {'message': 'Invalid email'},
            ),
          );
        }
      }),
    ));

    await tester.enterText(find.byType(TextFormField), 'user@example.com');
    await tester.tap(find.text('Send Request'));
    await tester.pumpAndSettle();
    expect(find.text('Invalid email'), findsOneWidget);
    await tester.tap(find.text('Send Request'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Back to Login'), findsOneWidget);
  });
}
