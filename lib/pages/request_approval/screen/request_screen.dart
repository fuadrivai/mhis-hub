import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/request_approval/screen/my_request_widget.dart';
import 'package:fl_mhis_hr/pages/request_approval/screen/my_approval_widget.dart';
import 'package:fl_mhis_hr/pages/pages.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
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
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: "Timeoff Request",
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const TimeoffScreen2()));
        },
        backgroundColor: AppColors.secondary,
        elevation: 8,
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
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(color: AppColors.whiteshade),
            child: TabBar(
              controller: _tabController!,
              labelColor: AppColors.secondary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.secondary,
              tabs: const [
                Tab(text: "My requests"),
                Tab(text: "My Approvals"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController!,
              children: [
                const MyRequestWidget(),
                const MyApprovalWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
