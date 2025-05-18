import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WildlifeConservationPage extends StatefulWidget {
  const WildlifeConservationPage({super.key});

  @override
  State<WildlifeConservationPage> createState() =>
      _WildlifeConservationPageState();
}

class _WildlifeConservationPageState extends State<WildlifeConservationPage> {
  Position? _currentPosition;
  Map<String, double> _distances = {};

  final List<Map<String, dynamic>> _contacts = [
    {
      'name': 'Wildlife SOS Hotline',
      'location': 'New Delhi, India',
      'phone': '+91-9871963535',
      'latitude': 28.6139,
      'longitude': 77.2090,
    },
    {
      'name': 'Rapid Response Teams',
      'location': 'Kerala, India',
      'phone': '8547 602299',
      'latitude': 10.8505,
      'longitude': 76.2711,
    },
    {
      'name': 'Wildlife Rescues',
      'location': 'Kerala, India',
      'phone': '1800 425 4733',
      'latitude': 9.9312,
      'longitude': 76.2673,
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _calculateDistances();
      });
    }
  }

  void _calculateDistances() {
    if (_currentPosition == null) return;

    final double currentLat = _currentPosition!.latitude;
    final double currentLng = _currentPosition!.longitude;

    for (var contact in _contacts) {
      final double distance = _calculateHaversineDistance(
        currentLat,
        currentLng,
        contact['latitude'],
        contact['longitude'],
      );

      setState(() {
        _distances[contact['name']] = distance;
      });
    }
  }

  double _calculateHaversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double radius = 6371; // Radius of the Earth in km
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radius * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Wildlife Conservation'),
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeading(),
                const SizedBox(height: 20),
                _buildTopSymbolBox(),
                const SizedBox(height: 20),
                _buildAboutServiceBox(),
                const SizedBox(height: 20),
                _buildEmergencyContactsSection(context),
                const SizedBox(height: 20),
                _buildReportButton(context),
              ],
            ),
    );
  }

  Widget _buildHeading() {
    return const Center(
      child: Text(
        'Wildlife Conservation',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildTopSymbolBox() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.pets, // Paw icon
          size: 100,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAboutServiceBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About the Service',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'This service connects you with nearby wildlife conservation teams and provides contact information for emergency rescue and support services.',
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Contacts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _contacts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final contact = _contacts[index];
              final distance = _distances[contact['name']] ?? 0.0;

              return ListTile(
                leading: IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: () => _makePhoneCall(contact['phone']),
                ),
                title: Text(
                  contact['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${contact['location']} \nDistance: ${distance.toStringAsFixed(2)} km',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.map, color: Colors.blue),
                  onPressed: () => _openMapByName(contact['name']),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () => _showReportDialog(context),
      child: const Text('Report an Issue', style: TextStyle(fontSize: 18)),
    );
  }

  Future<void> _showReportDialog(BuildContext context) async {
    TextEditingController reportController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report an Issue'),
        content: TextField(
          controller: reportController,
          decoration: const InputDecoration(
            hintText: 'Describe the issue...',
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              final reportText = reportController.text.trim();
              if (reportText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Please enter a description before submitting.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.of(context).pop();
              await _sendReportToBackend(reportText);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendReportToBackend(String reportText) async {
    final url =
        Uri.parse('http://127.0.0.1:5000/send-wildlife-conservation-report');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'description': reportText,
      'location': _currentPosition != null
          ? '${_currentPosition!.latitude}, ${_currentPosition!.longitude}'
          : 'Location unavailable',
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Wildlife conservation report sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to send report: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error sending report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openMapByName(String name) async {
    final Uri uri = Uri.parse('https://www.google.com/maps/search/$name');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
