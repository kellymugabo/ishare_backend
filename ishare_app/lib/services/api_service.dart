import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/trip_model.dart';
import '../models/booking_model.dart';

// ⚠️ NETWORK CONFIGURATION
// Use "http://127.0.0.1:8000" for Windows Desktop, Edge (Web), or iOS Simulator.
// Use "http://10.0.2.2:8000" ONLY for Android Emulator.
const String baseUrl = "http://127.0.0.1:8000";

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isRefreshing = false; 

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    
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
        debugPrint('❌ API Error: ${e.response?.statusCode} - ${e.message}');
        
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

  Future<void> submitDriverVerification(Map<String, dynamic> data) async {
    try {
      await _dio.post('/api/driver/verify/', data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkDriverVerification() async {
    try {
      final response = await _dio.get('/api/driver/verification-status/');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isDriverVerified() async {
    try {
      final response = await _dio.get('/api/driver/verification-status/');
      if (response.data != null && response.data['is_verified'] == true) {
        return true;
      }
      return false;
    } catch (e) {
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
// ... inside ApiService class ...
// ✅ Rate Driver
  Future<void> rateDriver({
    required int tripId,
    required int driverId,
    required double rating,
    required String comment,
  }) async {
    try {
      final data = {
        // ✅ FIX 1: Server asked for 'trip', so we give it 'trip'
        'trip': tripId,      
        
        // ✅ FIX 2: Keeping 'ratee_id' because the previous error asked for it
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