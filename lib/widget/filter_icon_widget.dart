import 'package:flutter/material.dart';
import 'package:fl_mhis_hr/library/constant.dart';

class FilterIconWidget extends StatelessWidget {
  final GestureTapCallback? onTap;
  const FilterIconWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: const Icon(
              Icons.filter_list_rounded,
              color: AppColors.blackshade,
            ),
          ),
        ),
      ),
    );
  }
}
