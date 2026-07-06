import 'dart:convert';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:another_flushbar/flushbar.dart';

class Common {
  Common._();
  static String logoHub = 'assets/images/logo-hub.png';
  static String logoSplash = 'assets/images/splash.png';
  static String imageLogo = 'assets/images/logo.png';
  static String imageProfile = 'assets/images/profile.png';
  static String talentaLogo = 'assets/images/talenta.png';
  static String hmacUsername = 'VSkLSBDZBI7LnyPX';
  static String hmacSecret = '9hntyY9mqhQLHG9G5KZVkPPk9DKqagqU';

  static Gradient gradient = const LinearGradient(
    colors: [AppColors.primary, AppColors.primary2],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.3, 0.9],
  );
  static Gradient redGradient = const LinearGradient(
    colors: [AppColors.danger, Color.fromARGB(255, 247, 63, 109)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.3, 0.9],
  );
  static Gradient shimmerGradient = const LinearGradient(
    colors: [
      Color.fromARGB(255, 234, 234, 234),
      Color.fromARGB(255, 202, 202, 202)
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.3, 0.9],
  );

  static Color seededColor(
    int seed, {
    double saturation = 0.62,
    double lightness = 0.56,
  }) {
    final hue = (seed * 37) % 360;
    return HSLColor.fromAHSL(1, hue.toDouble(), saturation, lightness)
        .toColor();
  }

  static void modalInfo(
    BuildContext context, {
    String? message,
    required String title,
    Widget? icon,
    MODE? mode,
    bool? showAction,
    GestureTapCallback? onTap,
  }) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 30.0,
                  bottom: 5,
                  left: 8,
                  right: 8,
                ),
                child: Column(
                  children: <Widget>[
                    icon ??
                        FaIcon(
                          mode == MODE.success
                              ? FontAwesomeIcons.circleCheck
                              : FontAwesomeIcons.triangleExclamation,
                          color:
                              mode == MODE.success ? Colors.green : Colors.red,
                          size: 50,
                        ),
                    const SizedBox(height: 10),
                    Text(title, style: const TextStyle(fontSize: 25)),
                    const SizedBox(height: 10),
                    Text(
                      message ?? "Message",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: mode == MODE.success ? Colors.green : Colors.red,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).maybePop(),
                      child: const Text("Dismiss"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Color statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'approved':
        return AppColors.primary;
      case 'rejected':
      case 'reject':
        return AppColors.danger;
      case 'skipped':
        return AppColors.grey;
      case 'pending':
      default:
        return AppColors.amber;
    }
  }

  static MonthPickerDialogSettings monthPickerDialog() {
    return MonthPickerDialogSettings(
      headerSettings: const PickerHeaderSettings(
        headerBackgroundColor: AppColors.primary,
        headerCurrentPageTextStyle: TextStyle(
          fontSize: 25,
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
        headerSelectedIntervalTextStyle: TextStyle(
          fontSize: 16,
          color: AppColors.white,
        ),
      ),
      dateButtonsSettings: PickerDateButtonsSettings(
        selectedMonthBackgroundColor: AppColors.danger.withValues(
          red: 0.3,
          blue: 0.3,
          green: 0.3,
          colorSpace: ColorSpace.displayP3,
        ),
      ),
      dialogSettings: PickerDialogSettings(
        locale: const Locale('en'),
        dialogRoundedCornersRadius: 20,
        dialogBackgroundColor: AppColors.whiteshade,
      ),
    );
  }

  static Future flushBar(BuildContext context,
      {required String title,
      required String message,
      FlushbarPosition? position}) async {
    Flushbar(
      flushbarPosition: position ?? FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      title: title,
      message: message,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: AppColors.primary,
      duration: const Duration(seconds: 1),
      icon: const Icon(Icons.notification_add, color: AppColors.white),
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          color: AppColors.white,
          fontFamily: "ShadowsIntoLightTwo",
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          fontSize: 18.0,
          fontFamily: "ShadowsIntoLightTwo",
          color: AppColors.white,
        ),
      ),
      // ignore: use_build_context_synchronously
    ).show(context);
  }

  static String dateToUTC() {
    final now = DateTime.now().toUtc();
    return DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'').format(now);
    // Your implementation here to generate the date string in the required format
  }

  static String generateHmacSignature(
      String requestLine, String dateString, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode('date: $dateString\n$requestLine');
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return base64Encode(digest.bytes);
  }

  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status == PermissionStatus.granted) {
      return true;
    } else if (status == PermissionStatus.limited) {
      return true;
    } else if (status == PermissionStatus.permanentlyDenied) {
      return false;
    } else if (status == PermissionStatus.restricted) {
      return true;
    } else {
      return false;
    }
  }

  static Future<Position> determinePosition({BuildContext? context}) async {
    LocationPermission permission;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context != null) {
        if (!context.mounted) {
          return Future.error('Location services are disabled');
        }
        await _showLocationSettingsDialog(
          context,
          title: 'Turn on location',
          message:
              'Location service is turned off. Enable location services in settings to continue.',
        );
      }
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context != null) {
          if (!context.mounted) {
            return Future.error('Location permissions are denied');
          }
          await _showLocationSettingsDialog(
            context,
            title: 'Location permission required',
            message:
                'This feature needs location access. Open settings and allow location permission to continue.',
          );
        }
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (context != null) {
        if (!context.mounted) {
          return Future.error('Location permissions are denied forever');
        }
        await _showLocationSettingsDialog(
          context,
          title: 'Location permission required',
          message:
              'Location permission is permanently denied. Open settings and allow location permission to continue.',
        );
      }
      return Future.error('Location permissions are denied forever');
    }
    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(),
      // ignore: deprecated_member_use
      forceAndroidLocationManager: true,
    );
  }

  static Future<void> _showLocationSettingsDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await Geolocator.openLocationSettings();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  static String capitalizeFirst(String word) {
    if (word.isEmpty) {
      return word; // Return empty string if input is empty
    }
    return word[0].toUpperCase() + word.substring(1);
  }

  static String capitalizeEvery(String word) {
    String data = "";
    if (word.isEmpty) {
      data = word;
      return data;
    }
    List<String> words = word.split(" ");
    List<String> newWord = [];
    for (var i = 0; i < words.length; i++) {
      String str = words[i];
      str = str[0].toUpperCase() + str.substring(1);
      newWord.add(str);
    }
    return data = newWord.join(" ");
  }
}

enum MODE { success, error }
