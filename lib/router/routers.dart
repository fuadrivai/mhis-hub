import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
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
            routes: [
              GoRoute(
                parentNavigatorKey: _nav.navKey,
                path: 'announcement',
                name: "announcement",
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: NewsletterScreen(),
                  );
                },
              ),
              GoRoute(
                parentNavigatorKey: _nav.navKey,
                path: 'general-announcement',
                name: "general-announcement",
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: GeneralAnnouncementScreen(),
                  );
                },
                routes: [
                  GoRoute(
                    parentNavigatorKey: _nav.navKey,
                    path: 'form',
                    name: "general-announcement-form",
                    pageBuilder: (context, state) {
                      return const NoTransitionPage(
                        child: GeneralAnnouncementForm(),
                      );
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: _nav.navKey,
                    path: 'view',
                    name: "general-announcement-view",
                    pageBuilder: (context, state) {
                      var extra = state.extra as Map<String, dynamic>;
                      return NoTransitionPage(
                        child: GeneralAnnouncementView(
                          announcement: extra['announcement'],
                        ),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                parentNavigatorKey: _nav.navKey,
                path: 'payment-slip',
                name: "paymentsllip",
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: PaymentslipScreen(),
                  );
                },
              ),
              GoRoute(
                parentNavigatorKey: _nav.navKey,
                path: 'kpi',
                name: "kpi",
                pageBuilder: (context, state) {
                  return NoTransitionPage(
                    child: KpiScreen(),
                  );
                },
              ),
              GoRoute(
                parentNavigatorKey: _nav.navKey,
                path: 'live-ashar',
                name: "live-ashar",
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: ClockInAsharScreen(),
                  );
                },
                routes: [
                  GoRoute(
                    parentNavigatorKey: _nav.navKey,
                    path: 'tap-in',
                    name: "tap-in-ashar",
                    pageBuilder: (context, state) {
                      return const NoTransitionPage(
                        child: PrayMapScreen(),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                parentNavigatorKey: _nav.navKey,
                path: 'attendance-history',
                name: "attendance-history",
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: AttendanceHistoryScreen(),
                  );
                },
              ),
              GoRoute(
                parentNavigatorKey: _nav.navKey,
                path: 'location/clockin',
                name: "location-clockin",
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: MapScreen(
                      type: "checkin",
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    parentNavigatorKey: _nav.navKey,
                    path: 'attendance',
                    name: "clockin",
                    pageBuilder: (context, state) {
                      return const NoTransitionPage(
                        child: ClockinClockoutScreen(
                          type: "checkin",
                        ),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                parentNavigatorKey: _nav.navKey,
                path: 'location/clockout',
                name: "location-clockout",
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: MapScreen(
                      type: "checkout",
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    parentNavigatorKey: _nav.navKey,
                    path: 'attendance',
                    name: "clockout",
                    pageBuilder: (context, state) {
                      return const NoTransitionPage(
                        child: ClockinClockoutScreen(
                          type: "checkout",
                        ),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                parentNavigatorKey: _nav.navKey,
                path: 'attendance-response',
                name: "attendance-response",
                pageBuilder: (context, state) {
                  var extra = state.extra as Map<String, dynamic>;
                  return NoTransitionPage(
                    child: AttendanceResponseScreen(
                      data: extra['data'],
                    ),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            parentNavigatorKey: _dashboardNavigatorKey,
            path: '/profile',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: ProfileScreen(),
              );
            },
            routes: [
              GoRoute(
                parentNavigatorKey: _nav.navKey,
                path: 'setting',
                name: "setting",
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: SettingScreen(),
                  );
                },
              ),
              GoRoute(
                parentNavigatorKey: _nav.navKey,
                path: 'password/change',
                name: "change-password",
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: ChangePasswordScreen(),
                  );
                },
              ),
              GoRoute(
                parentNavigatorKey: _nav.navKey,
                path: 'personal/info',
                name: "personal-info",
                pageBuilder: (context, state) {
                  var extra = state.extra as Map<String, dynamic>;
                  Person person = extra['data'];
                  return NoTransitionPage(
                    child: PersonalInfo(
                      listForm: person.listForm(),
                      title: "Personal Info",
                    ),
                  );
                },
              ),
              GoRoute(
                parentNavigatorKey: _nav.navKey,
                path: 'employment/info',
                name: "employment-info",
                pageBuilder: (context, state) {
                  var extra = state.extra as Map<String, dynamic>;
                  Employment employment = extra['data'];
                  return NoTransitionPage(
                    child: PersonalInfo(
                      listForm: employment.listForm(),
                      title: "Employment Info",
                    ),
                  );
                },
              ),
            ],
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
            path: '/attendance',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: AttendanceScreen(),
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
          GoRoute(
            parentNavigatorKey: _dashboardNavigatorKey,
            path: '/employee',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: EmployeeScreen(),
              );
            },
          ),
        ],
      ),
    ],
  );
}
