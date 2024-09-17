import 'package:fl_mhis_hr/library/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: LoadingAnimationWidget.flickr(
            leftDotColor: AppColors.primary,
            rightDotColor: AppColors.danger,
            size: 40,
          ),
        ),
        const Text("Please Wait ...")
      ],
    );
  }
}
