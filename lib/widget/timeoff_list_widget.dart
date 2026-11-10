import 'dart:math';

import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TimeoffListWidget extends StatefulWidget {
  final List<Timeoff> timeoffs;
  const TimeoffListWidget({super.key, required this.timeoffs});

  @override
  State<TimeoffListWidget> createState() => _TimeoffListWidgetState();
}

class _TimeoffListWidgetState extends State<TimeoffListWidget> {
  static const _icons = [
    Icons.calendar_today_outlined,
    Icons.event_available_outlined,
    Icons.beach_access_outlined,
    Icons.flight_takeoff_outlined,
    Icons.local_hospital_outlined,
    Icons.home_work_outlined,
    Icons.spa_outlined,
    Icons.work_outline,
    Icons.celebration_outlined,
  ];

  final _random = Random();
  late List<IconData> _itemIcons;

  @override
  void initState() {
    super.initState();
    _randomizeIcons();
  }

  @override
  void didUpdateWidget(covariant TimeoffListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.timeoffs, widget.timeoffs)) {
      _randomizeIcons();
    }
  }

  void _randomizeIcons() {
    _itemIcons = List.generate(
      widget.timeoffs.length,
      (_) => _icons[_random.nextInt(_icons.length)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverList.builder(
        itemCount: widget.timeoffs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTimeoffCard(
              context,
              widget.timeoffs[index],
              _itemIcons[index],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeoffCard(BuildContext context, Timeoff item, IconData icon) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.danger.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.pushNamed("create-timeoff", extra: {
            "data": item,
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.danger,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          item.code ?? '-',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        _buildStatusBadge(item.isActive == true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    final background = isActive
        ? AppColors.primary.withValues(alpha: 0.15)
        : AppColors.danger.withValues(alpha: 0.12);
    final foreground = isActive ? AppColors.primary : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
