import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final GestureTapCallback? onTap;
  const EmptyWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Image.asset(
            "assets/images/no-data-found.png",
            scale: 2,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 100,
          child: AuthButton(
            onTap: onTap,
            text: "Refresh",
            color: AppColors.blue,
            height: 40,
          ),
        ),
      ],
    );
  }
}
