import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../services/geocode_service.dart';


class ClinicMapView extends StatefulWidget {
  final String clinicAddress; // Address to geocode
  final String clinicName; // Name of the clinic

  ClinicMapView({required this.clinicAddress, required this.clinicName});

  @override
  _ClinicMapViewState createState() => _ClinicMapViewState();
}

class _ClinicMapViewState extends State<ClinicMapView> {
  LatLng? _clinicLocation; // Variable to store clinic's location

  @override
  void initState() {
    super.initState();
    _fetchClinicLocation(); // Fetch the clinic's location on init
  }

  Future<void> _fetchClinicLocation() async {
    final geocodeService = GeocodeService();
    try {
      final response = await geocodeService.getGeocode(widget.clinicAddress);
      if (response['items'] != null && response['items'].isNotEmpty) {
        final location = response['items'][0]['position'];
        setState(() {
          _clinicLocation = LatLng(location['lat'], location['lng']);
        });
      } else {
        print('No location found');
      }
    } catch (error) {
      print('Error fetching location: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.clinicName)),
      body: _clinicLocation == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _clinicLocation!, // Center the map on the clinic's location
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId('clinic_location'),
            position: _clinicLocation!,
            infoWindow: InfoWindow(title: widget.clinicName), // Show clinic name on marker
          ),
        },
      ),
    );
  }
}
