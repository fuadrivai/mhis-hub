import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/employee/bloc/employee_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'dart:io';

class EmployeeWidget extends StatefulWidget {
  const EmployeeWidget({super.key});

  @override
  State<EmployeeWidget> createState() => _EmployeeWidgetState();
}

class _EmployeeWidgetState extends State<EmployeeWidget> {
  final ScrollController _controller = ScrollController();
  String _search = '';

  @override
  void initState() {
    context.read<EmployeeBloc>().add(const OnInitV2());
    _controller.addListener(() {
      if (_controller.position.maxScrollExtent == _controller.offset) {
        context.read<EmployeeBloc>().add(const OnLoadMore());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<EmployeeBloc>().add(const OnInitV2());
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50.withValues(alpha: 0.45)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: TextFormField(
                  validator: ValidForm.emptyValue,
                  decoration: TextFormDecoration.box(
                    hintText: 'Search by Employee Email...',
                  ),
                  onChanged: (str) {
                    setState(() {
                      _search = str.trim().toLowerCase();
                    });
                  },
                ),
              ),
              BlocBuilder<EmployeeBloc, EmployeeState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const LoadingWidget();
                  }

                  final List<Employee> source = state.employees2 ?? [];
                  final List<Employee> employees = _search.isEmpty
                      ? source
                      : source
                          .where(
                            (employee) =>
                                (employee.personal?.email ?? '')
                                    .toLowerCase()
                                    .contains(_search) ||
                                (employee.user?.email ?? '')
                                    .toLowerCase()
                                    .contains(_search) ||
                                (employee.personal?.fullname ?? '')
                                    .toLowerCase()
                                    .contains(_search),
                          )
                          .toList();

                  if (employees.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Text('No Data'),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final Employee employee = employees[index];
                      final String avatar = employee.personal?.avatar ?? '';
                      final String fullname =
                          employee.personal?.fullname ?? '-';
                      final String email = employee.personal?.email ??
                          employee.user?.email ??
                          '-';
                      final String mobilePhone =
                          employee.personal?.mobilePhone ?? '-';
                      final String organization =
                          employee.employment?.organization?.name ??
                              employee.employment?.organizationName ??
                              '-';
                      final String position =
                          employee.employment?.jobPosition?.name ??
                              employee.employment?.jobPositionName ??
                              '-';
                      final String level =
                          employee.employment?.jobLevel?.name ??
                              employee.employment?.jobLevelName ??
                              '-';
                      final String branch = employee.employment?.branch?.name ??
                          employee.employment?.branchName ??
                          '-';

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.blueGrey.shade100,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      if (avatar.isEmpty) return;
                                      await showDialog(
                                        context: context,
                                        builder: (_) => ImageDialog(
                                          imageUrl: avatar,
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 24,
                                      backgroundImage: avatar.isEmpty
                                          ? null
                                          : NetworkImage(avatar),
                                      child: avatar.isEmpty
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fullname,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          email,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          mobilePhone,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final badges = Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      _infoBadge('Branch', branch),
                                      _infoBadge('Level', level),
                                      _infoBadge('Organization', organization),
                                      _infoBadge('Position', position),
                                    ],
                                  );

                                  final bool hasPhone = mobilePhone != '-' &&
                                      mobilePhone.isNotEmpty;
                                  final actions = Row(
                                    children: [
                                      Expanded(
                                        child: _actionButton(
                                          icon: FontAwesomeIcons.phoneFlip,
                                          label: 'Phone',
                                          color: AppColors.danger,
                                          onTap: hasPhone
                                              ? () => phoneDial(mobilePhone)
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _actionButton(
                                          icon: FontAwesomeIcons.envelope,
                                          label: 'Email',
                                          color: AppColors.blue,
                                          onTap: () => launchEmail(email),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _actionButton(
                                          icon: FontAwesomeIcons.whatsapp,
                                          label: 'WhatsApp',
                                          color: Colors.green,
                                          onTap: hasPhone
                                              ? () => whatsapp(mobilePhone)
                                              : null,
                                        ),
                                      ),
                                    ],
                                  );

                                  if (constraints.maxWidth < 420) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        badges,
                                        const SizedBox(height: 10),
                                        actions,
                                      ],
                                    );
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      badges,
                                      const SizedBox(height: 10),
                                      actions,
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      constraints: const BoxConstraints(maxWidth: 220),
      child: Text(
        '$label: $value',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.blueGrey.shade700,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _actionButton({
    required FaIconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(36),
        side: BorderSide(
          color: onTap == null
              ? Colors.grey.shade300
              : color.withValues(alpha: 0.5),
        ),
        foregroundColor: onTap == null ? Colors.grey.shade400 : color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      icon: FaIcon(icon, size: 14),
      label: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Future<void> launchEmail(String email) async {
    if (email == '-' || email.isEmpty) {
      return;
    }
    final String url = 'mailto:$email';
    await launchUrl(Uri.parse(url));
  }

  Future<void> phoneDial(String contact) async {
    final Uri url = Uri(scheme: 'tel', path: contact);
    await launchUrl(url);
  }

  Future<void> whatsapp(String contact) async {
    final String te = contact.substring(0, 1);
    String newContact = contact;
    if (te == '0') {
      newContact = replaceFirstCharacter(contact, '62');
    }
    final String androidUrl = 'whatsapp://send?phone=$newContact';
    final String iosUrl = 'https://wa.me/$newContact';

    try {
      if (Platform.isIOS) {
        await launchUrl(Uri.parse(iosUrl));
      } else {
        await launchUrl(Uri.parse(androidUrl));
      }
    } on Exception {
      debugPrint('whatsapp not installed');
    }
  }

  String replaceFirstCharacter(String str, String replacement) {
    if (str.isEmpty) {
      return str;
    }
    return replacement + str.substring(1);
  }
}
