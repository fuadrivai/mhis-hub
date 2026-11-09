import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final String? btnTitle;
  final GestureTapCallback? onTap;
  final Color? buttonColor;
  final bool centerButton;
  const MapWidget({
    super.key,
    this.onTap,
    this.btnTitle,
    this.buttonColor,
    this.centerButton = false,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  double lat = -6.200000, long = 106.816666, zoom = 0;
  bool isLoading = true;
  GoogleMapController? _googleMapController;

  @override
  void initState() {
    getLocation();
    // WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     getLocation();
  //   } else {
  //     _googleMapController.dispose();
  //   }
  //   super.didChangeAppLifecycleState(state);
  // }

  Future<void> getLocation() async {
    isLoading = true;
    bool isLocationActive = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return;
    if (isLocationActive) {
      Common.determinePosition().then((val) {
        if (!mounted) return;
        setState(() {
          lat = val.latitude;
          long = val.longitude;
          zoom = 17;
          isLoading = false;
        });
      });
    } else {
      await Geolocator.openLocationSettings().then((val) {
        getLocation();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingWidget()
        : Stack(
            alignment: AlignmentDirectional.centerEnd,
            children: [
              GoogleMap(
                myLocationEnabled: true,
                // myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                onMapCreated: (controller) {
                  _googleMapController = controller;
                  setState(() {});
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat, long),
                  zoom: zoom,
                ),
              ),
              Positioned(
                top: 60,
                right: 10,
                child: GestureDetector(
                  onTap: getLocation,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.dark.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Center(
                      child: FaIcon(FontAwesomeIcons.arrowsRotate),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: widget.centerButton ? 0 : null,
                right: widget.centerButton ? 0 : 100,
                child: Center(
                  child: SizedBox(
                    width: 200,
                    child: AuthButton(
                      onTap: widget.onTap,
                      text: widget.btnTitle ?? "Next",
                      height: 50,
                      color: widget.buttonColor ?? AppColors.blue,
                    ),
                  ),
                ),
              )
            ],
          );
  }
}
