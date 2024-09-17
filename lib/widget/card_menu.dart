import 'package:fl_mhis_hr/library/constant.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TileList extends StatelessWidget {
  final GestureTapCallback? onTap;
  final IconData? iconData;
  final String title;

  const TileList({super.key, this.onTap, this.iconData, required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.0),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Center(
                child: FaIcon(
                  iconData,
                  size: 32,
                  color: AppColors.primary2,
                ),
              ),
            ),
            Expanded(
                child: Text(
              title,
              style: const TextStyle(fontSize: 15),
            )),
            const SizedBox(
              width: 40,
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color.fromARGB(255, 101, 101, 101),
                size: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextTitle extends StatelessWidget {
  final String title;
  const TextTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 10,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.dismissibleBackground,
            fontWeight: FontWeight.w600,
            fontSize: 21,
          ),
        ),
      ),
    );
  }
}
