class TripModel {
  final int id;
  final DriverInfo driver;
  final String startLocationName;
  final double startLat;
  final double startLng;
  final String destinationName;
  final double destLat;
  final double destLng;
  
  final String? driverPhone;
  final DateTime departureTime; 
  
  // ✅ NEW: Store Total and Booked separately to calculate availability accurately
  final int totalSeats;
  final int bookedSeats;

  // ✅ LOGIC: Auto-calculate remaining seats
  int get availableSeats => totalSeats - bookedSeats;

  final double pricePerSeat;
  final DateTime createdAt;
  final bool isActive;
  
  final String? carName;
  final String? carPhotoUrl;

  TripModel({
    required this.id,
    required this.driver,
    required this.startLocationName,
    required this.startLat,
    required this.startLng,
    required this.destinationName,
    required this.destLat,
    required this.destLng,
    required this.departureTime,
    
    // Updated Constructor
    required this.totalSeats,
    required this.bookedSeats,
    
    required this.pricePerSeat,
    required this.createdAt,
    required this.isActive,
    this.carName,
    this.carPhotoUrl, 
    this.driverPhone,
  });

  String get driverName => driver.displayName;

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'],
      driver: DriverInfo.fromJson(json['driver']),
      startLocationName: json['start_location_name'],
      startLat: (json['start_lat'] as num).toDouble(),
      startLng: (json['start_lng'] as num).toDouble(),
      destinationName: json['destination_name'],
      destLat: (json['dest_lat'] as num).toDouble(),
      destLng: (json['dest_lng'] as num).toDouble(),
      
      departureTime: DateTime.parse(json['departure_time']), 
      
      // ✅ LOGIC FIX: 
      // 1. Try to read 'total_seats'. If missing, assume 'available_seats' is the total capacity.
      totalSeats: json['total_seats'] ?? json['available_seats'] ?? 4,
      
      // 2. Read 'booked_seats'. Default to 0 if not sent.
      bookedSeats: json['booked_seats'] ?? json['seats_booked'] ?? 0,
      
      pricePerSeat: double.parse(json['price_per_seat'].toString()),
      driverPhone: json['driver_phone'], 
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
      
      carName: json['car_name'] ?? 'Car Details Unavailable',
      carPhotoUrl: json['car_photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_location_name': startLocationName,
      'start_lat': startLat,
      'start_lng': startLng,
      'destination_name': destinationName,
      'dest_lat': destLat,
      'dest_lng': destLng,
      'departure_time': departureTime.toIso8601String(),
      
      // Send back the data correctly
      'total_seats': totalSeats,
      'booked_seats': bookedSeats,
      'available_seats': availableSeats, // Send the calculated value just in case
      
      'price_per_seat': pricePerSeat,
      'car_name': carName,
      'car_photo_url': carPhotoUrl,
    };
  }
}

class DriverInfo {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phoneNumber;
  final bool isVerified; 

  DriverInfo({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    required this.email,
    this.phoneNumber,
    this.isVerified = false, 
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'] ?? json['phone'],
      isVerified: json['is_verified'] ?? false, 
    );
  }

  String get displayName {
    if (firstName != null && firstName!.isNotEmpty) {
      return '$firstName ${lastName ?? ''}'.trim();
    }
    return username;
  }
}