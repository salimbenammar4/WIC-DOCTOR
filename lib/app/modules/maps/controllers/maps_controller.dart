import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../common/ui.dart';
import '../../../models/address_model.dart';
import '../../../models/clinic_model.dart';
import '../../../repositories/clinic_repository.dart';
import '../../../services/settings_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class MapsController extends GetxController {
  final clinics = <Clinic>[].obs;
  final allMarkers = <Marker>[].obs;
  final cameraPosition = CameraPosition(target: LatLng(0, 0)).obs;
  final mapController = Rx<GoogleMapController?>(null);
  late ClinicRepository _clinicRepository;

  // Add this property to keep track of the card position
  var cardPosition = Offset(0, 0).obs;

  MapsController() {
    _clinicRepository = ClinicRepository();
  }

  Address get currentAddress => Get.find<SettingsService>().address.value;

  @override
  void onInit() async {
    await refreshMaps();
    super.onInit();
  }

  Future refreshMaps({bool showMessage = false}) async {
    await getCurrentPosition();
    if (showMessage) {
      Get.showSnackbar(Ui.SuccessSnackBar(message: "Page actualisée avec succées".tr));
    }
  }


  Future<void> getCurrentPosition() async {
    cameraPosition.value = CameraPosition(
      target: currentAddress.getLatLng(),
      zoom: 5.4746, // Adjust zoom level as needed
    );
    Marker marker = await _getMyPositionMarker(currentAddress.getLatLng());
    allMarkers.add(marker);
  }

  Future<void> updateCardPosition() async {
    if (mapController.value != null) {
      // Get the current position
      LatLng myPosition = currentAddress.getLatLng();

      // Convert LatLng to screen coordinates
      final screenCoordinates = await mapController.value!.getScreenCoordinate(myPosition);

      // Update the card position with double values
      cardPosition.value = Offset(screenCoordinates.x.toDouble(), screenCoordinates.y.toDouble());
    }
  }

  Future getNearClinics() async {
    try {
      clinics.clear();
      clinics.assignAll(await _clinicRepository.getNearClinics(currentAddress.getLatLng(), cameraPosition.value.target));
      clinics.forEach((element) async {
        var clinicMarker = await getClinicMarker(element);
        allMarkers.add(clinicMarker);
      });
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<void> goToClinic(LatLng clinicPosition) async {
    if (mapController.value != null) {
      await mapController.value!.animateCamera(
        CameraUpdate.newLatLng(clinicPosition),
      );
    }
  }

  Future<Marker> _getMyPositionMarker(LatLng latLng) async {
    final Uint8List markerIcon = await _getBytesFromAsset('assets/img/my_marker.png', 120);
    final Marker marker = Marker(
      markerId: MarkerId(Random().nextInt(100).toString()),
      icon: BitmapDescriptor.fromBytes(markerIcon),
      anchor: ui.Offset(0.5, 0.5),
      position: latLng,
    );

    return marker;
  }

  Future<Marker> getClinicMarker(Clinic clinic) async {
    final Uint8List markerIcon = await _getBytesFromAsset('assets/img/marker.png', 120);

    // Get the user's current LatLng
    LatLng userLatLng = currentAddress.getLatLng();

    // Calculate the distance between user and clinic
    double distanceInMeters = Geolocator.distanceBetween(
      userLatLng.latitude,
      userLatLng.longitude,
      clinic.address!.getLatLng().latitude,
      clinic.address!.getLatLng().longitude,
    );

    // Format the distance for display
    String formattedDistance = distanceInMeters < 1000
        ? "${distanceInMeters.toStringAsFixed(0)} m"
        : "${(distanceInMeters / 1000).toStringAsFixed(2)} km";

    final Marker marker = Marker(
      markerId: MarkerId(clinic.id),
      icon: BitmapDescriptor.fromBytes(markerIcon),
      anchor: ui.Offset(0.5, 0.5),
      infoWindow: InfoWindow(
        title: clinic.name,
        snippet: formattedDistance, // Use the calculated distance here
        onTap: () {
          // Handle info window tap
        },
      ),
      position: clinic.address!.getLatLng(),
    );

    return marker;
  }

  Future<void> requestLocationPermissionAndNavigate() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      try {
        // Get the user's current location
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        LatLng userLocation = LatLng(position.latitude, position.longitude);

        // Update the camera position to user's current location
        cameraPosition.value = CameraPosition(
          target: userLocation,
          zoom: 15.0, // Adjust zoom level as needed
        );

        // Add a marker for user's location
        Marker userMarker = await _getMyPositionMarker(userLocation);
        allMarkers.add(userMarker);

        // Move the camera to the user's location
        if (mapController.value != null) {
          await mapController.value!.animateCamera(
            CameraUpdate.newLatLng(userLocation),
          );
        }
      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: "Failed to get location: $e"));
      }
    } else if (status.isDenied || status.isPermanentlyDenied) {
      Get.showSnackbar(Ui.ErrorSnackBar(
        message: "Location permission denied. Please enable it in settings.",
      ));
    }
  }
  String calculateDistance(LatLng clinicLatLng ) {
    var userLatLng= currentAddress.getLatLng();

    double distanceInMeters = Geolocator.distanceBetween(
      userLatLng.latitude,
      userLatLng.longitude,
      clinicLatLng.latitude,
      clinicLatLng.longitude,
    );
    print(userLatLng.latitude);

    print(userLatLng.longitude);

    print(clinicLatLng.latitude);

    print(clinicLatLng.longitude);


    print(distanceInMeters);
    // Format distance
    return distanceInMeters < 1000
        ? "${distanceInMeters.toStringAsFixed(0)} m"
        : "${(distanceInMeters / 1000).toStringAsFixed(2)} km";
  }
}
