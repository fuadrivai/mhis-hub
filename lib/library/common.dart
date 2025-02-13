import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:another_flushbar/flushbar.dart';

class Common {
  Common._();
  static String imageLogo = 'assets/images/logo.png';
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

  static modalInfo(
    BuildContext context, {
    String? message,
    required String title,
    Widget? icon,
    MODE? mode,
    bool? showAction,
    GestureTapCallback? onTap,
  }) {
    showDialog(
      context: context,
      builder: (__) {
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
                      onPressed: () => Navigator.pop(context),
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

  static Future flushBar(BuildContext context,
      {required String title, required String message}) async {
    await Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      title: title,
      message: message,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: AppColors.primary,
      duration: const Duration(seconds: 10),
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

  static Future<Position> determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Geolocator.openLocationSettings();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Geolocator.openLocationSettings();
    }
    return await Geolocator.getCurrentPosition(
      forceAndroidLocationManager: true,
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
