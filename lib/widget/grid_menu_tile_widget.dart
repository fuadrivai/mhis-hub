import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GridMenuTile extends StatelessWidget {
  const GridMenuTile({super.key, required this.item, required this.onTap});

  final GridMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconBg = Common.seededColor(item.seed).withValues(alpha: 0.14);
    final iconColor =
        Common.seededColor(item.seed, saturation: 0.72, lightness: 0.44);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            // borderRadius: BorderRadius.circular(12),
            // border: Border.all(color: Colors.black12, width: 0.7),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(10, 0, 0, 0),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: FaIcon(
                    item.icon,
                    size: 20,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
