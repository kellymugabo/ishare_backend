import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/trip_model.dart';

// Provider that fetches recommended trips for the user
final recommendedTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  
  try {
    // Fetch all trips and return a subset as "recommended"
    // In a real app, this would use a recommendation algorithm
    final allTrips = await apiService.fetchTrips();
    
    // Return up to 5 trips as recommendations
    return allTrips.take(5).toList();
  } catch (e) {
    // Return empty list on error
    return [];
  }
});