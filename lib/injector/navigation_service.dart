import 'package:material_ui/material_ui.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName) {
    return navKey.currentState!
        .pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  Future<dynamic> pushNamedWithArguments(String routeName) {
    return navKey.currentState!.pushNamed(routeName);
  }
}
