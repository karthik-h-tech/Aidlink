import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'address': TextEditingController(),
    'age': TextEditingController(),
    'bloodGroup': TextEditingController(),
    'height': TextEditingController(),
    'weight': TextEditingController(),
    'emergencyContact1Name': TextEditingController(),
    'emergencyContact1Relation': TextEditingController(),
    'emergencyContact1Phone': TextEditingController(),
    'emergencyContact2Name': TextEditingController(),
    'emergencyContact2Relation': TextEditingController(),
    'emergencyContact2Phone': TextEditingController(),
  };

  File? _imageFile;
  String? _profileImageUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _controllers['name']!.text = userDoc.data()?['name'] ?? '';
          _controllers['email']!.text = userDoc.data()?['email'] ?? '';
          _controllers['phone']!.text = userDoc.data()?['phone'] ?? '';
          _controllers['address']!.text = userDoc.data()?['address'] ?? '';
          _controllers['age']!.text = userDoc.data()?['age'] ?? '';
          _controllers['bloodGroup']!.text =
              userDoc.data()?['bloodGroup'] ?? '';
          _controllers['height']!.text = userDoc.data()?['height'] ?? '';
          _controllers['weight']!.text = userDoc.data()?['weight'] ?? '';
          _controllers['emergencyContact1Name']!.text =
              userDoc.data()?['emergencyContact1Name'] ?? '';
          _controllers['emergencyContact1Relation']!.text =
              userDoc.data()?['emergencyContact1Relation'] ?? '';
          _controllers['emergencyContact1Phone']!.text =
              userDoc.data()?['emergencyContact1Phone'] ?? '';
          _controllers['emergencyContact2Name']!.text =
              userDoc.data()?['emergencyContact2Name'] ?? '';
          _controllers['emergencyContact2Relation']!.text =
              userDoc.data()?['emergencyContact2Relation'] ?? '';
          _controllers['emergencyContact2Phone']!.text =
              userDoc.data()?['emergencyContact2Phone'] ?? '';
          _profileImageUrl = userDoc.data()?['profileImageUrl'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User profile not found.')));
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');
      await storageRef.putFile(_imageFile!);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profileImageUrl': downloadUrl,
      });

      setState(() {
        _profileImageUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile picture updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload profile picture')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                  ],
                ),
              ),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  _buildProfileForm(),
                  _buildQuickInfo(),
                  _buildEmergencyContacts(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_isEditing) {
            if (_formKey.currentState!.validate()) {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update({
                  'name': _controllers['name']!.text,
                  'email': _controllers['email']!.text,
                  'phone': _controllers['phone']!.text,
                  'address': _controllers['address']!.text,
                  'age': _controllers['age']!.text,
                  'bloodGroup': _controllers['bloodGroup']!.text,
                  'height': _controllers['height']!.text,
                  'weight': _controllers['weight']!.text,
                  'emergencyContact1Name':
                      _controllers['emergencyContact1Name']!.text,
                  'emergencyContact1Relation':
                      _controllers['emergencyContact1Relation']!.text,
                  'emergencyContact1Phone':
                      _controllers['emergencyContact1Phone']!.text,
                  'emergencyContact2Name':
                      _controllers['emergencyContact2Name']!.text,
                  'emergencyContact2Relation':
                      _controllers['emergencyContact2Relation']!.text,
                  'emergencyContact2Phone':
                      _controllers['emergencyContact2Phone']!.text,
                }).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Profile updated successfully')));
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Failed to update profile.')));
                });
              }
            } else {
              return;
            }
          }
          setState(() {
            _isEditing = !_isEditing;
          });
        },
        backgroundColor: const Color(0xFFE9A23B),
        child: Icon(_isEditing ? Icons.save : Icons.edit),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null
                      ? ClipOval(
                          child: Image.asset(
                            'assets/profile.jpg',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 60,
                                color: Color(0xFF1C4F3F),
                              );
                            },
                          ),
                        )
                      : null,
                ),
              ),
              if (_isEditing)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE9A23B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _controllers['name']!.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _controllers['email']!.text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Full Name',
              controller: _controllers['name']!,
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Email',
              controller: _controllers['email']!,
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Phone',
              controller: _controllers['phone']!,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Address',
              controller: _controllers['address']!,
              enabled: _isEditing,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Age',
            controller: _controllers['age']!,
            enabled: _isEditing,
          ),
          const SizedBox(height: 8),
          _buildTextField(
            label: 'Blood Group',
            controller: _controllers['bloodGroup']!,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Height',
            controller: _controllers['height']!,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Weight',
            controller: _controllers['weight']!,
            enabled: _isEditing,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Contacts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Emergency Contact 1 Name',
            controller: _controllers['emergencyContact1Name']!,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Emergency Contact 1 Relation',
            controller: _controllers['emergencyContact1Relation']!,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Emergency Contact 1 Phone',
            controller: _controllers['emergencyContact1Phone']!,
            enabled: _isEditing,
          ),
          const Divider(),
          _buildTextField(
            label: 'Emergency Contact 2 Name',
            controller: _controllers['emergencyContact2Name']!,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Emergency Contact 2 Relation',
            controller: _controllers['emergencyContact2Relation']!,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Emergency Contact 2 Phone',
            controller: _controllers['emergencyContact2Phone']!,
            enabled: _isEditing,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact({
    required String name,
    required String relation,
    required String phone,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF1C4F3F),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  relation,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            color: const Color(0xFF1C4F3F),
            onPressed: () async {
              // Handle phone call
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(Icons.person, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      validator: validator,
    );
  }
}
