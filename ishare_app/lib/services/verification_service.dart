import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;


class VerificationService {
  final String baseUrl;
  final String authToken;

  VerificationService({
    required this.baseUrl,
    required this.authToken,
  });

  // Headers for authenticated requests
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

  /// Upload National ID documents
  Future<Map<String, dynamic>> uploadNationalId({
    required String userId,
    required File frontImage,
    required File backImage,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/verification/national-id'),
      );

      request.headers['Authorization'] = 'Bearer $authToken';
      request.fields['userId'] = userId;

      // Add front image
      request.files.add(await http.MultipartFile.fromPath(
        'frontImage',
        frontImage.path,
        filename: 'national_id_front_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

      // Add back image
      request.files.add(await http.MultipartFile.fromPath(
        'backImage',
        backImage.path,
        filename: 'national_id_back_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': json.decode(responseData),
          'message': 'National ID uploaded successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to upload National ID',
          'error': responseData,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error uploading National ID',
        'error': e.toString(),
      };
    }
  }

  /// Get verification status for a user
  Future<Map<String, dynamic>> getVerificationStatus(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/verification/status/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch verification status',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching verification status',
        'error': e.toString(),
      };
    }
  }
}