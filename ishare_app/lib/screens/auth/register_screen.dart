import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ishare_app/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart'; 

import '../../services/api_service.dart';
import '../../constants/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
  // Driver specific controllers
  final _vehicleModelController = TextEditingController();
  final _plateNumberController = TextEditingController();
  
  // Image handling
  XFile? _vehiclePhoto; 
  Uint8List? _vehiclePhotoBytes;
  final ImagePicker _picker = ImagePicker();

  // State variables
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isDriver = false; 

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _vehicleModelController.dispose();
    _plateNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickVehiclePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes(); 
        setState(() {
          _vehiclePhoto = image;       
          _vehiclePhotoBytes = bytes;  
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  bool _isPasswordValid(String password) {
    bool hasMinLength = password.length >= 8;
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    return hasMinLength && hasDigit;
  }

  Future<void> _register() async {
    // 1. Validation
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _firstNameController.text.isEmpty) {
      _showError("Please fill in all required fields");
      return;
    }

    if (!_isPasswordValid(_passwordController.text)) {
      _showError("Password must be 8+ chars and include a number");
      return;
    }

    if (_isDriver) {
      if (_vehicleModelController.text.isEmpty ||
          _plateNumberController.text.isEmpty) {
        _showError("Drivers must provide vehicle details");
        return;
      }
      if (_vehiclePhoto == null) {
        _showError("Drivers must upload a vehicle photo");
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // 2. Prepare Data
      final Map<String, dynamic> formMap = {
        "username": _usernameController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text,
        "password2": _passwordController.text, 
        "first_name": _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "role": _isDriver ? "driver" : "passenger",
      };

      if (_isDriver) {
        formMap["vehicle_model"] = _vehicleModelController.text.trim();
        formMap["plate_number"] = _plateNumberController.text.trim();
      }

      final formData = FormData.fromMap(formMap);

      // 3. Attach Photo
      if (_isDriver && _vehiclePhoto != null) {
        final bytes = await _vehiclePhoto!.readAsBytes();
        formData.files.add(MapEntry(
          "vehicle_photo",
          MultipartFile.fromBytes(
            bytes,
            filename: "vehicle_photo.jpg",
          ),
        ));
      }

      // 4. API Call - Register
      await ref.read(apiServiceProvider).register(formData);

      if (mounted) {
        // --- AUTO LOGIN LOGIC ---
        try {
          // Attempt to login immediately using the credentials provided
          await ref.read(apiServiceProvider).login(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            role: _isDriver ? "driver" : "passenger",
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Welcome to ISHARE! Registration complete."),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to Home and clear the navigation stack
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
        } catch (loginError) {
          debugPrint("Auto-login failed: $loginError");
          // If login fails, we send them back to login screen normally
          if (mounted) {
            Navigator.pop(context);
          }
        }
      }

    } on DioException catch (e) {
      debugPrint("❌ SERVER ERROR DETAILS: ${e.response?.data}");
      String message = "Registration failed";
      final data = e.response?.data;
      
      if (data is Map<String, dynamic>) {
        if (data.containsKey('detail')) message = data['detail'];
        else if (data.containsKey('message')) message = data['message'];
        else if (data.containsKey('error')) message = data['error'];
        else if (data.isNotEmpty) {
           final firstKey = data.keys.first;
           final firstError = data[firstKey];
           message = firstError is List ? "$firstKey: ${firstError[0]}" : "$firstKey: $firstError";
        }
      }
      _showError(message);
    } catch (e) {
      debugPrint("❌ UNKNOWN ERROR: $e");
      _showError("An unexpected error occurred.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.createAccount),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryBlue),
        titleTextStyle: const TextStyle(
            color: AppTheme.primaryBlue, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.joinIshare,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryBlue,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Create an account to start your journey.",
                style: TextStyle(color: Colors.grey[500], fontSize: 15),
              ),
              
              const SizedBox(height: 25),
              _buildRoleSelector(),
              const SizedBox(height: 25),

              _buildGlassInput(
                controller: _firstNameController, 
                label: l10n.firstName,
                icon: Icons.person_outline_rounded
              ),
              const SizedBox(height: 16),
              
              _buildGlassInput(
                controller: _lastNameController, 
                label: l10n.lastNameOptional,
                icon: Icons.person_outline_rounded
              ),
              const SizedBox(height: 16),
              
              AnimatedCrossFade(
                firstChild: Container(), 
                secondChild: Column(
                  children: [
                    _buildGlassInput(
                      controller: _vehicleModelController,
                      label: "Vehicle Model (e.g. Toyota Corolla)",
                      icon: Icons.directions_car_filled_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildGlassInput(
                      controller: _plateNumberController,
                      label: "Plate Number (e.g. RAA 123 A)",
                      icon: Icons.pin_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildPhotoPicker(),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[200], thickness: 1, height: 30),
                  ],
                ),
                crossFadeState: _isDriver ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),

              _buildGlassInput(
                controller: _emailController, 
                label: l10n.emailAddress,
                icon: Icons.email_outlined, 
                type: TextInputType.emailAddress
              ),
              const SizedBox(height: 16),
              
              _buildGlassInput(
                controller: _usernameController, 
                label: l10n.username,
                icon: Icons.account_circle_outlined
              ),
              const SizedBox(height: 16),
              
              _buildGlassInput(
                controller: _passwordController, 
                label: l10n.password,
                icon: Icons.lock_outline_rounded, 
                isPassword: true
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  "Min 8 chars, at least 1 number", 
                  style: TextStyle(color: Colors.grey[400], fontSize: 12)
                ),
              ),
              
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 8,
                    shadowColor: AppTheme.primaryBlue.withOpacity(0.4),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24, height: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                        )
                      : Text(
                          "${l10n.registerAction} (${_isDriver ? 'Driver' : 'Passenger'})",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: _pickVehiclePhoto,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        ),
        child: _vehiclePhotoBytes == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_rounded, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  "Upload Vehicle Photo",
                  style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
                ),
              ],
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                _vehiclePhotoBytes!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedAlign(
                alignment: _isDriver ? Alignment.centerRight : Alignment.centerLeft,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Container(
                  width: constraints.maxWidth / 2,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isDriver = false),
                      behavior: HitTestBehavior.translucent,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: !_isDriver ? AppTheme.primaryBlue : Colors.grey[500],
                          ),
                          child: const Text("Passenger"),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isDriver = true),
                      behavior: HitTestBehavior.translucent,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _isDriver ? AppTheme.primaryBlue : Colors.grey[500],
                          ),
                          child: const Text("Driver"),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: type,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: AppTheme.primaryBlue.withOpacity(0.7)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    color: Colors.grey[400],
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}