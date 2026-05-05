import 'package:fl_mhis_hr/library/constant.dart';
import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final double? height;
  final Color? color;
  final GestureTapCallback? onTap;

  const AuthButton({
    super.key,
    required this.onTap,
    required this.text,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: height ?? MediaQuery.of(context).size.height * 0.08,
        margin: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          color: color ?? AppColors.primary,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: KTextStyle.authButtonTextStyle,
          ),
        ),
      ),
    );
  }
}
