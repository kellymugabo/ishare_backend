import 'trip_model.dart';
import 'user_model.dart';

class BookingModel {
  final int? id;
  final int tripId;
  final TripModel? trip;
  
  final int? passengerId;
  final UserModel? passenger; 
  
  final int seatsBooked;
  final double totalPrice;
  final String status;
  
  // 1️⃣ Field Declaration
  final String? passengerName; 

  final String? paymentMethod;
  final String? phoneNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingModel({
    this.id,
    required this.tripId,
    this.trip,
    this.passengerId,
    this.passenger,
    required this.seatsBooked,
    required this.totalPrice,
    this.status = 'pending',
    this.paymentMethod,
    this.phoneNumber,
    this.createdAt,
    this.updatedAt,
    
    // 2️⃣ Constructor Initialization
    this.passengerName, 
  });

  // ✅ FIXED: Uses firstName/lastName instead of 'name'
  String get displayName {
    if (passenger != null) {
      
      final first = passenger!.firstName ?? '';
      final last = passenger!.lastName ?? '';
      
      if (first.isNotEmpty || last.isNotEmpty) {
        return "$first $last".trim();
      }
    }
    
    if (passengerName != null && passengerName!.isNotEmpty) {
      return passengerName!;
    }
    
    return "Passenger #${passengerId ?? '?'}";
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // --- 1. Parse Trip ---
    TripModel? parsedTrip;
    int parsedTripId;
    
    if (json['trip'] is Map<String, dynamic>) {
      parsedTrip = TripModel.fromJson(json['trip'] as Map<String, dynamic>);
      // ✅ FIXED WARNING: 'id' is likely non-nullable in your TripModel
      parsedTripId = parsedTrip.id; 
    } else if (json['trip'] is int) {
      parsedTripId = json['trip'] as int;
    } else {
      parsedTripId = json['trip_id'] as int? ?? 0;
    }

    // --- 2. Parse Passenger ---
    UserModel? parsedPassenger;
    int? parsedPassengerId;

    if (json['passenger'] is Map<String, dynamic>) {
      parsedPassenger = UserModel.fromJson(json['passenger'] as Map<String, dynamic>);
      parsedPassengerId = parsedPassenger.id;
    } else if (json['passenger'] is int) {
      parsedPassengerId = json['passenger'] as int;
    } else {
      parsedPassengerId = json['passenger_id'] as int?;
    }

    // --- 3. Parse Price ---
    double parsedTotalPrice = 0.0;
    if (json['total_price'] != null) {
      if (json['total_price'] is String) {
        parsedTotalPrice = double.tryParse(json['total_price']) ?? 0.0;
      } else if (json['total_price'] is num) {
        parsedTotalPrice = (json['total_price'] as num).toDouble();
      }
    }

    // --- 4. Parse Name Logic ---
    String? parsedName;
    if (parsedPassenger != null) {
      // ✅ FIXED: Combine first and last name here too
      final first = parsedPassenger.firstName ?? '';
      final last = parsedPassenger.lastName ?? '';
      if (first.isNotEmpty || last.isNotEmpty) {
        parsedName = "$first $last".trim();
      }
    }
    
    // ✅ FIXED LINT: Use '??=' assignment
    parsedName ??= json['passenger_name'] as String?;

    return BookingModel(
      id: json['id'] as int?,
      tripId: parsedTripId,
      trip: parsedTrip,
      passengerId: parsedPassengerId,
      passenger: parsedPassenger,
      seatsBooked: json['seats_booked'] as int? ?? 1,
      totalPrice: parsedTotalPrice,
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String?,
      phoneNumber: json['phone_number'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      
      // ✅ Assign the parsed name
      passengerName: parsedName, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'trip_id': tripId,
      if (passengerId != null) 'passenger_id': passengerId,
      'seats_booked': seatsBooked,
      'total_price': totalPrice,
      'status': status,
      if (passengerName != null) 'passenger_name': passengerName,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  BookingModel copyWith({
    int? id,
    int? tripId,
    TripModel? trip,
    int? passengerId,
    UserModel? passenger,
    int? seatsBooked,
    double? totalPrice,
    String? status,
    String? passengerName,
    String? paymentMethod,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      trip: trip ?? this.trip,
      passengerId: passengerId ?? this.passengerId,
      passenger: passenger ?? this.passenger,
      seatsBooked: seatsBooked ?? this.seatsBooked,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      passengerName: passengerName ?? this.passengerName, 
      paymentMethod: paymentMethod ?? this.paymentMethod,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}