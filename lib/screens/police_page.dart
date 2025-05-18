import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

const String googleMapsApiKey = 'enter google api'; // Replace with your API Key

class PolicePage extends StatefulWidget {
  const PolicePage({Key? key}) : super(key: key);

  @override
  _PolicePageState createState() => _PolicePageState();
}

class _PolicePageState extends State<PolicePage> {
  List<Map<String, dynamic>> nearbyStations = [];

  @override
  void initState() {
    super.initState();
    _fetchNearbyStations();
  }

  Future<Position> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _fetchNearbyStations() async {
    try {
      final Position position = await _getUserLocation();
      final String url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
          '?location=${position.latitude},${position.longitude}'
          '&radius=5000'
          '&type=police'
          '&key=$googleMapsApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> stations = [];

        for (var place in data['results']) {
          // Fetching additional details including phone number
          final placeDetailsUrl =
              'https://maps.googleapis.com/maps/api/place/details/json?place_id=${place['place_id']}&fields=formatted_phone_number&key=$googleMapsApiKey';
          final placeDetailsResponse =
              await http.get(Uri.parse(placeDetailsUrl));
          String phoneNumber = 'N/A';
          if (placeDetailsResponse.statusCode == 200) {
            final placeDetailsData = json.decode(placeDetailsResponse.body);
            if (placeDetailsData['result'] != null) {
              phoneNumber =
                  placeDetailsData['result']['formatted_phone_number'] ?? 'N/A';
            }
          }

          stations.add({
            'name': place['name'],
            'address': place['vicinity'],
            'latitude': place['geometry']['location']['lat'],
            'longitude': place['geometry']['location']['lng'],
            'phone': phoneNumber,
          });
        }

        setState(() {
          nearbyStations = stations;
        });
      } else {
        throw Exception('Failed to load stations');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading stations: $e')),
      );
    }
  }

  void _openInGoogleMaps(double latitude, double longitude) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _callPoliceStation(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not dial $phoneNumber';
    }
  }

  // Report pop-up dialog
  void _showReportDialog() {
    String reportText = '';
    List<String> selectedCrimes = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Report Crime'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Crime Type:'),
                    Wrap(
                      spacing: 10.0,
                      children: [
                        'Theft',
                        'Assault',
                        'Vandalism',
                        'Fraud',
                        'Other'
                      ].map((crime) {
                        return CheckboxListTile(
                          title: Text(crime),
                          value: selectedCrimes.contains(crime),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedCrimes.add(crime);
                              } else {
                                selectedCrimes.remove(crime);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      maxLines: 4,
                      onChanged: (value) => reportText = value,
                      decoration: const InputDecoration(
                        labelText: 'Describe the incident',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final url =
                        Uri.parse('http://127.0.0.1:5000/send-crime-report');
                    final headers = {'Content-Type': 'application/json'};
                    final body = jsonEncode({
                      'crime_types': selectedCrimes,
                      'description': reportText,
                    });

                    try {
                      final response =
                          await http.post(url, headers: headers, body: body);
                      if (response.statusCode == 200) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('✅ Crime report sent successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                        Navigator.of(context).pop();
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '❌ Failed to send report: ${response.body}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Error sending report: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Report'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFFB2EBF2)
            ], // Light cyan gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AppBar(
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      title: const Text('Police Service'),
                      backgroundColor: Colors.blue,
                    ),

                    // Police Icon
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16.0),
                      child: const Icon(
                        Icons.local_police,
                        size: 100,
                        color: Colors.blue,
                      ),
                    ),

                    // About Service Section
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.white70,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Service',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'This service provides information on nearby police stations and emergency contacts. '
                            'You can also navigate to police stations using Google Maps for assistance.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Emergency Contacts Section
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Emergency Contacts',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildEmergencyContact(
                            'Police Control Room',
                            '100',
                            Icons.local_police,
                          ),
                          _buildEmergencyContact(
                            'Emergency Response Support',
                            '112',
                            Icons.phone,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Nearby Police Stations Section in a Container
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nearby Police Stations',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          nearbyStations.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: nearbyStations.length,
                                  itemBuilder: (context, index) {
                                    final station = nearbyStations[index];
                                    return ListTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                              child: Text(station['name'])),
                                          IconButton(
                                            icon: const Icon(Icons.map,
                                                color: Colors.blue),
                                            onPressed: () {
                                              _openInGoogleMaps(
                                                  station['latitude'],
                                                  station['longitude']);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.call,
                                                color: Colors.green),
                                            onPressed: () {
                                              _callPoliceStation(
                                                  station['phone']);
                                            },
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(station['address']),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Report Button at Bottom
            SafeArea(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.report, color: Colors.white),
                label: const Text('Report Crime'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: _showReportDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContact(String name, String number, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(name),
      subtitle: Text('Call: $number'),
      onTap: () => launchUrl(Uri(scheme: 'tel', path: number)),
    );
  }
}
