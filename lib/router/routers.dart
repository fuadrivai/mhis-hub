import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/bottom_menu.dart';
import 'package:fl_mhis_hr/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final NavigationService _nav = locator<NavigationService>();
final GlobalKey<NavigatorState> _dashboardNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'dashboard');

class RouteNavigation {
  static final GoRouter router = GoRouter(
    navigatorKey: _nav.navKey,
    redirect: (context, state) async {
      String? token = await Session.get("token");
      if (token == null || token == "") {
        return '/auth';
      } else {
        return null;
      }
    },
    initialLocation: '/',
    routes: [
      GoRoute(
        parentNavigatorKey: _nav.navKey,
        path: '/auth',
        pageBuilder: (context, state) {
          return const NoTransitionPage(
            child: LoginScreen(),
          );
        },
      ),
      ShellRoute(
        restorationScopeId: "",
        navigatorKey: _dashboardNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return BottomMenu(child: child);
        },
        routes: [
          GoRoute(
            parentNavigatorKey: _dashboardNavigatorKey,
            path: '/',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: HomeScreen(),
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: _dashboardNavigatorKey,
            path: '/profile',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: ProfileScreen(),
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: _dashboardNavigatorKey,
            path: '/academy',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: AcademyScreen(),
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: _dashboardNavigatorKey,
            path: '/talenta',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: TalentaScreen(),
              );
            },
          ),
        ],
      ),
    ],
  );
}
