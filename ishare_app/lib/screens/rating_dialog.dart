import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Needed for API
import '../../constants/app_theme.dart';
import '../../models/trip_model.dart';
import '../../services/api_service.dart'; // ✅ Import your API service

class RateDriverDialog extends ConsumerStatefulWidget {
  final TripModel trip;

  const RateDriverDialog({super.key, required this.trip});

  @override
  ConsumerState<RateDriverDialog> createState() => _RateDriverDialogState();
}

class _RateDriverDialogState extends ConsumerState<RateDriverDialog> {
  double _rating = 5.0; // Default to 5 stars (positive psychology)
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  // ✅ Professional Touch: Quick Feedback Tags
  final List<String> _feedbackTags = [
    "Safe Driving",
    "Clean Car",
    "Good Music",
    "Friendly",
    "Punctual"
  ];
  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);

    final apiService = ref.read(apiServiceProvider);
    
    // Combine tags and comment into one string for the backend
    String finalComment = _commentController.text;
    if (_selectedTags.isNotEmpty) {
      finalComment += "\n[Tags: ${_selectedTags.join(', ')}]";
    }

    try {
      // ✅ Call your backend (You need to add this method to ApiService)
      await apiService.rateDriver(
        tripId: widget.trip.id,
        driverId: widget.trip.driver.id,
        rating: _rating,
        comment: finalComment,
      );

      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Rating submitted! Thank you."),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverName = widget.trip.driver.displayName.isNotEmpty 
        ? widget.trip.driver.displayName 
        : widget.trip.driver.username;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. DRIVER AVATAR (Visual Context)
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: AppTheme.surfaceGrey,
                backgroundImage: null, // Add widget.trip.driver.photoUrl here if available
                child: Text(driverName[0].toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 12),
            
            // 2. HEADER TEXT
            const Text("How was your ride?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            Text("with $driverName", style: const TextStyle(fontSize: 14, color: Colors.grey)),
            
            const SizedBox(height: 20),

            // 3. RATING BAR (The Star of the show)
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Colors.amber, size: 40),
              onRatingUpdate: (rating) => setState(() => _rating = rating),
            ),

            const SizedBox(height: 20),

            // 4. FEEDBACK TAGS (Only show if rating is good > 3, or distinct tags for bad rating)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _feedbackTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selected ? _selectedTags.add(tag) : _selectedTags.remove(tag);
                    });
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryBlue : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  checkmarkColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AppTheme.primaryBlue : Colors.transparent)),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 5. COMMENT BOX
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Add a note (optional)...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
              minLines: 2,
            ),

            const SizedBox(height: 24),

            // 6. ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Skip", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRating,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isSubmitting 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Submit Rating", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}