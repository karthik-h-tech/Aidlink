import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart'; // For geolocation
import 'package:geocoding/geocoding.dart'; // For reverse geocoding
import 'dart:convert';
import 'package:http/http.dart' as http;

class HospitalPage extends StatefulWidget {
  const HospitalPage({super.key});

  @override
  State<HospitalPage> createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {
  List<Map<String, String>> _nearbyHospitals = [];
  String _statusMessage = 'Fetching nearby hospitals...';

  @override
  void initState() {
    super.initState();
    _getNearbyHospitals();
  }

  // Function to get nearby hospitals using Google Places API
  Future<void> _getNearbyHospitals() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      const String apiKey = 'enter google api'; // Replace with your API key
      final String url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=5000&type=hospital&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, String>> hospitals = [];

        for (var result in data['results']) {
          String name = result['name'];
          String address = result['vicinity'];
          String phone = result['plus_code'] != null
              ? result['plus_code']['compound_code']
              : 'No phone available';

          hospitals.add({
            'name': name,
            'location': address,
            'phone': phone, // Assuming phone is retrieved here
            'latitude': result['geometry']['location']['lat'].toString(),
            'longitude': result['geometry']['location']['lng'].toString(),
          });
        }

        setState(() {
          _nearbyHospitals = hospitals;
          _statusMessage = hospitals.isEmpty
              ? 'No nearby hospitals found'
              : 'Nearby hospitals:';
        });
      } else {
        setState(() {
          _statusMessage = 'Failed to load nearby hospitals';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error fetching nearby hospitals';
      });
    }
  }

  Future<void> _makeCall(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $phone')),
      );
    }
  }

  Future<void> _openInGoogleMaps(double latitude, double longitude) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Function to show the report dialog
  void _showReportDialog() {
    final TextEditingController hospitalController = TextEditingController();
    final TextEditingController problemController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report an Issue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: hospitalController,
                decoration: const InputDecoration(
                  labelText: 'Hospital Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: problemController,
                decoration: const InputDecoration(
                  labelText: 'Problem Description',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String hospitalName = hospitalController.text;
                String problem = problemController.text;

                if (hospitalName.isNotEmpty && problem.isNotEmpty) {
                  try {
                    final url =
                        Uri.parse('http://127.0.0.1:5000/send-hospital-report');
                    final headers = {'Content-Type': 'application/json'};
                    final body = jsonEncode({
                      'hospital_name': hospitalName,
                      'problem_description': problem,
                    });

                    final response =
                        await http.post(url, headers: headers, body: body);
                    if (response.statusCode == 200) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('✅ Report submitted successfully!')),
                        );
                      }
                      Navigator.of(context).pop(); // Close dialog
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '❌ Failed to submit report: ${response.body}')),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('❌ Error submitting report: $e')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill both fields')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Hospital Services'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 72, bottom: 16),
              title: const Text(
                'Hospital Services',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blueAccent,
                      Colors.blueAccent.withOpacity(0.8)
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_hospital,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildDescriptionSection(
                    'Our hospital provides comprehensive medical services, including emergency care, outpatient services, and specialized treatments.'),
                const SizedBox(height: 16),
                _buildNearbyHospitalsContainer(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showReportDialog,
        label: const Text('Report Issue'),
        icon: const Icon(Icons.report),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDescriptionSection(String description) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
            'About Service',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyHospitalsContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            'Nearby Hospitals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildNearbyHospitalList(),
        ],
      ),
    );
  }

  Widget _buildNearbyHospitalList() {
    if (_nearbyHospitals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_statusMessage),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _nearbyHospitals.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final hospital = _nearbyHospitals[index];
        double latitude = double.parse(hospital['latitude']!);
        double longitude = double.parse(hospital['longitude']!);
        String phone = hospital['phone']!;

        return ListTile(
          title: Text(hospital['name']!),
          subtitle: Text(hospital['location']!),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.map),
                onPressed: () => _openInGoogleMaps(latitude, longitude),
              ),
              if (phone != 'No phone available') ...[
                IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () => _makeCall(phone),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
