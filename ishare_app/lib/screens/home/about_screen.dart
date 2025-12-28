import 'package:flutter/material.dart';
// 🌍 LOCALIZATION IMPORT
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants/app_theme.dart'; // ✅ Using shared theme
import '../../constants/app_constants.dart'; // Kept for non-translatable consts

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Professional color palette adjustment
    final bgGrey = Colors.grey[50]!; 

    return Scaffold(
      backgroundColor: bgGrey,
      extendBodyBehindAppBar: true, // Makes header blend better
      appBar: AppBar(
        title: Text(
          l10n.aboutIShare,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        backgroundColor: Colors.transparent, // Let the hero gradient show through
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroSection(context, l10n),
            const SizedBox(height: 20),
            _buildMissionVision(context, l10n),
            _buildFeaturesCompact(context, l10n), // New Compact Version
            _buildHowItWorks(context, l10n),
            _buildImpact(context, l10n),
            _buildVisionAlignment(context, l10n),
            _buildLongTermGoal(context, l10n),
            _buildFooter(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      // Added extra top padding to account for transparent AppBar
      padding: const EdgeInsets.fromLTRB(24, 110, 24, 50),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            const Color(0xFF1565C0), // Deeper professional blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.25),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: const Icon(Icons.directions_car_filled_rounded, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.appName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.appTagline,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ✅ COMPACT FEATURES SECTION (Horizontal Scroll)
  Widget _buildFeaturesCompact(BuildContext context, AppLocalizations l10n) {
    final features = [
      {'icon': Icons.account_circle_outlined, 'title': l10n.feat1Title},
      {'icon': Icons.location_on_outlined, 'title': l10n.feat2Title},
      {'icon': Icons.search_outlined, 'title': l10n.feat3Title},
      {'icon': Icons.payment_outlined, 'title': l10n.feat4Title},
      {'icon': Icons.star_outline_rounded, 'title': l10n.feat5Title},
      {'icon': Icons.health_and_safety_outlined, 'title': l10n.feat6Title},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: _buildSectionTitle(l10n.keyFeatures),
        ),
        SizedBox(
          height: 110, // Fixed small height for compact look
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: features.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final feature = features[index];
              return Container(
                width: 90, // Small width for items
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(feature['icon'] as IconData, color: AppTheme.primaryBlue, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      feature['title'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11, // Small font
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMissionVision(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Vision & Mission combined in a cleaner layout
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04), 
                  blurRadius: 20, 
                  offset: const Offset(0, 5)
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.rocket_launch_rounded, color: AppTheme.primaryBlue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.missionTitle.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGrey, letterSpacing: 1.0)),
                          const SizedBox(height: 4),
                          Text(l10n.missionText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textDark, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.visionTitle.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGrey, letterSpacing: 1.0)),
                          const SizedBox(height: 4),
                          Text(l10n.visionText, style: const TextStyle(fontSize: 14, color: AppTheme.textDark, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context, AppLocalizations l10n) {
    // Simplified, cleaner steps
    final steps = [
      {'step': '1', 'title': l10n.step1Title, 'desc': l10n.step1Desc},
      {'step': '2', 'title': l10n.step2Title, 'desc': l10n.step2Desc},
      {'step': '3', 'title': l10n.step3Title, 'desc': l10n.step3Desc},
      {'step': '4', 'title': l10n.step4Title, 'desc': l10n.step4Desc},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(l10n.howItWorks),
          const SizedBox(height: 20),
          ...steps.map((step) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0,3))],
                  ),
                  child: Center(child: Text(step['step']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step['title']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      const SizedBox(height: 4),
                      Text(step['desc']!, style: const TextStyle(fontSize: 14, color: AppTheme.textGrey, height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildImpact(BuildContext context, AppLocalizations l10n) {
    // Professional clean look instead of colored background
    final impacts = [l10n.impact1, l10n.impact2, l10n.impact3];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(l10n.ourImpact, color: Colors.black87),
          const SizedBox(height: 24),
          ...impacts.map((message) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF43A047), size: 22), // Professional Green
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF424242), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildVisionAlignment(BuildContext context, AppLocalizations l10n) {
    final visions = [l10n.visionPoint1, l10n.visionPoint2, l10n.visionPoint3];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(l10n.vision2050Title),
          const SizedBox(height: 16),
          ...visions.map((point) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.15)), // Thin elegant border
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: AppTheme.primaryBlue, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Text(point, style: const TextStyle(fontSize: 14, height: 1.4, color: AppTheme.textDark))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLongTermGoal(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: 
          
          [const Color(0xFF2C3E50), const Color(0xFF000000)], // Dark professional gradient
          begin: Alignment.topLeft, end: Alignment.bottomRight
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.public, color: Colors.white70, size: 24),
              const SizedBox(width: 10),
              Text(l10n.longTermVision, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.longTermText, style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.white70)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              l10n.countryRwanda, l10n.countryUganda, l10n.countryKenya, 
              l10n.countryTanzania, l10n.countryBurundi, l10n.countryDRC
            ].map((country) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Text(country, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF9FAFB), // Very light grey
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 50),
      child: Column(
        children: [
          Text('© ${AppConstants.copyrightYear} ${l10n.copyrightOwner}', style: const TextStyle(color: AppTheme.textGrey, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(l10n.appTagline.toUpperCase(), style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Color color = AppTheme.primaryBlue}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
      ),
    );
  }
}