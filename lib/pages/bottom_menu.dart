import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class BottomMenu extends StatefulWidget {
  final Widget child;
  const BottomMenu({super.key, required this.child});

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  int _currentIndex = 0;
  Color bgColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        backgroundColor: bgColor,
        iconPadding: 10,
        buttonBackgroundColor: const Color.fromARGB(255, 235, 235, 235),
        onTap: (i) {
          _currentIndex = i;
          callPage(_currentIndex);
          setState(() {});
        },
        items: [
          CurvedNavigationBarItem(
            child: FaIcon(
              FontAwesomeIcons.house,
              color: bgColor,
            ),
            label: 'Home',
          ),
          CurvedNavigationBarItem(
            child: FaIcon(
              FontAwesomeIcons.peopleGroup,
              color: bgColor,
            ),
            label: 'Contacts',
          ),
          CurvedNavigationBarItem(
            child: FaIcon(
              FontAwesomeIcons.clockRotateLeft,
              color: bgColor,
            ),
            label: 'Timeoff',
          ),
          CurvedNavigationBarItem(
            child: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Common.imageLogo),
                  scale: 2,
                ),
              ),
            ),
            label: 'Academy',
          ),
          CurvedNavigationBarItem(
            child: FaIcon(
              FontAwesomeIcons.user,
              color: bgColor,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void callPage(int index) {
    switch (index) {
      case 0:
        context.go("/");
      case 1:
        context.go("/employee");
      case 2:
        context.go("/timeoff");
      case 3:
        context.go("/academy");
      case 4:
        context.go("/profile");
      default:
        context.go("/");
    }
  }
}
