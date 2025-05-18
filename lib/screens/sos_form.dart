import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SOSForm extends StatefulWidget {
  final Position? currentPosition;
  final Map<String, String>? nearestFireStation;

  const SOSForm({super.key, this.currentPosition, this.nearestFireStation});

  @override
  State<SOSForm> createState() => _SOSFormState();
}

class _SOSFormState extends State<SOSForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emergencyController = TextEditingController();
  bool _isLoading = false;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate form submission delay
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isLoading = false);

        Fluttertoast.showToast(
          msg: "🚨 SOS Request Submitted!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );

        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🔥 SOS Request Form",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),

            // User's name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 12),

            // Emergency description field
            TextFormField(
              controller: _emergencyController,
              decoration: const InputDecoration(
                labelText: 'Describe Emergency',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warning),
              ),
              maxLines: 3,
              validator: (value) =>
                  value!.isEmpty ? 'Please describe the emergency' : null,
            ),
            const SizedBox(height: 20),

            // Display location info
            if (widget.currentPosition != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "📍 Current Location:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Latitude: ${widget.currentPosition?.latitude}, Longitude: ${widget.currentPosition?.longitude}",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                ],
              ),

            if (widget.nearestFireStation != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "🚒 Nearest Fire Station:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${widget.nearestFireStation?['name']}, ${widget.nearestFireStation?['distance']} km away",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Submit button with loading indicator
            _isLoading
                ? Center(
                    child: SpinKitWave(
                      color: Colors.red,
                      size: 40.0,
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.send),
                    label: const Text(
                      "Submit SOS Request",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
