import 'package:fl_mhis_hr/library/constant.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final double height;
  const LoadingShimmer({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 10,
      ),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.white,
          gradient: Common.shimmerGradient,
        ),
        padding: const EdgeInsets.all(20),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: const Text(
            "Please Wait ...",
            style: TextStyle(
              color: AppColors.danger,
            ),
          ),
        ),
      ),
    );
  }
}
