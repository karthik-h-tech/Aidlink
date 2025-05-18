import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // For current location
import 'package:url_launcher/url_launcher.dart'; // For calling and map navigation
import 'dart:math'; // For distance calculation
import 'hazard_report_form.dart'; // Import the form page

class HazardAlertPage extends StatefulWidget {
  const HazardAlertPage({super.key});

  @override
  State<HazardAlertPage> createState() => _HazardAlertPageState();
}

class _HazardAlertPageState extends State<HazardAlertPage> {
  List<Map<String, dynamic>> contacts = [
    {
      'name': 'National Emergency Management Agency',
      'location': 'Emergency Center',
      'phone': '112',
      'latitude': 10.8505,
      'longitude': 76.2711,
      'distance': ''
    },
    {
      'name': 'Disaster Management',
      'location': 'Main Centre',
      'phone': '108',
      'latitude': 28.7041,
      'longitude': 77.1025,
      'distance': ''
    },
    {
      'name': 'National Disaster Management Authority',
      'location': 'Centre Station',
      'phone': '011-26701730',
      'latitude': 19.0760,
      'longitude': 72.8777,
      'distance': ''
    },
  ];

  List<Map<String, dynamic>> filteredContacts = [];
  TextEditingController searchController = TextEditingController();
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    filteredContacts = List.from(contacts);
    _getCurrentLocation();
  }

  // Fetches current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _calculateDistances();
  }

  // Calculate distances
  void _calculateDistances() {
    if (currentPosition == null) return;

    setState(() {
      for (var contact in contacts) {
        double distance = _getDistance(
          currentPosition!.latitude,
          currentPosition!.longitude,
          contact['latitude'],
          contact['longitude'],
        );

        contact['distance'] = '${distance.toStringAsFixed(2)} km';
      }

      filteredContacts = List.from(contacts);
    });
  }

  // Haversine formula to calculate distance
  double _getDistance(double lat1, double lon1, double lat2, double lon2) {
    const double radius = 6371; // Earth radius in km
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Filter contacts by name
  void _filterContacts(String query) {
    setState(() {
      filteredContacts = contacts
          .where((contact) =>
              contact['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Function to make a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  // Navigate by searching the contact name in Google Maps
  Future<void> _openMapByName(String name) async {
    final Uri uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$name');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not open Google Maps for $name';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Hazard Alert'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterContacts,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildHeaderSection(),
                _buildDescriptionSection(
                  'Stay informed about potential hazards in your area. Our hazard alert service provides timely notifications and resources to keep you safe.',
                ),
                _buildEmergencyContactsSection(context, filteredContacts),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.report, color: Colors.white),
          label: const Text(
            'Report Hazard',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HazardReportForm()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, size: 80, color: Colors.white),
            SizedBox(height: 10),
            Text(
              'Hazard Alert',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(String description) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),
      child:
          Text(description, style: const TextStyle(fontSize: 16, height: 1.5)),
    );
  }

  Widget _buildEmergencyContactsSection(
      BuildContext context, List<Map<String, dynamic>> contacts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          leading: IconButton(
            icon: const Icon(Icons.phone, color: Colors.green),
            onPressed: () => _makePhoneCall(contact['phone']),
          ),
          title: Text(contact['name']),
          subtitle: Text('${contact['location']} • ${contact['distance']}'),
          trailing: IconButton(
            icon: const Icon(Icons.map, color: Colors.blue),
            onPressed: () => _openMapByName(contact['name']),
          ),
        );
      },
    );
  }
}
