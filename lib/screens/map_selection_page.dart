import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapSelectionPage extends StatefulWidget {
  const MapSelectionPage({super.key});

  @override
  State<MapSelectionPage> createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  late GoogleMapController mapController;
  LatLng? selectedLocation; // Selected location
  LatLng? currentLocation; // Current GPS location
  bool isLoading = true; // Loading indicator

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // ✅ Get current location with GPS accuracy
  Future<void> _getCurrentLocation() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best, // High GPS accuracy
        );

        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
          isLoading = false;
        });

        // Move the camera to the current location
        if (mapController != null) {
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(currentLocation!, 16.0), // Zoom in
          );
        }
      } catch (e) {
        print('Error: $e');
        setState(() => isLoading = false);
      }
    } else {
      print('Location permission denied');
      setState(() => isLoading = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    if (currentLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation!, 16.0),
      );
    }
  }

  // ✅ Center map on current GPS location
  void _centerOnCurrentLocation() {
    if (currentLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation!, 16.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (selectedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                // Return the selected location
                Navigator.pop(context, selectedLocation);
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: currentLocation ?? const LatLng(0.0, 0.0),
                zoom: 16.0,
              ),
              markers: {
                // ✅ GPS location marker with high accuracy
                if (currentLocation != null)
                  Marker(
                    markerId: const MarkerId('gpsLocation'),
                    position: currentLocation!,
                    infoWindow: const InfoWindow(title: 'My GPS Location'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue), // Blue marker for GPS
                  ),
                // Marker for the selected location
                if (selectedLocation != null)
                  Marker(
                    markerId: const MarkerId('selected'),
                    position: selectedLocation!,
                    infoWindow: const InfoWindow(title: 'Selected Location'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed), // Red marker for selection
                  ),
              },
              onTap: (LatLng position) {
                setState(() {
                  selectedLocation = position;
                });
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnCurrentLocation,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
