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

List<CameraDescription> listCamera = [];
bool cameraPermission = false;
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // ignore: avoid_print
  print(
      "Message received in background: ${message.notification?.title}, ${message.notification?.body}");
}

Future<void> initializeFirebaseMessaging() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(alert: true, badge: true, sound: true);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  if (Platform.isIOS) {
    String? apnsToken;
    for (int attempt = 0; attempt < 10; attempt++) {
      apnsToken = await messaging.getAPNSToken();
      if (apnsToken != null) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (apnsToken == null) {
      debugPrint(
          'APNs token is not available yet. Skipping Firebase topic subscription for now.');
      return;
    }
  }

  try {
    await messaging.subscribeToTopic('all');
  } catch (e) {
    debugPrint('Failed to subscribe to topic "all": $e');
  }
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await _initializeCamera();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (Platform.isAndroid || Platform.isIOS) {
    await initializeFirebaseMessaging();
  }

  setPathUrlStrategy();
  setupLocator();
  runApp(const MyApp());
}

Future<void> _initializeCamera() async {
  if (!(Platform.isAndroid || Platform.isIOS)) {
    return;
  }

  cameraPermission = await Common.requestCameraPermission();
  if (!cameraPermission) {
    listCamera = [];
    debugPrint('Camera permission not granted.');
    return;
  }

  try {
    listCamera = await availableCameras();
    if (listCamera.isEmpty) {
      debugPrint('No camera available on this device.');
    }
  } on CameraException catch (e) {
    listCamera = [];
    cameraPermission = false;
    debugPrint('Failed to load camera list: ${e.code} - ${e.description}');
  }
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
