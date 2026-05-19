import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GridMenuItem {
  const GridMenuItem({
    required this.title,
    required this.icon,
    required this.routeCandidates,
    required this.seed,
  });

  final String title;
  final FaIconData icon;
  final List<String> routeCandidates;
  final int seed;
}
