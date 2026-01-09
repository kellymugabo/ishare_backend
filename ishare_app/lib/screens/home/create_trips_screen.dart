import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
// 🌍 LOCALIZATION IMPORT
import 'package:ishare_app/l10n/app_localizations.dart';

import '../../services/api_service.dart';
import '../../constants/app_theme.dart';

// ✅ SCREENS IMPORTS
import '../auth/login_screen.dart';
import 'driververification_screen.dart';
import 'subscription_screen.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  bool _isLoading = false;
  int _currentStep = 0;

  // ✅ NEW: Amenity States (Preferences)
  bool _hasAC = false;
  bool _allowsLuggage = false;
  bool _noSmoking = true; // Default to 'No Smoking' for safety
  bool _hasMusic = false;

  // Formatters for Professional Display
  final _currencyFormat = NumberFormat("#,##0", "en_US");

  // Popular locations in Rwanda
  final List<Map<String, dynamic>> _popularLocations = [
    {'name': 'Kigali', 'lat': -1.9536, 'lng': 30.0606},
    {'name': 'Nyabugogo', 'lat': -1.9706, 'lng': 30.0588},
    {'name': 'Musanze', 'lat': -1.4992, 'lng': 29.6353},
    {'name': 'Rubavu', 'lat': -1.6778, 'lng': 29.2564},
    {'name': 'Huye', 'lat': -2.5967, 'lng': 29.7389},
    {'name': 'Rusizi', 'lat': -2.4862, 'lng': 28.9026},
  ];

  @override
  void initState() {
    super.initState();
    // Listen to changes to update the UI (Total Calculation) in real-time
    _priceController.addListener(() => setState(() {}));
    _seatsController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  // --- Logic Helpers ---
  Map<String, double> _getCoordinates(String locationName) {
    try {
      final location = _popularLocations.firstWhere(
        (loc) => loc['name'].toString().toLowerCase() == locationName.toLowerCase(),
      );
      return {'lat': location['lat'] as double, 'lng': location['lng'] as double};
    } catch (e) {
      return {'lat': 0.0, 'lng': 0.0};
    }
  }

  void _fillLocation(String name, bool isStart) {
    setState(() {
      if (isStart) {
        _fromController.text = name;
      } else {
        _toController.text = name;
      }
    });
  }

  // Calculate Total Earnings
  double get _totalEarnings {
    final price = double.tryParse(_priceController.text.replaceAll(',', '')) ?? 0;
    final seats = int.tryParse(_seatsController.text) ?? 0;
    return price * seats;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(l10n.offerRide, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textDark)),
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. Progress Indicator
          _buildProgressHeader(),

          // 2. Main Content Area
          Expanded(
            child: Form(
              key: _formKey,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: SingleChildScrollView(
                  key: ValueKey<int>(_currentStep),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStepTitle(l10n),
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStepSubtitle(l10n),
                        style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.4),
                      ),
                      const SizedBox(height: 32),
                      if (_currentStep == 0) _buildRouteStep(l10n),
                      if (_currentStep == 1) _buildDetailsStep(l10n),
                      if (_currentStep == 2) _buildReviewStep(l10n),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // 3. Bottom Action Bar
      bottomNavigationBar: _buildBottomBar(l10n),
    );
  }

  // =====================================================
  // UI COMPONENTS
  // =====================================================

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Row(
        children: [
          _buildStepDot(isActive: _currentStep >= 0),
          _buildStepLine(isActive: _currentStep >= 1),
          _buildStepDot(isActive: _currentStep >= 1),
          _buildStepLine(isActive: _currentStep >= 2),
          _buildStepDot(isActive: _currentStep >= 2),
        ],
      ),
    );
  }

  Widget _buildStepDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryBlue : Colors.grey[300],
        shape: BoxShape.circle,
        boxShadow: isActive ? [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.4), blurRadius: 6)] : [],
      ),
    );
  }

  Widget _buildStepLine({required bool isActive}) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 3,
        color: isActive ? AppTheme.primaryBlue : Colors.grey[300],
      ),
    );
  }

  // --- Step 1: Route ---
  Widget _buildRouteStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Column(
                  children: [
                    const Icon(Icons.circle, size: 16, color: AppTheme.primaryBlue),
                    Expanded(child: Container(width: 2, color: Colors.grey[200])),
                    const Icon(Icons.location_on, size: 20, color: Colors.redAccent),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildCleanInput(
                        controller: _fromController,
                        label: l10n.startingPoint,
                        hint: "City or Area",
                      ),
                      const Divider(height: 30),
                      _buildCleanInput(
                        controller: _toController,
                        label: l10n.destination,
                        hint: "City or Area",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text("Quick Select", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _popularLocations.map((loc) => ActionChip(
            label: Text(loc['name']),
            backgroundColor: Colors.white,
            elevation: 1,
            onPressed: () {
              if (_fromController.text.isEmpty) {
                _fillLocation(loc['name'], true);
              } else if (_toController.text.isEmpty) {
                _fillLocation(loc['name'], false);
              }
            },
          )).toList(),
        ),
      ],
    );
  }

  // --- Step 2: Details (UPDATED WITH AMENITIES) ---
  Widget _buildDetailsStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align "Ride Comfort" title to left
      children: [
        InkWell(
          onTap: _selectDateTime,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.05), blurRadius: 15)],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryBlue, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.departureTime.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEE, MMM d • h:mm a').format(_selectedDateTime),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _buildCardInput(
                controller: _seatsController,
                label: l10n.seats,
                icon: Icons.airline_seat_recline_normal_rounded,
                suffix: "",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCardInput(
                controller: _priceController,
                label: l10n.price,
                icon: Icons.monetization_on_rounded,
                suffix: "RWF",
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ✅ NEW: Amenities Selector
        const Text(
          "Ride Comfort & Rules",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildAmenityToggle("AC", Icons.ac_unit_rounded, _hasAC, (val) => setState(() => _hasAC = val)),
            _buildAmenityToggle("Luggage", Icons.luggage_rounded, _allowsLuggage, (val) => setState(() => _allowsLuggage = val)),
            _buildAmenityToggle("Music", Icons.music_note_rounded, _hasMusic, (val) => setState(() => _hasMusic = val)),
            _buildAmenityToggle("No Smoking", Icons.smoke_free_rounded, _noSmoking, (val) => setState(() => _noSmoking = val)),
          ],
        ),
      ],
    );
  }

  // ✅ NEW HELPER: Amenity Toggle Button
  Widget _buildAmenityToggle(String label, IconData icon, bool isSelected, Function(bool) onTap) {
    return InkWell(
      onTap: () => onTap(!isSelected),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey[300]!,
            width: 1.5
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Step 3: Review ---
  Widget _buildReviewStep(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 25, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.summary, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow(l10n.from, _fromController.text, Icons.my_location_rounded, Colors.black),
                const Padding(
                  padding: EdgeInsets.only(left: 28, top: 4, bottom: 4),
                  child: Align(alignment: Alignment.centerLeft, child: Icon(Icons.arrow_downward_rounded, size: 14, color: Colors.grey)),
                ),
                _buildSummaryRow(l10n.to, _toController.text, Icons.location_on_rounded, Colors.redAccent),
                
                const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(height: 1)),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_today_rounded, color: Colors.orange),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Departure Date", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Row(
                          children: [
                            Text(
                              DateFormat('EEEE, ').format(_selectedDateTime),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              DateFormat('MMM d').format(_selectedDateTime),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('h:mm a').format(_selectedDateTime),
                          style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w600),
                        ),
                      ],
                    )
                  ],
                ),

                const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(height: 1)),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildFinancialRow(
                        "Price per Seat", 
                        "${_currencyFormat.format(int.tryParse(_priceController.text) ?? 0)} RWF"
                      ),
                      const SizedBox(height: 8),
                      _buildFinancialRow(
                        "Total Seats", 
                        _seatsController.text
                      ),
                      const SizedBox(height: 8),
                      // ✅ NEW: Show amenities in summary (Optional text)
                      if (_hasAC || _allowsLuggage) 
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            children: [
                              if (_hasAC) const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.ac_unit, size: 14, color: Colors.grey)),
                              if (_allowsLuggage) const Icon(Icons.luggage, size: 14, color: Colors.grey),
                              const SizedBox(width: 8),
                              const Text("Includes Amenities", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Earnings", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            "${_currencyFormat.format(_totalEarnings)} RWF",
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Input Widgets ---

  Widget _buildCleanInput({required TextEditingController controller, required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[300]),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          validator: (value) => value!.isEmpty ? "Required" : null,
        ),
      ],
    );
  }

  Widget _buildCardInput({required TextEditingController controller, required String label, required IconData icon, required String suffix}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              suffixText: suffix,
              suffixStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              border: InputBorder.none,
              isDense: true,
            ),
            validator: (value) => value!.isEmpty ? "Required" : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 14, backgroundColor: color.withOpacity(0.1), child: Icon(icon, size: 16, color: color)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  Widget _buildFinancialRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  // --- Bottom Bar ---

  Widget _buildBottomBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  onPressed: () => setState(() => _currentStep--),
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.grey),
                  style: IconButton.styleFrom(backgroundColor: Colors.grey[100], padding: const EdgeInsets.all(12)),
                ),
              ),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleNextOrSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: AppTheme.primaryBlue.withOpacity(0.4),
                ),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text(
                        _currentStep == 2 ? l10n.publishRide : l10n.continueText,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Logic Methods ---

  String _getStepTitle(AppLocalizations l10n) {
    switch (_currentStep) {
      case 0: return l10n.planRoute;
      case 1: return l10n.tripInfo;
      case 2: return "Review Trip";
      default: return '';
    }
  }

  String _getStepSubtitle(AppLocalizations l10n) {
    switch (_currentStep) {
      case 0: return "Where are you going today?";
      case 1: return "Set your schedule, pricing & comfort"; // Updated subtitle
      case 2: return "Confirm earnings & schedule";
      default: return '';
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primaryBlue)),
        child: child!,
      ),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_selectedDateTime));
      if (time != null) {
        setState(() => _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
      }
    }
  }

  Future<void> _handleNextOrSubmit() async {
    if (_currentStep == 0 && _formKey.currentState!.validate()) {
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1 && _formKey.currentState!.validate()) {
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      await _submitTrip();
    }
  }

  Future<void> _submitTrip() async {
    final apiService = ref.read(apiServiceProvider);
    final l10n = AppLocalizations.of(context)!;
    
    // Auth & Verification Checks
    if (!await apiService.isLoggedIn()) {
      _showAuthDialog();
      return;
    }
    
    // Check verification status with detailed error handling
    try {
      final verificationStatus = await apiService.checkDriverVerification();
      
      // Check if verified
      if (verificationStatus['is_verified'] != true && 
          verificationStatus['status'] != 'approved') {
        
        // Check if pending
        if (verificationStatus['status'] == 'pending' || 
            verificationStatus['has_pending'] == true) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Verification Pending'),
                content: const Text(
                  'Your driver verification is still under review. '
                  'Please wait for approval before publishing rides.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          return;
        }
        
        // Not verified and not pending - show verification dialog
        _showVerifyDialog();
        return;
      }
    } catch (e) {
      debugPrint('⚠️ Error checking verification status: $e');
      // Continue with submission - backend will validate
    }

    // ✅ Check subscription status before creating trip
    try {
      final subscriptionData = await apiService.checkSubscriptionAccess();
      if (subscriptionData['has_access'] == false) {
        if (mounted) {
          _showSubscriptionDialog(subscriptionData);
        }
        return;
      }
    } catch (e) {
      debugPrint('⚠️ Could not check subscription: $e');
      // Continue anyway - backend will validate
    }

    setState(() => _isLoading = true);

    try {
      final startCoords = _getCoordinates(_fromController.text);
      final destCoords = _getCoordinates(_toController.text);

      final tripData = {
        'start_location_name': _fromController.text,
        'start_lat': startCoords['lat'].toString(),
        'start_lng': startCoords['lng'].toString(),
        'destination_name': _toController.text,
        'dest_lat': destCoords['lat'].toString(),
        'dest_lng': destCoords['lng'].toString(),
        'available_seats': _seatsController.text,
        'price_per_seat': _priceController.text,
        'departure_time': _selectedDateTime.toUtc().toIso8601String(),
        
        // ✅ NEW: Sending Amenities to Backend
        'has_ac': _hasAC,
        'allows_luggage': _allowsLuggage,
        'no_smoking': _noSmoking,
        'has_music': _hasMusic,
      };

      await apiService.createTrip(tripData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Ride published successfully!'), backgroundColor: Colors.green)
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to publish ride';
        
        // Check if it's a subscription error
        if (e.toString().contains('subscription') || e.toString().contains('expired')) {
          errorMessage = 'Your subscription has expired. Please renew to publish rides.';
        } else if (e is DioException && e.response?.data != null) {
          final errorData = e.response!.data;
          if (errorData is Map) {
            errorMessage = errorData['error'] ?? errorData['detail'] ?? errorMessage;
          }
        } else {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSubscriptionDialog(Map<String, dynamic> subscriptionData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Expired'),
        content: Text(
          'Your subscription has expired. Please renew your subscription to publish rides.\n\n'
          'Price: ${subscriptionData['subscription_price'] ?? 10000} RWF\n'
          'Days remaining: ${subscriptionData['days_remaining'] ?? 0}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close create trip screen
              // Navigate directly to subscription screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Renew Subscription'),
          ),
        ],
      ),
    );
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to offer a ride.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showVerifyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Required'),
        content: const Text('Please verify your identity first.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverVerificationScreen()));
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}