import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint; // For debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/trip_model.dart';
import '../models/booking_model.dart';
import '../models/subscription_model.dart';

// ⚠️ NETWORK CONFIGURATION

const String baseUrl = "https://amiable-amazement-production-4d09.up.railway.app";

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isRefreshing = false; 

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    
    // Web-specific configuration for CORS
    if (kIsWeb) {
      _dio.options.headers['Content-Type'] = 'application/json';
      _dio.options.headers['Accept'] = 'application/json';
    }
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint('🔑 Token attached to request: ${options.uri}');
        } else {
          debugPrint('⚠️ No token found - proceeding without auth: ${options.uri}');
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Better error logging for web CORS issues
        if (kIsWeb && e.type == DioExceptionType.connectionError) {
          debugPrint('❌ CORS/Network Error: ${e.message}');
          debugPrint('   This is likely a CORS configuration issue on the backend.');
          debugPrint('   Backend URL: ${e.requestOptions.uri}');
        } else {
          debugPrint('❌ API Error: ${e.response?.statusCode} - ${e.message}');
        }
        
        if (e.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          debugPrint('🔄 Attempting token refresh...');
          
          try {
            final refreshed = await _refreshToken();
            if (refreshed) {
              try {
                final token = await _storage.read(key: 'access_token');
                e.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await _dio.fetch(e.requestOptions);
                return handler.resolve(response);
              } catch (retryError) {
                return handler.next(e);
              }
            } else {
              await logout();
              return handler.next(e);
            }
          } finally {
            _isRefreshing = false;
          }
        }
        return handler.next(e);
      },
    ));
  } 

  // =====================================================
  // 1. AUTHENTICATION & PASSWORD RESET
  // =====================================================

  // ✅ Login
  Future<Response> login({
    required String username, 
    required String password,
    required String role, 
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/token/', 
        data: {
          'username': username, 
          'password': password,
          'role': role 
        },
      );

      if (response.statusCode == 200) {
        await _storage.write(key: 'access_token', value: response.data['access']);
        await _storage.write(key: 'refresh_token', value: response.data['refresh']);
        await _storage.write(key: 'user_role', value: role); 
        debugPrint('✅ Login successful (Token & Role Saved)');
      }
      return response; 
    } catch (e) {
      debugPrint('❌ Login failed: $e');
      rethrow;
    }
  }

  // ✅ Register
  Future<void> register({
    required String username,
    required String password,
    required String email,
    required String role,
    String? firstName,
    String? lastName,
    String? vehicleModel,
    String? plateNumber,
    XFile? vehiclePhoto, 
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'username': username,
        'password': password,
        'password2': password,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
      };

      if (role == 'driver') {
        if (vehicleModel != null) dataMap['vehicle_model'] = vehicleModel;
        if (plateNumber != null) dataMap['plate_number'] = plateNumber;
      }

      final formData = FormData.fromMap(dataMap);

      if (vehiclePhoto != null) {
        final bytes = await vehiclePhoto.readAsBytes();
        formData.files.add(MapEntry(
          'vehicle_photo', 
          MultipartFile.fromBytes(bytes, filename: vehiclePhoto.name),
        ));
      }

      final response = await _dio.post(
        '/api/register/', 
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 201) {
        debugPrint('✅ Registration successful');
      }
    } catch (e) {
      debugPrint('❌ Registration failed: $e');
      if (e is DioException && e.response != null) {
        throw Exception('Registration failed: ${e.response?.data}');
      }
      rethrow;
    }
  }

  // ✅ Request OTP (Forgot Password)
  Future<void> requestPasswordReset(String email) async {
    try {
      await _dio.post(
        '/api/auth/forgot-password/', 
        data: {'email': email}
      );
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) return;
      rethrow;
    }
  }

  // ✅ Confirm Password Reset
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/api/auth/reset-password/', 
        data: {
          'email': email,
          'code': code,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response?.data['error'] ?? "Reset failed");
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_role');
    _isRefreshing = false;
    debugPrint('✅ Logged out - tokens cleared');
  }
  
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;
      
      final refreshDio = Dio();
      refreshDio.options.baseUrl = baseUrl;
      
      final response = await refreshDio.post(
        '/api/auth/token/refresh/', 
        data: {'refresh': refreshToken},
      );
      
      if (response.statusCode == 200) {
        await _storage.write(key: 'access_token', value: response.data['access']);
        if (response.data.containsKey('refresh')) {
          await _storage.write(key: 'refresh_token', value: response.data['refresh']);
        }
        return true;
      }
    } catch (e) {
      debugPrint('❌ Token refresh error: $e');
    }
    return false;
  }

  // =====================================================
  // 2. TRIPS & BOOKINGS
  // =====================================================

  Future<List<TripModel>> fetchTrips() async {
    try {
      final response = await _dio.get('/api/trips/');
      final List<dynamic> data = response.data;
      return data.map((trip) => TripModel.fromJson(trip)).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch trips: $e');
      rethrow;
    }
  }

  Future<List<TripModel>> getMyTrips() async {
    try {
      final response = await _dio.get('/api/trips/my_trips/');
      final List<dynamic> data = response.data;
      return data.map((json) => TripModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching my trips: $e');
      rethrow;
    }
  }

  Future<List<BookingModel>> fetchMyBookings() async {
    try {
      final response = await _dio.get('/api/bookings/my_tickets/');
      final List<dynamic> data = response.data;
      return data.map((booking) => BookingModel.fromJson(booking)).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch bookings: $e');
      rethrow;
    }
  }

  Future<List<BookingModel>> getUserBookings() async {
    return fetchMyBookings();
  }

  // =====================================================
  // 3. DRIVER REQUESTS
  // =====================================================

  Future<List<BookingModel>> getDriverRequests() async {
    try {
      final response = await _dio.get('/api/bookings/driver-requests/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => BookingModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load requests");
      }
    } catch (e) {
      throw Exception("Error fetching requests: $e");
    }
  }

  Future<void> approveBooking(int bookingId) async {
    try {
      await _dio.post('/api/bookings/$bookingId/approve/');
    } catch (e) {
      throw Exception("Failed to approve: $e");
    }
  }

  Future<void> rejectBooking(int bookingId) async {
    try {
      await _dio.post('/api/bookings/$bookingId/reject/');
    } catch (e) {
      throw Exception("Failed to reject: $e");
    }
  }

  // =====================================================
  // 4. USER PROFILE & VERIFICATION
  // =====================================================
  Future<UserProfileModel> fetchMyProfile() async {
    try {
      final response = await _dio.get('/api/profiles/me/');
      return UserProfileModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfileModel> getUserProfile(int userId) async {
    try {
      final response = await _dio.get('/api/profiles/user_profile/?user_id=$userId');
      return UserProfileModel.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ Failed to fetch user profile: $e');
      rethrow;
    }
  }

  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final formMap = <String, dynamic>{};
      if (data['bio'] != null) formMap['bio'] = data['bio'];
      if (data['first_name'] != null) formMap['first_name'] = data['first_name'];
      if (data['last_name'] != null) formMap['last_name'] = data['last_name'];
      if (data['phone_number'] != null) formMap['phone_number'] = data['phone_number'];
      if (data['vehicle_plate_number'] != null) formMap['vehicle_plate_number'] = data['vehicle_plate_number'];
      if (data['vehicle_model'] != null) formMap['vehicle_model'] = data['vehicle_model'];

      final formData = FormData.fromMap(formMap);

      if (data['profile_picture'] != null && data['profile_picture'] is XFile) {
        final XFile file = data['profile_picture'];
        final List<int> bytes = await file.readAsBytes();
        formData.files.add(MapEntry('profile_picture', MultipartFile.fromBytes(bytes, filename: file.name)));
      }

      if (data['vehicle_photo'] != null && data['vehicle_photo'] is XFile) {
        final XFile file = data['vehicle_photo'];
        final List<int> bytes = await file.readAsBytes();
        formData.files.add(MapEntry('vehicle_photo', MultipartFile.fromBytes(bytes, filename: file.name)));
      }

      final response = await _dio.patch(
        '/api/profiles/me/',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return UserProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ UPDATE PROFILE ERROR: ${e.response?.data}');
      if (e.response?.data != null) {
        throw Exception(e.response?.data.toString());
      }
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      rethrow;
    }
  }

  // ✅ UPDATED: Handles File Uploads for Verification Correctly
  Future<void> submitDriverVerification(Map<String, dynamic> data) async {
    try {
      final formData = FormData();

      // Loop through all data to handle both Text and Files
      for (var entry in data.entries) {
        if (entry.value is XFile) {
          // If it is a File (Image), prepare it for upload
          final XFile file = entry.value;
          final bytes = await file.readAsBytes();
          formData.files.add(MapEntry(
            entry.key,
            MultipartFile.fromBytes(bytes, filename: file.name),
          ));
        } else if (entry.value != null) {
          // If it is just Text, send as string
          formData.fields.add(MapEntry(entry.key, entry.value.toString()));
        }
      }

      await _dio.post(
        '/api/driver/verify/', 
        data: formData,
        // options: Options(contentType: 'multipart/form-data'), // Dio does this automatically with FormData
      );
      
      debugPrint('✅ Verification submitted successfully');
    } catch (e) {
      debugPrint('❌ Verification Failed: $e');
      if (e is DioException && e.response != null) {
        debugPrint('Server Reason: ${e.response?.data}');
        throw Exception(e.response?.data.toString());
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkDriverVerification() async {
    try {
      final response = await _dio.get('/api/driver/verification-status/');
      final data = response.data ?? {};
      
      // Debug: Log the raw backend response
      debugPrint('📡 Raw Backend Response: $data');
      debugPrint('   - is_verified: ${data['is_verified']} (${data['is_verified'].runtimeType})');
      debugPrint('   - status: ${data['status']} (${data['status']?.runtimeType})');
      
      // Get status as string (handle both string and enum cases)
      final statusStr = data['status']?.toString().toLowerCase();
      final isVerified = data['is_verified'] == true || 
                         data['is_verified'] == 'true' || 
                         statusStr == 'approved';
      
      // Normalize the response to handle different backend formats
      final normalized = {
        'is_verified': isVerified,
        'status': statusStr ?? (isVerified ? 'approved' : 'none'),
        'has_pending': statusStr == 'pending',
        // Keep all original fields
      };
      
      // Add original data for backward compatibility (without overwriting normalized values)
      data.forEach((key, value) {
        if (!normalized.containsKey(key)) {
          normalized[key] = value;
        }
      });
      
      debugPrint('📦 Normalized Response: $normalized');
      
      return normalized;
    } catch (e) {
      debugPrint('❌ Error checking driver verification status: $e');
      rethrow;
    }
  }

  Future<bool> isDriverVerified() async {
    try {
      final response = await _dio.get('/api/driver/verification-status/');
      if (response.data != null) {
        final data = response.data;
        
        // Get status as string (handle both string and enum cases)
        final statusStr = data['status']?.toString().toLowerCase();
        
        // Check multiple possible formats from backend
        final isVerified = data['is_verified'] == true || 
                          data['is_verified'] == 'true' ||
                          statusStr == 'approved' ||
                          data['verification_status']?.toString().toLowerCase() == 'approved';
        
        if (isVerified) {
          debugPrint('✅ Driver is verified (status: $statusStr, is_verified: ${data['is_verified']})');
          return true;
        }
        debugPrint('⚠️ Driver verification status: ${statusStr ?? data['is_verified'] ?? 'unknown'}');
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error checking driver verification: $e');
      return false;
    }
  }

  // =====================================================
  // 5. CREATE, RATE & PAYMENTS
  // =====================================================

  Future<TripModel> createTrip(Map<String, dynamic> tripData) async {
    try {
      final response = await _dio.post('/api/trips/', data: tripData);
      return TripModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<BookingModel> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await _dio.post('/api/bookings/', data: bookingData);
      return BookingModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BookingModel>> getBookingsForTrip(int tripId) async {
    try {
      final response = await _dio.get('/api/bookings/?trip_id=$tripId');
      final List<dynamic> data = response.data;
      return data.map((json) => BookingModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch trip bookings: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> simulatePayment({
    required int bookingId,
    required double amount,
    String? phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/api/payments/',
        data: {
          'booking': bookingId,
          'amount': amount.toString(),
          'payment_method': 'mobile_money',
          'phone_number': phoneNumber,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint("❌ PAYMENT FAILED - SERVER SAYS: ${e.response?.data}");
      } else {
        debugPrint("❌ PAYMENT FAILED - ${e.message}");
      }
      rethrow;
    }
  }

  // ✅ Rate Driver
  Future<void> rateDriver({
    required int tripId,
    required int driverId,
    required double rating,
    required String comment,
  }) async {
    try {
      final data = {
        'trip': tripId,      
        'ratee_id': driverId,   
        'score': rating, 
        'comment': comment,
      };

      debugPrint('📤 Sending Rating Data: $data');

      await _dio.post('/api/ratings/', data: data);
      debugPrint('✅ Rating submitted successfully');
    } catch (e) {
      debugPrint('❌ Failed to submit rating: $e');
      if (e is DioException) {
        debugPrint('Server Response: ${e.response?.data}');
      }
      rethrow;
    }
  }

  // =====================================================
  // SUBSCRIPTION METHODS
  // =====================================================

  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      final response = await _dio.get('/api/subscription/status/');
      return response.data;
    } catch (e) {
      debugPrint('❌ Failed to get subscription status: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkSubscriptionAccess() async {
    try {
      final response = await _dio.get('/api/subscription/check/');
      return response.data;
    } catch (e) {
      debugPrint('❌ Failed to check subscription access: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> processSubscriptionPayment({
    required String phoneNumber,
    String paymentMethod = 'mobile_money',
  }) async {
    try {
      final response = await _dio.post(
        '/api/subscription/pay/',
        data: {
          'phone_number': phoneNumber,
          'payment_method': paymentMethod,
        },
      );
      debugPrint('✅ Subscription payment processed');
      return response.data;
    } catch (e) {
      debugPrint('❌ Failed to process subscription payment: $e');
      if (e is DioException && e.response != null) {
        debugPrint('Server Response: ${e.response?.data}');
      }
      rethrow;
    }
  }
} // ⬅️ 🛑 IMPORTANT: This closing brace ends the ApiService class!

// =====================================================
// ✅ RIVERPOD PROVIDERS (MUST BE OUTSIDE THE CLASS)
// =====================================================

final apiServiceProvider = Provider((ref) => ApiService());

final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.isLoggedIn();
});

final tripsProvider = FutureProvider<List<TripModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.fetchTrips();
});

final myTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getMyTrips(); 
});

final bookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.fetchMyBookings();
});

final userProfileProvider = FutureProvider.autoDispose<UserProfileModel>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.fetchMyProfile();
});

// =====================================================
// SUBSCRIPTION METHODS
// =====================================================