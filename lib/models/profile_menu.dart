import 'package:fl_mhis_hr/models/model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class ParentMenu {
  String? parent;
  List<ChildMenu>? child;

  ParentMenu({
    this.parent,
    this.child,
  });

  List<ParentMenu> menu(BuildContext context, Employee employee) => [
        ParentMenu(
          parent: "My Info",
          child: [
            ChildMenu(
              name: "Personal Info",
              iconData: FontAwesomeIcons.person,
              onTap: () {
                context
                    .goNamed("personal-info", extra: {"data": employee.person});
              },
            ),
            ChildMenu(
              name: "Employment Info",
              iconData: FontAwesomeIcons.idCard,
              onTap: () {
                context.goNamed("employment-info",
                    extra: {"data": employee.employment});
              },
            ),
            // ChildMenu(
            //   name: "Emergency Contact Info",
            //   iconData: FontAwesomeIcons.flag,
            //   onTap: () {},
            // ),
            // ChildMenu(
            //   name: "Family Info",
            //   iconData: FontAwesomeIcons.peopleGroup,
            //   onTap: () {},
            // ),
            // ChildMenu(
            //   name: "Education and Experience",
            //   iconData: FontAwesomeIcons.solidBuilding,
            //   onTap: () {},
            // ),
            // ChildMenu(
            //   name: "Payroll Info",
            //   iconData: FontAwesomeIcons.sackDollar,
            //   onTap: () {},
            // ),
            // ChildMenu(
            //   name: "My files",
            //   iconData: FontAwesomeIcons.folderOpen,
            //   onTap: () {},
            // ),
            // ChildMenu(
            //   name: "Reprimand",
            //   iconData: FontAwesomeIcons.triangleExclamation,
            //   onTap: () {},
            // ),
          ],
        ),
        ParentMenu(
          parent: "Settings",
          child: [
            ChildMenu(
              name: "Change Password",
              iconData: FontAwesomeIcons.lock,
              onTap: () => context.goNamed("change-password"),
            ),
            ChildMenu(
              name: "Login With Biometric",
              defaultTrailing: false,
              iconData: FontAwesomeIcons.fingerprint,
              onTap: () {},
            ),
            // ChildMenu(
            //   name: "PIN",
            //   iconData: FontAwesomeIcons.key,
            //   onTap: () {},
            // ),
            // ChildMenu(
            //   name: "Enable Authentication",
            //   iconData: FontAwesomeIcons.fingerprint,
            //   onTap: () {},
            // ),
            // ChildMenu(
            //   name: "Reminder Clock in/out",
            //   iconData: FontAwesomeIcons.clock,
            //   onTap: () {},
            // ),
            // ChildMenu(
            //   name: "Language",
            //   iconData: FontAwesomeIcons.comment,
            //   onTap: () {},
            // ),
          ],
        ),
      ];
}

class ChildMenu {
  String? name;
  GestureTapCallback? onTap;
  IconData? iconData;
  bool? defaultTrailing;

  ChildMenu(
      {this.iconData, this.name, this.onTap, this.defaultTrailing = true});
}
