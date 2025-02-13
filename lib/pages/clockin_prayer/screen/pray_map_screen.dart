import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/clockin_prayer/data/clock_in_prayer_api.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';

class PrayMapScreen extends StatefulWidget {
  const PrayMapScreen({super.key});

  @override
  State<PrayMapScreen> createState() => _PrayMapScreenState();
}

class _PrayMapScreenState extends State<PrayMapScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: IconButton(
          onPressed: () => ctx.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: "Clock In Ashar",
      ),
      body: isLoading
          ? const LoadingWidget()
          : MapWidget(
              btnTitle: "Tap IN",
              onTap: () async {
                isLoading = true;
                setState(() {});
                Position position = await Common.determinePosition();
                if (position.isMocked) {
                  isLoading = false;
                  Common.modalInfo(
                    // ignore: use_build_context_synchronously
                    ctx,
                    title: "Error",
                    mode: MODE.error,
                    message: "Out Of Area",
                  );
                  setState(() {});
                }

                PostPrayer post = PostPrayer();
                post.clockTime =
                    Jiffy.now().format(pattern: "yyyy-MM-dd HH:mm:ss");
                post.latitude = position.latitude;
                post.longitude = position.longitude;
                post.note = "";

                ClockInPrayerApi.postPrayer(post).then((val) {
                  setState(() {
                    isLoading = false;
                    Common.modalInfo(
                      // ignore: use_build_context_synchronously
                      ctx,
                      title: "Success",
                      mode: MODE.success,
                    );
                  });
                }).catchError((err) {
                  isLoading = false;
                  setState(() {});
                });
              },
            ),
    );
  }
}
