import 'package:fl_mhis_hr/library/app_colors.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:material_ui/material_ui.dart';

class VisitorEmployeeCard extends StatelessWidget {
  const VisitorEmployeeCard({
    super.key,
    required this.employee,
    required this.onTap,
    this.selectionMode = false,
    this.selected = false,
  });

  final VisitorHost employee;
  final VoidCallback onTap;
  final bool selectionMode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final details = <(String, String)>[
      ('Branch', employee.branch ?? '-'),
      ('Level', employee.level ?? '-'),
      ('Organization', employee.organization ?? '-'),
      ('Position', employee.position ?? '-'),
    ];
    final avatar = employee.avatar;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AppColors.danger.withValues(alpha: 0.45)
                  : AppColors.danger.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: avatar != null && avatar.isNotEmpty
                        ? NetworkImage(avatar)
                        : null,
                    onBackgroundImageError:
                        avatar == null || avatar.isEmpty ? null : (_, __) {},
                    child: avatar == null || avatar.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        if (employee.email?.isNotEmpty == true)
                          _ContactLine(
                            icon: Icons.email_outlined,
                            value: employee.email!,
                          ),
                        if (employee.phone?.isNotEmpty == true)
                          _ContactLine(
                            icon: Icons.phone_outlined,
                            value: employee.phone!,
                          ),
                      ],
                    ),
                  ),
                  if (selectionMode)
                    Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: selected ? AppColors.danger : Colors.black45,
                    )
                  else
                    const Icon(Icons.chevron_right, color: Colors.black45),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: details
                    .map(
                      (detail) =>
                          _EmployeeBadge(label: detail.$1, value: detail.$2),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade600),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeBadge extends StatelessWidget {
  const _EmployeeBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey.shade800, fontSize: 11),
      ),
    );
  }
}
