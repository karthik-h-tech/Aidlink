import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DisasterRecoveryPage extends StatefulWidget {
  const DisasterRecoveryPage({super.key});

  @override
  State<DisasterRecoveryPage> createState() => _DisasterRecoveryPageState();
}

class _DisasterRecoveryPageState extends State<DisasterRecoveryPage> {
  bool _isReporting = false;
  String _currentLocation = "Fetching location...";

  final Map<String, bool> _resources = {
    'Medicine': false,
    'Water': false,
    'Food': false,
    'Clothing': false,
    'Shelter': false,
  };

  final TextEditingController _extraController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = "${position.latitude}, ${position.longitude}";
        _locationController.text = _currentLocation;
      });
    } catch (e) {
      setState(() {
        _currentLocation = "Location unavailable";
      });
    }
  }

  void _toggleReport() {
    setState(() {
      _isReporting = !_isReporting;
      if (_isReporting) {
        _fetchLocation();
      }
    });
  }

  Future<void> _sendReportToBackend(
      String location, List<String> resources, String extraInfo) async {
    final url = Uri.parse('http://10.10.168.144::5000/send-disaster-report');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'location': location,
      'resources': resources,
      'extra_info': extraInfo,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Disaster recovery report sent successfully!'),
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

  void _submitReport() {
    final selectedResources = _resources.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    final extraText = _extraController.text;
    final locationText = _locationController.text;

    if (selectedResources.isEmpty && extraText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please select at least one resource or add extra information.'),
        ),
      );
      return;
    }

    _sendReportToBackend(locationText, selectedResources, extraText);

    setState(() {
      _resources.updateAll((key, value) => false);
      _extraController.clear();
      _locationController.clear();
      _isReporting = false;
    });
  }

  Future<void> _call(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not call $phoneNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Recovery'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.red, Colors.redAccent],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.replay,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
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
                  const Text(
                    'Our disaster recovery service provides support and resources for individuals and communities affected by disasters. We coordinate with local agencies to ensure timely assistance.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    'Emergency Contacts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactList(context),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isReporting) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
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
                      'Report Needed Resources',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location (Fetched Automatically)',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    ..._resources.keys.map((resource) => CheckboxListTile(
                          title: Text(resource),
                          value: _resources[resource],
                          onChanged: (bool? value) {
                            setState(() {
                              _resources[resource] = value!;
                            });
                          },
                        )),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _extraController,
                      decoration: const InputDecoration(
                        labelText: 'Extra Information',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitReport,
                        child: const Text('Submit Report'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.report),
                label: Text(_isReporting ? 'Cancel Report' : 'Report'),
                onPressed: _toggleReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactList(BuildContext context) {
    final contacts = [
      {'name': 'National Disaster Response Team', 'phone': '011-23438091'},
      {'name': 'Kerala State Disaster Management', 'phone': '0471-2331345'},
      {'name': 'National Disaster Management', 'phone': '012 848 4602'},
    ];

    return Column(
      children: contacts
          .map((contact) => ListTile(
                title: Text(contact['name']!),
                subtitle: Text(contact['phone']!),
                trailing: IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: () => _call(contact['phone']!),
                ),
              ))
          .toList(),
    );
  }
}
