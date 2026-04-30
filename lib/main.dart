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
import 'package:url_strategy/url_strategy.dart';

late List<CameraDescription> listCamera;
late bool cameraPermission;
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // ignore: avoid_print
  print(
      "Message received in background: ${message.notification?.title}, ${message.notification?.body}");
}
void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  if (!Platform.isWindows) {
    cameraPermission = await Common.requestCameraPermission();
    listCamera = await availableCameras();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  setPathUrlStrategy();
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
    setupFCM();
    initialization();
    super.initState();
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 2));
    FlutterNativeSplash.remove();
  }

  Future<void> setupFCM() async {
  final messaging = FirebaseMessaging.instance;

  // Request permission
  await messaging.requestPermission();

  // 🔥 Listen for token (THIS is the key fix)
  messaging.onTokenRefresh.listen((token) async {
    print("FCM Token ready: $token");
    await messaging.subscribeToTopic('all');
  });

  // Try initial token
  String? token = await messaging.getToken();

  if (token != null) {
    print("Initial FCM Token: $token");
    await messaging.subscribeToTopic('all');
  } else {
    print("⚠️ Token not ready yet, waiting...");
  }
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
