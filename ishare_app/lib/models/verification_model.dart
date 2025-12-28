class VerificationModel {
  final String userId;
  final String nationalIdStatus;
  final String driverLicenseStatus;
  final String vehicleStatus;
  final NationalIdData? nationalId;
  final DriverLicenseData? driverLicense;
  final VehicleData? vehicle;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final String? rejectionReason;

  VerificationModel({
    required this.userId,
    this.nationalIdStatus = 'not_started',
    this.driverLicenseStatus = 'not_started',
    this.vehicleStatus = 'not_started',
    this.nationalId,
    this.driverLicense,
    this.vehicle,
    this.submittedAt,
    this.verifiedAt,
    this.rejectionReason,
  });

  bool get isFullyVerified =>
      nationalIdStatus == 'verified' &&
      driverLicenseStatus == 'verified' &&
      vehicleStatus == 'verified';

  bool get canOfferRides =>
      nationalIdStatus == 'verified' &&
      driverLicenseStatus == 'verified' &&
      vehicleStatus == 'verified';

  bool get canRequestRides => nationalIdStatus == 'verified';

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nationalIdStatus': nationalIdStatus,
      'driverLicenseStatus': driverLicenseStatus,
      'vehicleStatus': vehicleStatus,
      'nationalId': nationalId?.toJson(),
      'driverLicense': driverLicense?.toJson(),
      'vehicle': vehicle?.toJson(),
      'submittedAt': submittedAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  factory VerificationModel.fromJson(Map<String, dynamic> json) {
    return VerificationModel(
      userId: json['userId'] ?? '',
      nationalIdStatus: json['nationalIdStatus'] ?? 'not_started',
      driverLicenseStatus: json['driverLicenseStatus'] ?? 'not_started',
      vehicleStatus: json['vehicleStatus'] ?? 'not_started',
      nationalId: json['nationalId'] != null
          ? NationalIdData.fromJson(json['nationalId'])
          : null,
      driverLicense: json['driverLicense'] != null
          ? DriverLicenseData.fromJson(json['driverLicense'])
          : null,
      vehicle: json['vehicle'] != null
          ? VehicleData.fromJson(json['vehicle'])
          : null,
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : null,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
      rejectionReason: json['rejectionReason'],
    );
  }

  VerificationModel copyWith({
    String? userId,
    String? nationalIdStatus,
    String? driverLicenseStatus,
    String? vehicleStatus,
    NationalIdData? nationalId,
    DriverLicenseData? driverLicense,
    VehicleData? vehicle,
    DateTime? submittedAt,
    DateTime? verifiedAt,
    String? rejectionReason,
  }) {
    return VerificationModel(
      userId: userId ?? this.userId,
      nationalIdStatus: nationalIdStatus ?? this.nationalIdStatus,
      driverLicenseStatus: driverLicenseStatus ?? this.driverLicenseStatus,
      vehicleStatus: vehicleStatus ?? this.vehicleStatus,
      nationalId: nationalId ?? this.nationalId,
      driverLicense: driverLicense ?? this.driverLicense,
      vehicle: vehicle ?? this.vehicle,
      submittedAt: submittedAt ?? this.submittedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

class NationalIdData {
  final String idNumber;
  final String frontImageUrl;
  final String backImageUrl;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? placeOfBirth;

  NationalIdData({
    required this.idNumber,
    required this.frontImageUrl,
    required this.backImageUrl,
    required this.fullName,
    this.dateOfBirth,
    this.placeOfBirth,
  });

  Map<String, dynamic> toJson() {
    return {
      'idNumber': idNumber,
      'frontImageUrl': frontImageUrl,
      'backImageUrl': backImageUrl,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'placeOfBirth': placeOfBirth,
    };
  }

  factory NationalIdData.fromJson(Map<String, dynamic> json) {
    return NationalIdData(
      idNumber: json['idNumber'] ?? '',
      frontImageUrl: json['frontImageUrl'] ?? '',
      backImageUrl: json['backImageUrl'] ?? '',
      fullName: json['fullName'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      placeOfBirth: json['placeOfBirth'],
    );
  }
}

class DriverLicenseData {
  final String licenseNumber;
  final String frontImageUrl;
  final String backImageUrl;
  final DateTime expiryDate;
  final String category;
  final DateTime issueDate;

  DriverLicenseData({
    required this.licenseNumber,
    required this.frontImageUrl,
    required this.backImageUrl,
    required this.expiryDate,
    required this.category,
    required this.issueDate,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  
  bool get isExpiringSoon {
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    return expiryDate.isBefore(thirtyDaysFromNow);
  }

  Map<String, dynamic> toJson() {
    return {
      'licenseNumber': licenseNumber,
      'frontImageUrl': frontImageUrl,
      'backImageUrl': backImageUrl,
      'expiryDate': expiryDate.toIso8601String(),
      'category': category,
      'issueDate': issueDate.toIso8601String(),
    };
  }

  factory DriverLicenseData.fromJson(Map<String, dynamic> json) {
    return DriverLicenseData(
      licenseNumber: json['licenseNumber'] ?? '',
      frontImageUrl: json['frontImageUrl'] ?? '',
      backImageUrl: json['backImageUrl'] ?? '',
      expiryDate: DateTime.parse(json['expiryDate']),
      category: json['category'] ?? '',
      issueDate: DateTime.parse(json['issueDate']),
    );
  }
}

class VehicleData {
  final String plateNumber;
  final String make;
  final String model;
  final int year;
  final String color;
  final int availableSeats;
  final String registrationImageUrl;
  final String vehiclePhotoUrl;
  final DateTime? insuranceExpiry;
  final String? vehicleType;

  VehicleData({
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.availableSeats,
    required this.registrationImageUrl,
    required this.vehiclePhotoUrl,
    this.insuranceExpiry,
    this.vehicleType,
  });

  bool get isInsuranceExpired =>
      insuranceExpiry != null && DateTime.now().isAfter(insuranceExpiry!);

  String get displayName => '$year $make $model';

  Map<String, dynamic> toJson() {
    return {
      'plateNumber': plateNumber,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'availableSeats': availableSeats,
      'registrationImageUrl': registrationImageUrl,
      'vehiclePhotoUrl': vehiclePhotoUrl,
      'insuranceExpiry': insuranceExpiry?.toIso8601String(),
      'vehicleType': vehicleType,
    };
  }

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    return VehicleData(
      plateNumber: json['plateNumber'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      color: json['color'] ?? '',
      availableSeats: json['availableSeats'] ?? 1,
      registrationImageUrl: json['registrationImageUrl'] ?? '',
      vehiclePhotoUrl: json['vehiclePhotoUrl'] ?? '',
      insuranceExpiry: json['insuranceExpiry'] != null
          ? DateTime.parse(json['insuranceExpiry'])
          : null,
      vehicleType: json['vehicleType'],
    );
  }
}

// Document upload model
class DocumentUpload {
  final String userId;
  final String documentType;
  final String filePath;
  final String fileName;
  final int fileSize;
  final DateTime uploadedAt;
  final String status;

  DocumentUpload({
    required this.userId,
    required this.documentType,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.uploadedAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'documentType': documentType,
      'filePath': filePath,
      'fileName': fileName,
      'fileSize': fileSize,
      'uploadedAt': uploadedAt.toIso8601String(),
      'status': status,
    };
  }

  factory DocumentUpload.fromJson(Map<String, dynamic> json) {
    return DocumentUpload(
      userId: json['userId'] ?? '',
      documentType: json['documentType'] ?? '',
      filePath: json['filePath'] ?? '',
      fileName: json['fileName'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      uploadedAt: DateTime.parse(json['uploadedAt']),
      status: json['status'] ?? 'pending',
    );
  }
}