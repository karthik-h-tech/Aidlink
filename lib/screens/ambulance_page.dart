import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AmbulancePage extends StatefulWidget {
  const AmbulancePage({super.key});

  @override
  State<AmbulancePage> createState() => _AmbulancePageState();
}

class _AmbulancePageState extends State<AmbulancePage> {
  String? arrivalTime;
  bool requesting = false;
  bool locationFetched = false;
  bool tracking = false;
  Position? _currentPosition;
  GoogleMapController? _mapController;

  List<String> status = ['Dispatched', 'En route', 'Nearby', 'Arrived'];
  int statusIndex = 0;
  Marker? _currentLocationMarker;

  final TextEditingController detailsController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      _showSnackBar('Location permissions are denied.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    setState(() {
      _currentPosition = position;
      locationFetched = true;

      locationController.text =
          '${position.latitude}, ${position.longitude}'; // Autofill location

      _currentLocationMarker = Marker(
        markerId: const MarkerId("current_location"),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: const InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        15.0,
      ),
    );

    _showSnackBar(
        'Location fetched: ${position.latitude}, ${position.longitude}');
  }

  void _requestAmbulance() {
    if (!locationFetched) {
      _showSnackBar('Fetching location, please wait!');
      return;
    }

    // Show popup with three text fields
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ambulance Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: detailsController,
              decoration: const InputDecoration(
                labelText: 'Details',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location (Auto-filled)',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final details = detailsController.text;
              final phone = phoneController.text;
              final location = locationController.text;

              Navigator.pop(context);

              try {
                final url =
                    Uri.parse('http://127.0.0.1:5000/send-ambulance-report');
                final headers = {'Content-Type': 'application/json'};
                final body = jsonEncode({
                  'details': details,
                  'phone': phone,
                  'location': location,
                });

                final response =
                    await http.post(url, headers: headers, body: body);
                if (response.statusCode == 200) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Ambulance request sent successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  setState(() {
                    requesting = true;
                    tracking = true;
                    statusIndex = 0;
                    arrivalTime = '${Random().nextInt(10) + 5} min';
                  });

                  Future.delayed(const Duration(seconds: 2), () {
                    setState(() => requesting = false);
                    _showSnackBar('Ambulance requested!\nETA: $arrivalTime');
                    _trackAmbulanceStatus();
                  });
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('❌ Failed to send request: ${response.body}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error sending request: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _trackAmbulanceStatus() {
    Future.delayed(const Duration(seconds: 5), () {
      if (statusIndex < status.length - 1) {
        setState(() => statusIndex++);
        _trackAmbulanceStatus();
      } else {
        setState(() => tracking = false);
        _showSnackBar('Ambulance has arrived!');
      }
    });
  }

  void _showNearbyAmbulance() {
    String driverName = "John Doe";
    String driverNumber = "+1 123-456-7890";
    double distance = Random().nextDouble() * 10 + 1;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 270,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nearby Ambulance',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.person, size: 40, color: Colors.red),
                title: Text('Driver: $driverName'),
                subtitle: Text('Contact: $driverNumber'),
              ),
              ListTile(
                leading:
                    const Icon(Icons.location_on, size: 40, color: Colors.blue),
                title: Text('Distance: ${distance.toStringAsFixed(2)} km'),
                subtitle: const Text('Estimated Arrival: 5-10 min'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _callDriver(driverNumber),
                icon: const Icon(Icons.call),
                label: const Text('Call Driver'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _callDriver(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showSnackBar('Could not launch call');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                children: [
                  _buildMapSection(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                  const SizedBox(height: 10),
                  _buildNearbyButton(),
                  const SizedBox(height: 20),
                  if (tracking) ...[
                    const SizedBox(height: 20),
                    _buildStatusTracker(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() => SliverAppBar(
        expandedHeight: 250.0,
        floating: false,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          title: const Text(
            'Ambulance Service',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          background: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.orange],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Icon(Icons.local_hospital, size: 100, color: Colors.white),
            ),
          ),
        ),
      );

  Widget _buildMapSection() => SizedBox(
        height: 300,
        child: locationFetched && _currentPosition != null
            ? GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude),
                  zoom: 15.0,
                ),
                markers: _currentLocationMarker != null
                    ? {_currentLocationMarker!}
                    : {},
                onMapCreated: (controller) => _mapController = controller,
              )
            : const Center(child: CircularProgressIndicator()),
      );

  Widget _buildActionButtons() => ElevatedButton(
        onPressed: _requestAmbulance,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 60),
        ),
        child: const Text('Request Ambulance', style: TextStyle(fontSize: 18)),
      );

  Widget _buildNearbyButton() => ElevatedButton(
        onPressed: _showNearbyAmbulance,
        child: const Text('Nearby Ambulance'),
      );

  Widget _buildStatusTracker() => ListTile(
        title: Text('Status: ${status[statusIndex]}'),
        subtitle: Text('ETA: $arrivalTime'),
      );
}
