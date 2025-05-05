import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class InformationHomeWidget extends StatelessWidget {
  const InformationHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: AppColors.white,
        child: Column(
          children: [
            const TextTitle(title: "Information"),
            const Divider(),
            const VerticalMenu(),
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
    return Wrap(
      children: [
        GestureDetector(
          onTap: () => context.goNamed('live-ashar'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.mosque),
              Text("Sholat"),
            ],
          ),
        ),
      ],
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
    required IconData iconData,
    GestureTapCallback? onTap,
  }) {
    return ListTile(
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
    );
  }
}
