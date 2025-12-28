import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



// Provider to track if user is verified
final userVerifiedProvider = StateProvider<bool>((ref) => false);

// Provider to store verification data
final verificationDataProvider = StateProvider<Map<String, String>?>((ref) => null);

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _isVerifying = false;
  String _selectedIdType = 'National ID';

  @override
  void dispose() {
    _idNumberController.dispose();
    _phoneController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  // Validate Rwanda National ID (16 digits)
  bool _isValidRwandaID(String id) {
    // Rwanda National ID format: 1 YYYY M MMM DD NNNNN C
    // Example: 1199780123456789 (16 digits)
    if (id.length != 16) return false;
    if (!RegExp(r'^[0-9]{16}$').hasMatch(id)) return false;
    
    // First digit should be 1 (Rwandan citizen)
    if (!id.startsWith('1')) return false;
    
    // Extract and validate year (positions 2-5)
    int year = int.tryParse(id.substring(1, 5)) ?? 0;
    if (year < 1900 || year > DateTime.now().year) return false;
    
    return true;
  }

  // Validate Rwanda Passport (8 characters)
  bool _isValidRwandaPassport(String passport) {
    // Rwanda passport format: PC followed by 6 digits
    // Example: PC123456
    if (passport.length != 8) return false;
    if (!RegExp(r'^PC[0-9]{6}$', caseSensitive: false).hasMatch(passport)) return false;
    return true;
  }

  // Validate Rwanda phone number
  bool _isValidRwandaPhone(String phone) {
    // Remove spaces and special characters
    phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Rwanda phone formats:
    // 07XX XXX XXX (10 digits starting with 07)
    // +25078XXXXXXX (international format)
    // 25078XXXXXXX (without +)
    
    if (phone.startsWith('+250')) {
      phone = phone.substring(4);
    } else if (phone.startsWith('250')) {
      phone = phone.substring(3);
    }
    
    // Should be 10 digits starting with 07
    if (!RegExp(r'^07[0-9]{8}$').hasMatch(phone)) return false;
    
    // Valid prefixes: 072, 073, 078, 079 (MTN), 075 (Airtel)
    List<String> validPrefixes = ['072', '073', '078', '079', '075'];
    String prefix = phone.substring(0, 3);
    
    return validPrefixes.contains(prefix);
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isVerifying = true);

    try {
      final idNumber = _idNumberController.text.trim();
      final phone = _phoneController.text.trim();
      final fullName = _fullNameController.text.trim();

     
      final result = await _verifyWithNIDA(
        idType: _selectedIdType,
        idNumber: idNumber,
        phone: phone,
        fullName: fullName,
      );

      if (result['success']) {
        // Store verification data
        ref.read(verificationDataProvider.notifier).state = {
          'idType': _selectedIdType,
          'idNumber': idNumber,
          'phone': phone,
          'fullName': fullName,
          'verifiedAt': DateTime.now().toIso8601String(),
        };

        // Update verification status
        ref.read(userVerifiedProvider.notifier).state = true;

        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        throw Exception(result['message'] ?? 'Verification failed');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  // Simulate NIDA verification - Replace with actual API
  Future<Map<String, dynamic>> _verifyWithNIDA({
    required String idType,
    required String idNumber,
    required String phone,
    required String fullName,
  }) async {
    
    // Example endpoint: https://nida.gov.rw/api/verify
    
    /*
    final response = await http.post(
      Uri.parse('https://your-backend.com/verify-id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_type': idType,
        'id_number': idNumber,
        'phone': phone,
        'full_name': fullName,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': data['verified'],
        'message': data['message'],
        'userData': data['user_data'],
      };
    }
    */

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 3));

    // Simulate verification logic
    bool isValid = false;
    
    if (idType == 'National ID') {
      isValid = _isValidRwandaID(idNumber);
    } else {
      isValid = _isValidRwandaPassport(idNumber);
    }

    if (!isValid) {
      return {
        'success': false,
        'message': 'Invalid $idType format. Please check and try again.',
      };
    }

    // Simulate successful verification
    return {
      'success': true,
      'message': 'Account verified successfully',
      'userData': {
        'name': fullName,
        'id': idNumber,
      },
    };
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 64),
            const SizedBox(height: 16),
            const Text('Verification Successful!'),
          ],
        ),
        content: const Text(
          'Your account has been verified. You can now make payments.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600], size: 32),
            const SizedBox(width: 12),
            const Text('Verification Failed'),
          ],
        ),
        content: Text(message.replaceAll('Exception: ', '')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Verification'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified_user,
                        size: 60,
                        color: Colors.orange[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Verify Your Identity',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Secure your account with Rwanda ID verification',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ID Type Selection
              const Text(
                'ID Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildIdTypeOption('National ID', Icons.credit_card),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildIdTypeOption('Passport', Icons.book),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Full Name
              TextFormField(
                controller: _fullNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'As shown on your ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  if (value.trim().split(' ').length < 2) {
                    return 'Please enter your full name (first and last name)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ID Number
              TextFormField(
                controller: _idNumberController,
                decoration: InputDecoration(
                  labelText: _selectedIdType == 'National ID' 
                      ? 'National ID Number' 
                      : 'Passport Number',
                  hintText: _selectedIdType == 'National ID'
                      ? '1199780123456789 (16 digits)'
                      : 'PC123456',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.badge),
                  helperText: _selectedIdType == 'National ID'
                      ? '16-digit Rwanda National ID'
                      : '8-character Passport (PC + 6 digits)',
                ),
                keyboardType: _selectedIdType == 'National ID'
                    ? TextInputType.number
                    : TextInputType.text,
                inputFormatters: _selectedIdType == 'National ID'
                    ? [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ]
                    : [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                        LengthLimitingTextInputFormatter(8),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          return TextEditingValue(
                            text: newValue.text.toUpperCase(),
                            selection: newValue.selection,
                          );
                        }),
                      ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your ${_selectedIdType == 'National ID' ? 'ID' : 'passport'} number';
                  }

                  if (_selectedIdType == 'National ID') {
                    if (!_isValidRwandaID(value)) {
                      return 'Invalid Rwanda National ID format (16 digits starting with 1)';
                    }
                  } else {
                    if (!_isValidRwandaPassport(value)) {
                      return 'Invalid passport format (PC followed by 6 digits)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '078 123 4567',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                  prefixText: '+250 ',
                  helperText: 'MTN or Airtel number',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!_isValidRwandaPhone(value)) {
                    return 'Invalid Rwanda phone number (07X XXX XXXX)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your information will be verified with NIDA (National ID Agency). This process is secure and your data is protected.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _submitVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Verify Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdTypeOption(String type, IconData icon) {
    final isSelected = _selectedIdType == type;
    return InkWell(
      onTap: () => setState(() {
        _selectedIdType = type;
        _idNumberController.clear();
      }),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.orange[700]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.orange[50] : Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.orange[700] : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.orange[700] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}