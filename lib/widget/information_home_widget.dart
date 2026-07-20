import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class InformationHomeWidget extends StatelessWidget {
  const InformationHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: AppColors.white,
        child: Column(
          children: [
            const TextTitle(
              title: "Information",
              textStyle: TextStyle(
                fontSize: 15,
                color: AppColors.dismissibleBackground,
                fontWeight: FontWeight.w500,
              ),
            ),
            const HorizontalMenu(),
          ],
        ),
      ),
    );
  }
}

class HorizontalMenu extends StatelessWidget {
  const HorizontalMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 8.0;
          final width = constraints.maxWidth;
          final itemWidth = (width - (spacing * 3)) / 4;
          final itemHeight = itemWidth * 0.88;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: Menu.front.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: itemWidth / itemHeight,
            ),
            itemBuilder: (context, index) {
              final item = Menu.front[index];
              return GridMenuTile(
                item: item,
                onTap: () => _openMenu(context, item),
              );
            },
          );
        },
      ),
    );
  }

  void _showAllAppsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.58,
          minChildSize: 0.42,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'All Apps',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount =
                              constraints.maxWidth < 360 ? 3 : 4;
                          const spacing = 8.0;

                          return GridView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                            itemCount: Menu.dialog.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: spacing,
                              mainAxisSpacing: spacing,
                              childAspectRatio: 0.92,
                            ),
                            itemBuilder: (context, index) {
                              final item = Menu.dialog[index];
                              return GridMenuTile(
                                item: item,
                                onTap: () {
                                  Navigator.of(sheetContext).pop();
                                  _openMenu(context, item);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openMenu(BuildContext context, GridMenuItem item) {
    if (item.title == 'All Apps') {
      _showAllAppsSheet(context);
      return;
    }

    for (final routeName in item.routeCandidates) {
      try {
        context.goNamed(routeName);
        return;
      } catch (_) {
        // Continue checking next candidate route name.
      }
    }

    if (kDebugMode) {
      debugPrint('Route for "${item.title}" is not registered.');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.title} is coming soon.')),
    );
  }
}

class VerticalMenu extends StatelessWidget {
  const VerticalMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // listTile(
        //   title: "Clock In Sholat",
        //   iconData: FontAwesomeIcons.mosque,
        //   onTap: () => context.goNamed('live-ashar'),
        // ),
        // const Divider(),
        listTile(
          title: "KPI Score",
          iconData: FontAwesomeIcons.book,
          onTap: () => context.goNamed('kpi'),
        ),
        const Divider(),
        listTile(
          title: "General Announcement",
          iconData: FontAwesomeIcons.paperPlane,
          onTap: () => context.goNamed('general-announcement'),
        ),
        const Divider(),
        listTile(
          title: "Newsletter",
          iconData: FontAwesomeIcons.newspaper,
          onTap: () => context.goNamed('announcement'),
        ),
        const Divider(),
        listTile(
          title: "Attendance Log",
          iconData: FontAwesomeIcons.rightToBracket,
          onTap: () => context.goNamed('attendance-history'),
        ),
        const Divider(),
        listTile(
          title: "Payment Slip",
          iconData: FontAwesomeIcons.sackDollar,
          onTap: () => context.goNamed("paymentsllip"),
        ),
      ],
    );
  }

  Widget listTile({
    required String title,
    required FaIconData iconData,
    GestureTapCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text(
          title,
        ),
        leading: FaIcon(
          iconData,
          size: 35,
          color: AppColors.primary2,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Color.fromARGB(255, 101, 101, 101),
          size: 15,
        ),
        onTap: onTap,
      ),
    );
  }
}
