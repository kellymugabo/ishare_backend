import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 👈 Required for Web
import 'dart:io'; 
import '../../services/api_service.dart';
import '../../models/user_model.dart';
import '../../constants/app_theme.dart';

final userProfileProvider = FutureProvider.autoDispose<UserProfileModel>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.fetchMyProfile();
});

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehiclePlateController = TextEditingController();

  XFile? _profileImage;
  XFile? _vehicleImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _initializeControllers(UserProfileModel profile) {
    if (_firstNameController.text.isEmpty) {
      _firstNameController.text = profile.user.firstName ?? '';
      _lastNameController.text = profile.user.lastName ?? '';
      _phoneController.text = profile.phoneNumber ?? '';
      _bioController.text = profile.bio ?? '';
      _vehicleModelController.text = profile.vehicleModel ?? '';
      _vehiclePlateController.text = profile.vehiclePlateNumber ?? '';
    }
  }

  // ✅ HELPER: Force HTTPS to prevent connection errors
  String _getValidUrl(String url) {
    if (url.startsWith('http')) {
      if (url.contains('127.0.0.1') || url.contains('localhost')) {
        return url;
      }
      return url.replaceFirst('http://', 'https://');
    }
    return url.startsWith('/') ? "http://127.0.0.1:8000$url" : "http://127.0.0.1:8000/$url";
  }

  Future<void> _pickImage({required bool isProfile}) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _profileImage = pickedFile;
        } else {
          _vehicleImage = pickedFile;
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 1. Auto-Fix Phone Number
      String phone = _phoneController.text.trim();
      if (phone.startsWith('07')) phone = '+250${phone.substring(1)}';
      else if (phone.startsWith('7')) phone = '+250$phone';

      // 2. Prepare Data
      final Map<String, dynamic> updateData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'phone_number': phone,
        'bio': _bioController.text,
        'vehicle_model': _vehicleModelController.text,
        'vehicle_plate_number': _vehiclePlateController.text,
        'profile_picture': _profileImage, 
        'vehicle_photo': _vehicleImage,   
      };

      // 3. Send to API
      await ref.read(apiServiceProvider).updateProfile(updateData);
      ref.invalidate(userProfileProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.surfaceGrey,
      appBar: AppBar(title: const Text('Edit Profile', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: profileAsync.when(
        data: (profile) {
          _initializeControllers(profile);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Profile Pic (Fixed for Crashes) ---
                  Center(
                    child: GestureDetector(
                      onTap: () => _pickImage(isProfile: true),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        // Use child with ClipOval to handle errors safely
                        child: ClipOval(
                          child: SizedBox(
                            width: 100, height: 100,
                            child: _buildProfileImageWidget(_profileImage, profile.profilePicture),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(_firstNameController, "First Name", Icons.person),
                  _buildTextField(_lastNameController, "Last Name", Icons.person),
                  _buildTextField(_phoneController, "Phone (+250...)", Icons.phone),
                  _buildTextField(_bioController, "Bio", Icons.info),

                  const SizedBox(height: 30),
                  const Text("Vehicle Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  _buildTextField(_vehicleModelController, "Car Model", Icons.directions_car),
                  _buildTextField(_vehiclePlateController, "Plate Number", Icons.confirmation_number),

                  const SizedBox(height: 15),
                  
                  // --- Car Photo Upload Box (Fixed for Crashes) ---
                  GestureDetector(
                    onTap: () => _pickImage(isProfile: false),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                        // REMOVED 'image: DecorationImage' because it crashes on 404
                      ),
                      // ADDED ClipRRect to contain the image cleanly
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _buildVehicleImageWidget(_vehicleImage, profile.vehiclePhoto),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Changes"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }

  // ✅ WIDGET BUILDER: Handles Local File vs Network URL vs 404 Error (Profile)
  Widget _buildProfileImageWidget(XFile? localFile, String? remoteUrl) {
    if (localFile != null) {
      if (kIsWeb) return Image.network(localFile.path, fit: BoxFit.cover);
      return Image.file(File(localFile.path), fit: BoxFit.cover);
    }
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return Image.network(
        _getValidUrl(remoteUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, size: 50, color: Colors.grey);
        },
      );
    }
    return const Icon(Icons.camera_alt, size: 30, color: Colors.grey);
  }

  // ✅ WIDGET BUILDER: Handles Local File vs Network URL vs 404 Error (Vehicle)
  Widget _buildVehicleImageWidget(XFile? localFile, String? remoteUrl) {
    // 1. Show Local File if selected
    if (localFile != null) {
      if (kIsWeb) return Image.network(localFile.path, fit: BoxFit.cover);
      return Image.file(File(localFile.path), fit: BoxFit.cover);
    }
    // 2. Show Remote URL if exists (With Error Handling)
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return Image.network(
        _getValidUrl(remoteUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // If 404, show the upload placeholder
          return _buildUploadPlaceholder();
        },
      );
    }
    // 3. Default Placeholder
    return _buildUploadPlaceholder();
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
        Text("Tap to upload car photo", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}