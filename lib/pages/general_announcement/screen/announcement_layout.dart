import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:flutter/material.dart';

class AnnouncementLayout extends StatelessWidget {
  const AnnouncementLayout({
    super.key,
    required this.subtitle,
    required this.child,
  });

  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ThemedPage(
      title: 'Announcement',
      subtitle: subtitle,
      child: child,
    );
  }
}
