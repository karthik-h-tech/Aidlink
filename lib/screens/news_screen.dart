import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _newsItems = [];
  String _district = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  // Function to get the current location
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw Exception("Failed to get current location: $e");
    }
  }

  // Function to determine the district using Google Maps API
  Future<String> _getDistrictFromGoogleMaps(
      double latitude, double longitude) async {
    const String apiKey = "enter google api"; // Replace with your API Key
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'OK') {
          for (var result in data['results']) {
            for (var component in result['address_components']) {
              if (component['types'].contains('administrative_area_level_2')) {
                return component['long_name']; // District name
              }
            }
          }
          print("District not found in address components.");
        } else {
          print("Google Maps API returned status: ${data['status']}");
        }
      } else {
        print("Failed to fetch district: HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching district: $e");
    }
    return "Unknown"; // Default if API fails
  }

  // Function to load disaster-related news based on the district
  Future<void> _loadNews() async {
    setState(() => _isLoading = true);

    try {
      Position position = await _getCurrentLocation();

      // Define bounding boxes for districts (latitude and longitude)
      // Updated bounding boxes based on user-provided accurate ranges
      final alappuzhaBounds = {
        'latMin': 9.05,
        'latMax': 9.55,
        'lngMin': 76.17,
        'lngMax': 76.63,
      };
      final kottayamBounds = {
        'latMin': 9.15,
        'latMax': 9.75,
        'lngMin': 76.32,
        'lngMax': 76.95,
      };
      final ernakulamBounds = {
        'latMin': 9.75,
        'latMax': 10.35,
        'lngMin': 76.10,
        'lngMax': 76.80,
      };
      final pathanamthittaBounds = {
        'latMin': 9.07,
        'latMax': 9.47,
        'lngMin': 76.51,
        'lngMax': 77.20,
      };

      bool isInBounds(Position pos, Map<String, double> bounds) {
        return pos.latitude >= bounds['latMin']! &&
            pos.latitude <= bounds['latMax']! &&
            pos.longitude >= bounds['lngMin']! &&
            pos.longitude <= bounds['lngMax']!;
      }

      // Removed debug print statements as per user request

      String districtName = 'Unknown Location';

      if (isInBounds(position, alappuzhaBounds)) {
        districtName = 'Alappuzha';
      } else if (isInBounds(position, kottayamBounds)) {
        districtName = 'Kottayam';
      } else if (isInBounds(position, ernakulamBounds)) {
        districtName = 'Ernakulam';
      } else if (isInBounds(position, pathanamthittaBounds)) {
        districtName = 'Pathanamthitta';
      }

      setState(() {
        _district = districtName;
      });

      if (districtName == 'Alappuzha') {
        _newsItems = [
          {
            'title': 'Flood Alert in Alappuzha',
            'description':
                'Alappuzha district is facing flooding after continuous rainfall...',
            'time': '10:30 AM',
            'category': 'Flood'
          },
          {
            'title': 'Damaged Roads in Alappuzha',
            'description':
                'Several roads have been submerged due to rising water levels...',
            'time': '9:00 AM',
            'category': 'Flood'
          },
        ];
      } else if (districtName == 'Kottayam') {
        _newsItems = [
          {
            'title':
                'Landslides, Flooding in Kottayam: Houses, Crops Damaged; No Lives Lost',
            'description':
                'Heavy rainfall caused flash floods and a landslide in the hill region of Kottayam district...',
            'time': '18 Aug 2024',
            'category': 'Landslide/Flood'
          },
          {
            'title': 'Heavy Rain Causes Flash Flooding in Kottayam',
            'description':
                'Heavy rainfall has led to massive flooding in Mundakayam and Kanjirapally...',
            'time': '17 Aug 2024',
            'category': 'Flood'
          },
          {
            'title': 'Heavy Rain Leaves a Trail of Destruction in Kottayam',
            'description':
                'The heavy rain accompanied by stormy winds that lashed central Travancore...',
            'time': '28 May 2024',
            'category': 'Storm/Flood'
          },
          {
            'title': 'Kottayam Flooding: Many Homes Submerged',
            'description':
                'The flooding in Kottayam has submerged numerous homes and roads...',
            'time': '20 Aug 2024',
            'category': 'Flood'
          },
        ];
      } else if (districtName == 'Ernakulam') {
        _newsItems = [
          {
            'title': 'Landslide in Ernakulam District',
            'description':
                'A massive landslide has blocked roads in Ernakulam following heavy rains...',
            'time': '2:00 PM',
            'category': 'Landslide'
          },
          {
            'title': 'Flood Waters Rise in Ernakulam',
            'description':
                'Floodwaters are affecting several low-lying areas in Ernakulam...',
            'time': '1:30 PM',
            'category': 'Flood'
          },
        ];
      } else if (districtName == 'Pathanamthitta') {
        _newsItems = [
          {
            'title': 'Pathanamthitta Receives Flood Warning',
            'description':
                'Pathanamthitta district is at risk of flooding due to continuous rain...',
            'time': '11:00 AM',
            'category': 'Flood'
          },
          {
            'title': 'Pathanamthitta Landslide Alerts Issued',
            'description':
                'Pathanamthitta has issued a landslide alert after persistent rainfall...',
            'time': '8:30 AM',
            'category': 'Landslide'
          },
        ];
      } else {
        _newsItems = [
          {
            'title': 'Local Disaster Alert: Unexpected Rainfall Expected',
            'description':
                'Residents are advised to stay alert as unexpected rainfall may cause local flooding...',
            'time': '12:00 PM',
            'category': 'Weather'
          },
        ];
      }
    } catch (e) {
      print('Error fetching location: $e');
      _newsItems = [
        {
          'title': 'Error fetching location data',
          'description':
              'Could not retrieve news for your area. Please try again.',
          'time': 'Unknown',
          'category': 'Error'
        },
      ];
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Disaster-Related News - $_district',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F172A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNews,
              child: ListView.builder(
                itemCount: _newsItems.length,
                itemBuilder: (context, index) {
                  final news = _newsItems[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(news['title'] ?? 'No title',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(news['description'] ?? 'No description',
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('Published: ${news['time'] ?? 'Unknown time'}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadNews,
        backgroundColor: const Color(0xFFE9A23B),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
