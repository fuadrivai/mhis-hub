// ignore_for_file: avoid_print

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_mhis_hr/bloc_provider.dart';
import 'package:fl_mhis_hr/firebase_options.dart';
import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/router/routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_strategy/url_strategy.dart';

List<CameraDescription> listCamera = <CameraDescription>[];
bool cameraPermission = false;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print(
      'Handling a background message: ${message.notification?.title} ${message.notification?.body}');
}

Future<void> _setupFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  if (Platform.isIOS || Platform.isMacOS) {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Notification permission: '
        '${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    String? apnsToken;

    for (int i = 0; i < 10; i++) {
      apnsToken = await messaging.getAPNSToken();
      print('Checking APNs Token: $apnsToken');
      if (apnsToken != null && apnsToken.isNotEmpty) {
        break;
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (apnsToken == null || apnsToken.isEmpty) {
      print('APNs Token is not available');
      return;
    }
    print('APNs Token: $apnsToken');
  }

  final fcmToken = await messaging.getToken();
  print('FCM Token: $fcmToken');

  try {
    await messaging.subscribeToTopic('all');
    print('Subscribed to topic: all');
  } on FirebaseException catch (e) {
    print('Firebase Messaging Error: '
        '${e.code} - ${e.message}');

    if (e.code != 'apns-token-not-set') {
      rethrow;
    }
  }

  messaging.onTokenRefresh.listen((token) {
    print('FCM Token Refreshed: $token');
  });
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  if (!Platform.isWindows) {
    cameraPermission = await Common.requestCameraPermission();
    listCamera = await availableCameras();
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Background notification
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Setup permission, APNs, FCM token
  await _setupFirebaseMessaging();

  // Foreground notification
  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) {
      print('Foreground notification received');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    },
  );

  // Notification clicked ketika app background
  FirebaseMessaging.onMessageOpenedApp.listen(
    (RemoteMessage message) {
      print('Notification clicked');
      print('Data: ${message.data}');
    },
  );

  // Notification clicked ketika app terminated
  final RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    print('App opened from terminated state');
    print('Data: ${initialMessage.data}');
  }

  setPathUrlStrategy();
  await initializeDateFormatting('en');
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    initialization();
    super.initState();
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 2));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiBlocProvider(
      providers: ProviderBloc.get(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: RouteNavigation.router,
        theme: ThemeData(
          fontFamily: 'Lato',
          scaffoldBackgroundColor: const Color.fromARGB(255, 237, 237, 237),
        ),
      ),
    );
  }
}
