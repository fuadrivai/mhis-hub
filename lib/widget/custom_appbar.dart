import 'package:fl_mhis_hr/library/constant.dart';
import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget implements PreferredSize {
  const CustomAppbar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.subTitle,
    this.gradient,
  });
  final String title;
  final Widget? actions;
  final Widget? leading;
  final Widget? subTitle;
  final Color? backgroundColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    double topBarOpacity = 0.0;
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ??
              AppColors.whiteshade.withOpacity(topBarOpacity),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.grey.withOpacity(0.4 * topBarOpacity),
              offset: const Offset(1.1, 1.1),
              blurRadius: 10.0,
            ),
          ],
          gradient: gradient,
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 5,
                top: 16 - 8.0 * topBarOpacity,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  leading ?? const SizedBox.shrink(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: AppColors.fontName,
                              fontWeight: FontWeight.w700,
                              fontSize: 15 + 6 - 6 * topBarOpacity,
                              color: AppColors.dismissibleBackground,
                            ),
                          ),
                          subTitle ?? const SizedBox.shrink()
                        ],
                      ),
                    ),
                  ),
                  actions ?? const SizedBox.shrink()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget get child => throw UnimplementedError();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
