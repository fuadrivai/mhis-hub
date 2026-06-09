import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/attendance/repository/attendance_api.dart';
import 'package:fl_mhis_hr/pages/pages.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';
import 'package:permission_handler/permission_handler.dart';

class ClockinClockoutScreen extends StatefulWidget {
  final String type;
  const ClockinClockoutScreen({super.key, required this.type});

  @override
  State<ClockinClockoutScreen> createState() => _ClockinClockoutScreenState();
}

class _ClockinClockoutScreenState extends State<ClockinClockoutScreen>
    with WidgetsBindingObserver {
  CameraController? cameraController;
  bool isLoading = true;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  bool positionStreamStarted = false;
  bool _hasCameraPermission = false;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    isLoading = true;
    _geolocatorPlatform.getServiceStatusStream();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndStartCamera();
    super.initState();
  }

  Future<void> _checkPermissionAndStartCamera() async {
    setState(() {
      isLoading = true;
    });

    if (!Platform.isWindows) {
      _hasCameraPermission = await Common.requestCameraPermission();
      if (_hasCameraPermission) {
        _cameras = await availableCameras();
        await startCamera();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      _hasCameraPermission = true;
      _cameras = await availableCameras();
      await startCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed) {
      _checkPermissionAndStartCamera();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: LoadingWidget(),
      );
    }
    if (_hasCameraPermission &&
        cameraController != null &&
        cameraController!.value.isInitialized) {
      final scale = 0.9 /
          ((cameraController?.value.aspectRatio ?? 0) *
              MediaQuery.of(context).size.aspectRatio);

      return Scaffold(
        appBar: CustomAppbar(
          backgroundColor: AppColors.whiteshade,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          title: widget.type.toUpperCase(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          isExtended: true,
          onPressed: _takePictureV2,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 5),
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: CameraPreview(
            cameraController!,
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: CustomAppbar(
          backgroundColor: AppColors.whiteshade,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          title: widget.type.toUpperCase(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Camera Access Required",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "To check in or check out, the app needs access to your camera. Please tap the button below to open Settings, then allow Camera access for this app.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  onPressed: () {
                    openAppSettings();
                  },
                  child: const Text(
                    "Open Settings",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> startCamera() async {
    if (_cameras.isNotEmpty) {
      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first, // Fallback to any camera
      );
      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.max,
        enableAudio: false,
      );

      await cameraController?.initialize();
      isLoading = false;
      if (mounted) setState(() {});
    } else {
      isLoading = false;
      if (mounted) setState(() {});
    }
  }

  void _stopCamera() {
    if (cameraController != null) {
      cameraController?.dispose();
    }
  }

  Future<void> _takePictureV2() async {
    try {
      if (cameraController == null || !cameraController!.value.isInitialized) {
        return;
      }

      isLoading = true;
      if (mounted) setState(() {});

      final filePicture = await cameraController!.takePicture();
      final file = File(filePicture.path);

      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      Position position = await Common.determinePosition();
      String? userId = await Session.get("userId");

      if (userId == null) throw Exception("User belum login");

      LiveAttendance liveAttendance = LiveAttendance()
        ..latitude = position.latitude
        ..longitude = position.longitude
        ..type = widget.type
        ..userId = int.parse(userId)
        ..date = Jiffy.now().format(pattern: "yyyy-MM-dd HH:mm:ss")
        ..photo = base64Image;

      AttendanceLog data = await AttendanceApi.postAttendance(liveAttendance);
      if (!mounted) return;
      // context.goNamed('attendance-response', extra: {'data': data});
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return AttendanceResponseScreen(attendance: data);
        }),
      );
    } catch (e) {
      if (!mounted) return;
      isLoading = false;
      setState(() {});
      String message = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        message = err.response?.data?['message'] ?? "Server Error";
      }
      Common.modalInfo(
        context,
        title: "Error",
        message: message,
      );
    } finally {
      isLoading = false;
      if (mounted) setState(() {});
    }
  }
}
