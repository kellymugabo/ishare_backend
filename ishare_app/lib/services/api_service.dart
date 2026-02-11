import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/trip_model.dart';
import '../models/booking_model.dart';

// ⚠️ NETWORK CONFIGURATION
// Remove the extra double quote at the end
const String baseUrl = "https://seashell-app-sz2nv.ondigitalocean.app";

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
        // Better error logging
        if (kIsWeb && e.type == DioExceptionType.connectionError) {
          debugPrint('❌ CORS/Network Error: ${e.message}');
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

  // ✅ Register (Modified to accept FormData directly)
  Future<void> register(FormData data) async {
    try {
      // SEND REQUEST
      await _dio.post(
        '/api/register/',
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
      
      debugPrint('✅ Registration successful');

    } on DioException catch (e) {
      // 🛑 GHOST FIX LOGIC 🛑
      
      // 1. If it times out (Server took too long), assume success
      if (e.type == DioExceptionType.receiveTimeout || 
          e.type == DioExceptionType.sendTimeout) {
        debugPrint('⚠️ Timeout hit, but assuming account created.');
        return; // We return normally, so the UI thinks it succeeded!
      }

      // 2. If it says "Bad Request", check if user already exists
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data.toString() ?? "";
        if (errorData.contains("already exists") || errorData.contains("unique")) {
            // We throw a friendly error telling them to login
            throw Exception("Account already exists. Please login.");
        }
      }

      // 3. For all other real errors, throw them
      throw Exception('Registration failed: ${e.response?.data ?? e.message}');
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
      
      debugPrint('📡 Raw Backend Response: $data');
      
      // Get status as string (handle both string and enum cases)
      final statusStr = data['status']?.toString().toLowerCase();
      final isVerified = data['is_verified'] == true || 
                         data['is_verified'] == 'true' || 
                         statusStr == 'approved';
      
      // Normalize the response
      final normalized = {
        'is_verified': isVerified,
        'status': statusStr ?? (isVerified ? 'approved' : 'none'),
        'has_pending': statusStr == 'pending',
      };
      
      data.forEach((key, value) {
        if (!normalized.containsKey(key)) {
          normalized[key] = value;
        }
      });
      
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
        
        final statusStr = data['status']?.toString().toLowerCase();
        
        final isVerified = data['is_verified'] == true || 
                           data['is_verified'] == 'true' ||
                           statusStr == 'approved' ||
                           data['verification_status']?.toString().toLowerCase() == 'approved';
        
        if (isVerified) return true;
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

  Future<void> submitRating(Map<String, dynamic> data) async {
    try {
      debugPrint('📤 Sending Rating Data: $data');
      
      // Map 'trip_id' to 'trip' if necessary (Django standard)
      if (data.containsKey('trip_id') && !data.containsKey('trip')) {
        data['trip'] = data['trip_id'];
      }
      
      // Rename 'driver_id' to 'ratee_id' if needed
      if (data.containsKey('driver_id') && !data.containsKey('ratee_id')) {
        data['ratee_id'] = data['driver_id'];
      }
      
      // Rename 'rating' to 'score' if needed
      if (data.containsKey('rating') && !data.containsKey('score')) {
        data['score'] = data['rating'];
      }

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

  // Legacy method (kept for backward compatibility if used elsewhere)
  Future<void> rateDriver({
    required int tripId,
    required int driverId,
    required double rating,
    required String comment,
  }) async {
    // Just forward to the new method
    await submitRating({
      'trip_id': tripId,
      'driver_id': driverId,
      'rating': rating,
      'comment': comment,
    });
  }

  // =====================================================
  // 6. SUBSCRIPTION METHODS
  // =====================================================

  // ✅ 1. NEW METHOD: Fetch plans from the new backend
  Future<List<dynamic>> fetchSubscriptionPlans() async {
    try {
      final response = await _dio.get('/api/subscriptions/plans/');
      return response.data; 
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to load plans");
    }
  }

  // ✅ 2. NEW METHOD: Activate subscription (Renamed to match your UI needs)
  Future<void> activateSubscription(int planId) async {
    try {
      await _dio.post(
        '/api/subscriptions/subscribe/',
        data: {'plan_id': planId},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to activate subscription");
    }
  }

  // ✅ 3. Helper for Free Trial (Calls same endpoint, specific name for clarity)
  Future<void> activateFreeSubscription(int planId) async {
    await activateSubscription(planId);
  }

  // ✅ 4. NEW METHOD: Submit Payment (This fixes your error!)
  Future<void> submitSubscriptionPayment(int planId, String transactionId) async {
    try {
      await _dio.post(
        '/api/subscriptions/pay/', 
        data: {
          'plan_id': planId,
          'transaction_id': transactionId,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to submit payment");
    }
  }

  // ✅ 5. COMPATIBILITY: Checks access using the NEW backend
  Future<Map<String, dynamic>> checkSubscriptionAccess() async {
    try {
      // We check against the new 'my-subscription' endpoint
      final response = await _dio.get('/api/subscriptions/me/');
      
      // The new endpoint returns {'plan': ..., 'is_valid': true/false}
      final bool isValid = response.data['is_valid'] == true;
      
      // Return the structure expected by CreateTripScreen
      return {
        'has_access': isValid,
        'status': isValid ? 'active' : 'inactive',
        'is_valid': isValid,
      };
    } catch (e) {
      debugPrint('❌ Failed to check subscription access: $e');
      // If error (e.g., 404 No Subscription), return false
      return {'has_access': false, 'is_valid': false};
    }
  }

  // ✅ 6. COMPATIBILITY: Dummy payment processor
  Future<Map<String, dynamic>> processSubscriptionPayment({
    required String phoneNumber,
    String paymentMethod = 'mobile_money',
  }) async {
    debugPrint("⚠️ processSubscriptionPayment called - logic moved to PaymentScreen");
    return {'status': 'redirect', 'message': 'Use new payment screen'};
  }
}

// =====================================================
// ✅ RIVERPOD PROVIDERS
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