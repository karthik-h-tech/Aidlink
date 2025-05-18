import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class FireRescuePage extends StatefulWidget {
  const FireRescuePage({super.key});

  @override
  State<FireRescuePage> createState() => _FireRescuePageState();
}

class _FireRescuePageState extends State<FireRescuePage> {
  late ScrollController _scrollController;
  bool _showScrollToTop = false;
  Map<String, String>? nearestFireStation;
  Position? _currentPosition;
  bool _isLoading = false;

  final String apiKey = "enter google api"; // ✅ Replace with your API key

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _fetchNearestFireStation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    setState(() {
      _showScrollToTop = _scrollController.offset > 300;
    });
  }

  // ✅ Fetch Nearest Fire Station using Google Places API
  Future<void> _fetchNearestFireStation() async {
    setState(() => _isLoading = true);

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      double lat = _currentPosition!.latitude;
      double lon = _currentPosition!.longitude;

      String apiUrl =
          "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lon&radius=5000&type=fire_station&key=$apiKey";

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["results"].isNotEmpty) {
          var station = data["results"][0]; // First nearest fire station
          String placeId = station["place_id"];
          String stationName = station["name"];
          String stationLocation =
              "${station["geometry"]["location"]["lat"]}, ${station["geometry"]["location"]["lng"]}";

          // Fetch Phone Number using Place Details API
          String phone = await _fetchPlacePhoneNumber(placeId);

          setState(() {
            nearestFireStation = {
              'name': stationName,
              'location': stationLocation,
              'phone': phone.isNotEmpty ? phone : "Not Available",
            };
          });
        } else {
          Fluttertoast.showToast(msg: "No fire stations found nearby.");
        }
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch fire station data.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching fire station: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ Fetch Phone Number using Google Places Details API
  Future<String> _fetchPlacePhoneNumber(String placeId) async {
    try {
      String detailsUrl =
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_phone_number&key=$apiKey";

      final response = await http.get(Uri.parse(detailsUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["result"]["formatted_phone_number"] ?? "";
      }
    } catch (e) {
      print("Error fetching phone number: $e");
    }
    return "";
  }

  // ✅ Make Phone Call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Fluttertoast.showToast(msg: "Failed to make the phone call.");
    }
  }

  // ✅ Open Google Maps for Navigation
  Future<void> _openMap(String location) async {
    if (_currentPosition == null) {
      Fluttertoast.showToast(msg: "⚠️ Location not available. Try again.");
      return;
    }

    final Uri url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=$location');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Fluttertoast.showToast(msg: "Failed to open map.");
    }
  }

  // ✅ Scroll to Top Button
  Widget _buildScrollToTopButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }

  // ✅ Report Emergency Button and Dialog
  void _showReportEmergencyDialog() async {
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    TextEditingController reportController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Report Fire Rescue"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    "Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}"),
                const SizedBox(height: 10),
                TextField(
                  controller: reportController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Describe the incident',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final location =
                    "${_currentPosition!.latitude},${_currentPosition!.longitude}";
                final reportText = reportController.text;

                final url =
                    Uri.parse('http://127.0.0.1:5000/send-fire-rescue-report');
                final headers = {'Content-Type': 'application/json'};
                final body = jsonEncode({
                  'location': location,
                  'report_text': reportText,
                });

                try {
                  final response =
                      await http.post(url, headers: headers, body: body);
                  if (response.statusCode == 200) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('✅ Fire rescue report sent successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('❌ Failed to send report: ${response.body}'),
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
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // ✅ App Bar
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Fire Rescue Service',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.orangeAccent],
            ),
          ),
          child: const Center(
            child: Icon(Icons.local_fire_department,
                size: 100, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ✅ Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildAboutServiceSection(), // ✅ "About Service" section above "Nearby Fire Stations"
                    _buildNearbyStationsHeading(),
                    _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: SpinKitFadingCircle(
                                color: Colors.red,
                                size: 50.0,
                              ),
                            ),
                          )
                        : nearestFireStation != null
                            ? _buildNearbyStationSection(nearestFireStation!)
                            : const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text("No fire station found"),
                                ),
                              ),
                  ],
                ),
              ),
            ],
          ),
          if (_showScrollToTop) _buildScrollToTopButton(),
        ],
      ),
      // ✅ Report Emergency Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _showReportEmergencyDialog,
        child: const Icon(Icons.report_problem, color: Colors.white),
      ),
    );
  }

  // ✅ "About Service" Section
  Widget _buildAboutServiceSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Service',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'The Fire Rescue Service provides immediate emergency assistance in case of fire hazards. Our goal is to ensure public safety by responding promptly to distress calls and coordinating with local fire stations.',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // ✅ Nearby Stations Heading
  Widget _buildNearbyStationsHeading() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: const Text(
        'Nearby Fire Stations',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

  // ✅ Nearby Station Section
  Widget _buildNearbyStationSection(Map<String, String> contact) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_fire_department,
            color: Colors.red, size: 40),
        title: Text(contact['name']!,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            'Location: ${contact['location']}\nPhone: ${contact['phone']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: () => _makePhoneCall(contact['phone']!)),
            IconButton(
                icon: const Icon(Icons.map, color: Colors.blue),
                onPressed: () => _openMap(contact['location']!)),
          ],
        ),
      ),
    );
  }
}
