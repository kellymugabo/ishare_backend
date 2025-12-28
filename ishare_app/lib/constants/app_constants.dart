

class AppConstants {
  // App Information
  static const String appName = 'iShare Rwanda';
  static const String appTagline = 'Together we move 🚗';
  static const String appVision = 'To make transport in Rwanda smarter, cheaper, and community-driven through shared mobility.';
  static const String appMission = 'Together we move.';
  
  // Platform Configuration
  static const double platformCommissionRate = 0.10; // 10% platform fee
  static const String currency = 'RWF';
  static const String currencySymbol = 'RWF';
  
  // Payment Configuration
  static const String paymentMethod = 'MTN MoMo Pay';
  static const bool autoDeductCommission = true;
  
  // User Roles
  static const String rolePassenger = 'passenger';
  static const String roleDriver = 'driver';
  
  // Ratings
  static const double minRating = 1.0;
  static const double maxRating = 5.0;
  static const double defaultRating = 4.0;
  
  // Trip Status
  static const String tripStatusPending = 'pending';
  static const String tripStatusConfirmed = 'confirmed';
  static const String tripStatusInProgress = 'in_progress';
  static const String tripStatusCompleted = 'completed';
  static const String tripStatusCancelled = 'cancelled';
  
  // Booking Status
  static const String bookingStatusPending = 'pending';
  static const String bookingStatusConfirmed = 'confirmed';
  static const String bookingStatusCancelled = 'cancelled';
  static const String bookingStatusCompleted = 'completed';
  
  // Safety Features
  static const String sosHotline = '112'; // Rwanda Emergency Number
  static const String sosHotlineLabel = 'Emergency Services';
  
  // Impact Messages
  static const List<String> impactMessages = [
    '🌱 Reduce CO₂ emissions by sharing rides',
    '💰 Save money on transport costs',
    '🤝 Build community connections',
    '🚗 Maximize vehicle capacity',
    '🌍 Contribute to Rwanda Vision 2050',
    '⚡ Support smart city initiatives',
  ];
  
  // About Content
  static const String aboutTitle = 'About iShare';
  static const String aboutDescription = '''
iShare is a Rwandan-built ride and cost-sharing mobile application that connects people traveling in the same direction. 

We help car owners with empty seats connect with passengers going along their route so they can share the cost of transport and reduce fuel expenses.

This solves several issues in Rwanda's mobility ecosystem — affordability, efficiency, and environmental sustainability.
''';
  
  static const String problemStatement = '''
In Rwanda, many vehicles travel daily with empty seats while thousands of citizens struggle to find convenient and affordable transport options. Public transport is often overcrowded, limited in flexibility, and not available in all routes or hours. Meanwhile, fuel prices continue to rise, making private car ownership expensive for individual use.
''';
  
  static const String solution = '''
iShare bridges this gap by providing a smart digital platform that matches drivers and passengers traveling in the same direction using GPS-based technology. The app promotes shared mobility and offers safe, cost-efficient, and convenient rides for everyone.
''';
  
  // How It Works Steps
  static const List<Map<String, dynamic>> howItWorksSteps = [
    {
      'step': 1,
      'icon': 'directions_car',
      'title': 'Post a Trip',
      'description': 'Driver posts a trip with available seats, start and destination points, and price per seat.',
      'role': 'driver',
    },
    {
      'step': 2,
      'icon': 'search',
      'title': 'Find Rides',
      'description': 'Passengers in nearby areas see available rides going in the same direction.',
      'role': 'passenger',
    },
    {
      'step': 3,
      'icon': 'chat',
      'title': 'Connect & Book',
      'description': 'Request a seat, confirm through chat or call, and book your ride.',
      'role': 'both',
    },
    {
      'step': 4,
      'icon': 'payment',
      'title': 'Pay Securely',
      'description': 'Pay via MTN MoMo Pay. Platform automatically deducts 10% commission.',
      'role': 'passenger',
    },
    {
      'step': 5,
      'icon': 'route',
      'title': 'Share the Ride',
      'description': 'Travel together safely using GPS navigation and real-time tracking.',
      'role': 'both',
    },
    {
      'step': 6,
      'icon': 'star',
      'title': 'Rate & Review',
      'description': 'Rate each other after the trip to build community trust.',
      'role': 'both',
    },
  ];
  
  // Features
  static const List<Map<String, String>> features = [
    {
      'icon': 'account_circle',
      'title': 'User Accounts',
      'description': 'Register as Driver or Passenger',
    },
    {
      'icon': 'location_on',
      'title': 'Live GPS Tracking',
      'description': 'Real-time location and route matching',
    },
    {
      'icon': 'search',
      'title': 'Smart Search',
      'description': 'Find rides going your direction',
    },
    {
      'icon': 'payment',
      'title': 'MTN MoMo Pay',
      'description': 'Secure mobile money integration',
    },
    {
      'icon': 'percent',
      'title': 'Auto Cost Sharing',
      'description': '10% platform fee automatically calculated',
    },
    {
      'icon': 'star',
      'title': 'Ratings & Reviews',
      'description': 'Build trust through community feedback',
    },
    {
      'icon': 'chat',
      'title': 'In-App Chat',
      'description': 'Communicate with drivers/passengers',
    },
    {
      'icon': 'emergency',
      'title': 'SOS Safety Tools',
      'description': 'Emergency contact and location sharing',
    },
  ];
  
  // Support & Contact
  static const String supportEmail = 'support@ishare.rw';
  static const String supportPhone = '+250 XXX XXX XXX';
  static const String website = 'www.ishare.rw';
  
  // Legal
  static const String copyrightOwner = 'iShare Rwanda';
  static const int copyrightYear = 2025;
  static const String intellectualPropertyNotice = 'All intellectual property belongs to the project founder.';
  
  // Regional Expansion
  static const String longTermGoal = 'To expand iShare beyond Rwanda into neighboring East African countries, promoting regional connectivity and sustainability.';
  static const List<String> targetCountries = [
    'Rwanda',
    'Uganda',
    'Kenya',
    'Tanzania',
    'Burundi',
  ];
  
  // Rwanda Vision 2050 Alignment
  static const List<String> visionAlignment = [
    'Supporting smart city initiatives',
    'Reducing CO₂ emissions by maximizing car capacity',
    'Creating job and income opportunities for drivers',
    'Offering citizens a cheaper and more flexible way to move around cities',
  ];
  
  /// Calculate platform commission from total amount
  static double calculateCommission(double totalAmount) {
    return totalAmount * platformCommissionRate;
  }
  
  /// Calculate driver earnings after commission
  static double calculateDriverEarnings(double totalAmount) {
    return totalAmount * (1 - platformCommissionRate);
  }
  
  /// Format currency
  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} $currencySymbol';
  }
}