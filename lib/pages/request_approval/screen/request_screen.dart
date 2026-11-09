import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/request_approval/screen/my_request_widget.dart';
import 'package:fl_mhis_hr/pages/request_approval/screen/my_approval_widget.dart';
import 'package:fl_mhis_hr/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didUpdateWidget(RequestScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tabController ??= TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const TimeoffScreen2()));
        },
        backgroundColor: AppColors.danger,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const FaIcon(
          FontAwesomeIcons.plus,
          size: 18,
          color: AppColors.whiteshade,
        ),
        label: const Text(
          "Request",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.whiteshade,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.paddingOf(context).top + 220,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: Common.homeHeaderGradient),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Timeoff Request',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'View your requests and approvals',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.1),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController!,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.danger,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tabs: const [
                      Tab(text: "My requests"),
                      Tab(text: "My Approvals"),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController!,
                    children: const [
                      MyRequestWidget(),
                      MyApprovalWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
