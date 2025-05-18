import 'package:flutter/material.dart';
import 'map_selection_page.dart'; // Import the map selection page
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For LatLng
import 'package:http/http.dart' as http;
import 'dart:convert';

class HazardReportForm extends StatefulWidget {
  const HazardReportForm({super.key});

  @override
  State<HazardReportForm> createState() => _HazardReportFormState();
}

class _HazardReportFormState extends State<HazardReportForm> {
  final _formKey = GlobalKey<FormState>();

  String? hazardType;
  String location = '';
  String description = '';
  LatLng? selectedLatLng; // Store LatLng coordinates

  // Function to navigate to the map page and get the selected location
  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapSelectionPage()),
    );

    if (result != null && result is LatLng && mounted) {
      setState(() {
        selectedLatLng = result;
        location =
            '${result.latitude}, ${result.longitude}'; // Display coordinates
      });
    }
  }

  Future<void> _sendHazardReport() async {
    final url = Uri.parse('http://1127.0.0.1:5000/send-hazard-alert');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'hazard_type': hazardType,
      'location': location,
      'description': description,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Hazard alert sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to send hazard alert: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error sending hazard alert: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Hazard'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Report a Hazard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Hazard Type Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Hazard Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Fire', child: Text('🔥 Fire')),
                    DropdownMenuItem(value: 'Flood', child: Text('🌊 Flood')),
                    DropdownMenuItem(
                        value: 'Earthquake', child: Text('🌍 Earthquake')),
                    DropdownMenuItem(value: 'Other', child: Text('⚠️ Other')),
                  ],
                  onChanged: (value) => hazardType = value,
                  validator: (value) =>
                      value == null ? 'Please select a hazard' : null,
                ),
                const SizedBox(height: 20),

                // Location field with map icon
                GestureDetector(
                  onTap: _selectLocation, // Redirect to the map page
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            location.isEmpty
                                ? 'Select Location from Map'
                                : location, // Display selected coordinates
                            style: TextStyle(
                              fontSize: 16,
                              color: location.isEmpty
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.map, color: Colors.blueAccent),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Description field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 4,
                  onChanged: (value) => description = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter description' : null,
                ),
                const SizedBox(height: 30),

                // Submit button
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text(
                      'Submit Report',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (location.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a location!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        _sendHazardReport();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
