import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/main.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/attendance/repositoty/attendance_api.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void initState() {
    isLoading = true;
    _geolocatorPlatform.getServiceStatusStream();
    WidgetsBinding.instance.addObserver(this);
    startCamera();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (cameraController == null || cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        cameraController != null &&
        cameraController!.value.isInitialized) {
      startCamera();
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
    if (cameraController != null) {
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
          onPressed: _takePicture,
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
        body: cameraPermission
            ? Transform.scale(
                scale: scale,
                alignment: Alignment.topCenter,
                child: CameraPreview(
                  cameraController!,
                ),
              )
            : const Text("Camera Tidak Tersedia"),
      );
    } else {
      return const Center(
        child: Text("No Camera Available"),
      );
    }
  }

  startCamera() async {
    if (listCamera.isNotEmpty) {
      final frontCamera = listCamera.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => listCamera.first, // Fallback to any camera
      );
      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.max,
        enableAudio: false,
      );

      await cameraController?.initialize();
      isLoading = false;
      setState(() {});
    }
  }

  _stopCamera() {
    if (cameraController != null) {
      cameraController?.dispose();
    }
  }

  _takePicture() async {
    if (cameraController == null) return;
    isLoading = true;
    setState(() {});
    final filePicture = await cameraController!.takePicture();
    final file = File(filePicture.path);
    Position position = await Common.determinePosition();
    String? userId = await Session.get("userIdTalenta");
    LiveAttendance liveAttendance = LiveAttendance();
    liveAttendance.description = "${widget.type} description selfie";
    liveAttendance.latitude = position.latitude;
    liveAttendance.longitude = position.longitude;
    liveAttendance.status = widget.type;
    liveAttendance.userId = int.parse(userId!);
    liveAttendance.file =
        await MultipartFile.fromFile(file.path, filename: "$userId.jpg");
    List<String> filePathList = [];
    filePathList.add(file.path.toString());
    var formData =
        FormData.fromMap(liveAttendance.toJson(), ListFormat.multiCompatible);
    AttendanceApi.postLiveAttendance(formData).then((data) {
      if (!mounted) return;
      isLoading = false;
      setState(() {});
      context.goNamed('attendance-response', extra: {'data': data});
    }).catchError((e) {
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
    });
  }
}
