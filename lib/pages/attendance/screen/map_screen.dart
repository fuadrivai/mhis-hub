import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final String type;
  const MapScreen({super.key, required this.type});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double lat = -6.200000, long = 106.816666, zoom = 0;
  late GoogleMapController _googleMapController;
  bool isLoading = true;

  @override
  void initState() {
    getLocation();
    super.initState();
  }

  getLocation() {
    isLoading = true;
    Common.determinePosition().then((val) {
      setState(() {
        lat = val.latitude;
        long = val.longitude;
        zoom = 17;
        isLoading = false;
      });
    });
    setState(() {});
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            onPressed: getLocation,
            icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
          ),
        ),
        title: widget.type.toUpperCase(),
      ),
      body: isLoading
          ? const LoadingWidget()
          : Stack(
              alignment: AlignmentDirectional.center,
              children: [
                GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
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
                  bottom: 30,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: AuthButton(
                      onTap: () {
                        if (widget.type == "checkin") {
                          context.goNamed('clockin');
                        } else {
                          context.goNamed('clockout');
                        }
                      },
                      text: "Next",
                      height: 50,
                      color: AppColors.blue,
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
