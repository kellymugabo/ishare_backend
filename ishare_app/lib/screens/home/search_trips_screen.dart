import 'package:flutter/material.dart';
// 🌍 LOCALIZATION IMPORT
import 'package:ishare_app/l10n/app_localizations.dart';

import '../../constants/app_theme.dart'; // ✅ Using shared theme

class SearchTripsScreen extends StatelessWidget {
  const SearchTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.surfaceGrey,
      appBar: AppBar(
        title: Text(
          l10n.findRide, // "Find a Ride"
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.softShadow,
                ),
                child: const Icon(
                  Icons.location_searching_rounded,
                  size: 80,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.searchComingSoon, // "Search functionality coming soon!"
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.searchFeatureDesc, // "You will be able to search..."
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textGrey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}