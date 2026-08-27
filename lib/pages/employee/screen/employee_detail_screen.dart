import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final Person person = widget.employee.personal ?? Person();
    final Employment employment = widget.employee.employment ?? Employment();
    final String name = _value(person.fullname);

    return Scaffold(
      backgroundColor: AppColors.whiteshade,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Employee Details'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final Widget personal = _InfoSection(
            title: 'Personal information',
            icon: Icons.person_outline_rounded,
            color: AppColors.danger,
            fields: person
                .listForm()
                .map(
                  (field) => {
                    ...field,
                    'value': _personalValue(
                      field['title']?.toString(),
                      field['value']?.toString(),
                    ),
                  },
                )
                .toList(),
          );
          final Widget employmentSection = _InfoSection(
            title: 'Employment information',
            icon: Icons.business_center_outlined,
            color: AppColors.primary,
            fields: employment
                .listForm()
                .map(
                  (field) => {
                    ...field,
                    if (field['title'] == 'Employment Status')
                      'value': employment.employmentStatus,
                  },
                )
                .toList(),
          );

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth < 500 ? 16 : 28,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileHeader(
                      name: name,
                      email: _value(person.email),
                      role: _value(employment.jobPosition?.name),
                      avatar: person.avatarLink,
                    ),
                    const SizedBox(height: 18),
                    _DetailTabs(
                      selectedIndex: _selectedTab,
                      onChanged: (index) => setState(() {
                        _selectedTab = index;
                      }),
                    ),
                    const SizedBox(height: 14),
                    IndexedStack(
                      index: _selectedTab,
                      children: [personal, employmentSection],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _value(String? value) =>
      value == null || value.trim().isEmpty ? '--' : value;

  String _personalValue(String? label, String? value) {
    if (label == 'Birth Date' && value != null && value.trim().isNotEmpty) {
      try {
        return Jiffy.parse(value.trim()).format(pattern: 'dd MMMM yyyy');
      } on Exception {
        return value;
      }
    }
    if (label == 'Gender') {
      return switch (value?.trim()) {
        '1' => 'Male',
        '2' => 'Female',
        _ => _value(value),
      };
    }
    if (label == 'Marital Status') {
      return switch (value?.trim()) {
        '1' => 'Single',
        '2' => 'Married',
        '3' => 'Widow',
        '4' => 'Widower',
        _ => _value(value),
      };
    }
    return _value(value);
  }
}

class _DetailTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _DetailTabs({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xffe1e8f0)),
      ),
      child: Row(
        children: [
          _tab(Icons.person_outline_rounded, 'Personal info', 0),
          _tab(Icons.business_center_outlined, 'Employment', 1),
        ],
      ),
    );
  }

  Widget _tab(IconData icon, String label, int index) {
    final bool selected = selectedIndex == index;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onChanged(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.danger : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: selected ? Colors.white : Colors.blueGrey.shade600,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.blueGrey.shade700,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String avatar;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.role,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: Common.redGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            backgroundImage: avatar.isEmpty ? null : NetworkImage(avatar),
            child: avatar.isEmpty
                ? const Icon(Icons.person, size: 38, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Map<String, dynamic>> fields;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe1e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.dark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...fields.map(
            (field) => _DetailRow(
              label: field['title']?.toString() ?? '--',
              value: field['value']?.toString().trim().isNotEmpty == true
                  ? field['value'].toString()
                  : '--',
              statusType: switch (field['title']?.toString()) {
                'Gender' => _StatusType.gender,
                'Marital Status' => _StatusType.marital,
                _ => null,
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final _StatusType? statusType;

  const _DetailRow({
    required this.label,
    required this.value,
    this.statusType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffedf1f5))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: statusType == null
                  ? Text(
                      value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.dark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : _StatusBadge(type: statusType!, value: value),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StatusType { gender, marital }

class _StatusBadge extends StatelessWidget {
  final _StatusType type;
  final String value;

  const _StatusBadge({required this.type, required this.value});

  @override
  Widget build(BuildContext context) {
    final bool isPlaceholder = value == '--';
    final IconData icon = type == _StatusType.gender
        ? Icons.person_outline_rounded
        : Icons.favorite_outline_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isPlaceholder
            ? Colors.blueGrey.shade50
            : AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: isPlaceholder ? Colors.blueGrey.shade500 : AppColors.danger,
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              color:
                  isPlaceholder ? Colors.blueGrey.shade600 : AppColors.danger,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
