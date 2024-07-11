import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Common {
  Common._();
  static String imageLogo = 'assets/images/logo.png';
  static String talentaLogo = 'assets/images/talenta.png';

  static modalInfo(BuildContext context,
      {String? message, required String title, Icon? icon, MODE? mode}) {
    showDialog(
      context: context,
      builder: (__) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Divider(height: 2, thickness: 3),
                icon ??
                    FaIcon(
                      mode == MODE.success
                          ? FontAwesomeIcons.circleCheck
                          : FontAwesomeIcons.circleXmark,
                      color: mode == MODE.success ? Colors.green : Colors.red,
                      size: 50,
                    ),
                Text(
                  message ?? "Message",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: mode == MODE.success ? Colors.green : Colors.red,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

enum MODE { success, error }
