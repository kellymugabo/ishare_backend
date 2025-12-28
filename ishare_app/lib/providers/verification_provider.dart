// lib/providers/verification_provider.dart
import 'dart:io'; // <--- ADDED: Necessary for the 'File' class
import 'package:flutter/foundation.dart'; // Contains 'ChangeNotifier' and 'debugPrint'
import '../services/verification_service.dart';
import '../models/verification_model.dart';

class VerificationProvider with ChangeNotifier {
  final VerificationService _service;
  VerificationModel? _verification;
  bool _isLoading = false;

  VerificationProvider(this._service);

  VerificationModel? get verification => _verification;
  bool get isLoading => _isLoading;

  Future<void> loadVerificationStatus(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _service.getVerificationStatus(userId);
      if (result['success']) {
        _verification = VerificationModel.fromJson(result['data']);
      }
    } catch (e) {
      // CHANGED: debugPrint is better than print for Flutter apps
      debugPrint('Error loading verification: $e'); 
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> submitNationalId(
    String userId,
    File frontImage,
    File backImage,
  ) async {
    return await _service.uploadNationalId(
      userId: userId,
      frontImage: frontImage,
      backImage: backImage,
    );
  }
}