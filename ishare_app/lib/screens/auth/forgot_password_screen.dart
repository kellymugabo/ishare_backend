import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../constants/app_theme.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passController = TextEditingController();
  
  int _step = 1; // 1: Email, 2: OTP, 3: Password
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // Step 1: Send OTP
  Future<void> _requestOtp() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showMessage("Please enter a valid email.", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      await api.requestPasswordReset(_emailController.text.trim());
      
      setState(() {
        _isLoading = false;
        _step = 2; // Move to next step
      });
      _showMessage("Code sent! Check your email.");
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage("Failed to send code. Try again.", isError: true);
    }
  }

  // Step 2: Verify & Reset
  Future<void> _resetPassword() async {
    if (_codeController.text.length != 6) {
      _showMessage("Code must be 6 digits.", isError: true);
      return;
    }
    if (_passController.text.length < 8) {
      _showMessage("Password must be at least 8 chars.", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      await api.confirmPasswordReset(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
        newPassword: _passController.text,
      );

      if (mounted) {
        _showMessage("Success! Please login with your new password.");
        Navigator.pop(context); // Close screen
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage(e.toString().replaceAll("Exception: ", ""), isError: true);
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Recover Password"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.textDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Icon Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _step == 1 ? Icons.email_outlined : Icons.lock_reset_rounded,
                size: 50,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 30),

            // Step 1: Email Input
            if (_step == 1) ...[
              const Text(
                "Forgot Password?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Enter your email address to receive a 6-digit verification code.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              _buildInput(_emailController, "Email Address", Icons.email),
              const SizedBox(height: 20),
              _buildButton("Send Code", _requestOtp),
            ],

            // Step 2 & 3: Code + New Password
            if (_step == 2) ...[
              const Text(
                "Reset Password",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Enter the code sent to ${_emailController.text}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              _buildInput(_codeController, "6-Digit Code", Icons.numbers, isNumber: true),
              const SizedBox(height: 16),
              _buildInput(_passController, "New Password", Icons.lock_outline, isPass: true),
              const SizedBox(height: 20),
              _buildButton("Set New Password", _resetPassword),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool isPass = false, bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: isPass,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}