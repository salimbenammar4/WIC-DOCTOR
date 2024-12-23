import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/maps_controller.dart';
import '../widgets/maps_carousel_widget.dart';

class MapsView extends GetView<MapsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Obx(() {
            return GoogleMap(
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              padding: EdgeInsets.only(top: 35),
              mapType: MapType.normal,
              initialCameraPosition: controller.cameraPosition.value,
              markers: Set.from(controller.allMarkers),
              onMapCreated: (GoogleMapController _controller) {
                controller.mapController.value = _controller;
                controller.requestLocationPermissionAndNavigate();
                controller.getNearClinics(); // Fetch clinics when map is created
              },
              onCameraMoveStarted: () {
                controller.clinics.clear();
              },
              onCameraMove: (CameraPosition cameraPosition) {
                controller.cameraPosition.value = cameraPosition;
              },
              onCameraIdle: () {
                // Optionally, debounce this call if necessary
                controller.getNearClinics(); // Fetch nearby clinics
              },
            );
          }),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MapsCarouselWidget(), // Ensure this widget updates according to the clinics
            ],
          ),
          Container(
            margin: EdgeInsetsDirectional.only(end: 50),
            height: 120,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Get.theme.hintColor),
                  onPressed: () => Get.back(),
                ),
                Expanded(
                  child: Text(
                    "Maps Explorer".tr,
                    style: Get.textTheme.titleLarge,
                    textAlign: TextAlign.center,
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
