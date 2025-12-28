// lib/models/user_model.dart

// ✅ 1. Review Model (Helper for the list)
class ReviewModel {
  final int id;
  final String raterName;
  final String? raterAvatar;
  final double score;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.raterName,
    this.raterAvatar,
    required this.score,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      raterName: json['rater_name'] ?? "User",
      raterAvatar: json['rater_avatar'],
      score: (json['score'] as num).toDouble(),
      comment: json['comment'] ?? "",
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// ✅ 2. Main User Model
class UserModel {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? profilePicture;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profilePicture,
    this.isVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Smart helper to find phone number
    String? extractPhone() {
      if (json['phone_number'] != null) return json['phone_number'];
      if (json['profile'] != null && json['profile']['phone_number'] != null) {
        return json['profile']['phone_number'];
      }
      return null;
    }

    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: extractPhone(),
      profilePicture: json['profile_picture'] as String?,
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
    };
  }

  String get displayName {
    if (firstName != null && firstName!.isNotEmpty) {
      if (lastName != null && lastName!.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName!;
    }
    return username;
  }
}

// ✅ 3. User Profile Model (MERGED)
class UserProfileModel {
  final UserModel user;
  final String? profilePicture;
  final String? phoneNumber;
  final String? bio;
  final double rating;
  final String? role;
  
  // ✅ Fields for Profile & Trip Cards
  final DateTime createdAt;
  final String? vehiclePlateNumber;
  final String? vehicleModel;
  final int? vehicleSeats;
  final String? vehiclePhoto;

  // ✅ NEW: The list of reviews
  final List<ReviewModel> reviews; 

  UserProfileModel({
    required this.user,
    this.profilePicture,
    this.phoneNumber,
    this.bio,
    this.rating = 5.0,
    this.role,
    required this.createdAt,
    this.vehiclePlateNumber,
    this.vehicleModel,
    this.vehicleSeats,
    this.vehiclePhoto,
    // ✅ Add to constructor
    required this.reviews, 
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      user: UserModel.fromJson(json['user']),
      // Map both keys just in case
      profilePicture: json['profile_picture'] as String? ?? json['avatar'] as String?, 
      phoneNumber: json['phone_number'] as String? ?? json['phone'] as String?,
      bio: json['bio'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      role: json['role'] as String?,
      
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),

      vehiclePlateNumber: json['vehicle_plate_number'] as String?,
      vehicleModel: json['vehicle_model'] as String?,
      vehicleSeats: json['vehicle_seats'] as int?,
      vehiclePhoto: json['vehicle_photo'] as String?,

      // ✅ Map the list of reviews
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => ReviewModel.fromJson(e))
          .toList() ?? [],
    );
  }

  // Use this getter for easier UI access
  String? get avatar => profilePicture; 
}