import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// 🌍 LOCALIZATION IMPORT
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../constants/app_theme.dart';
import '../../widgets/verification_badge.dart';

/// Provider to fetch specific user profile
final publicProfileProvider = FutureProvider.family<UserProfileModel, int>(
  (ref, userId) async {
    final apiService = ref.read(apiServiceProvider);
    return await apiService.getUserProfile(userId);
  },
);

/// Public profile screen displaying user information, vehicle details, and reviews
class PublicProfileScreen extends ConsumerWidget {
  final int userId;
  final String userName;

  const PublicProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicProfileProvider(userId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Softer background grey
      extendBodyBehindAppBar: true, // Allows header to slide behind app bar
      appBar: AppBar(
        title: profileAsync.when(
          data: (profile) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  profile.user.username.isNotEmpty ? profile.user.username : userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700, 
                    color: AppTheme.textDark,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (profile.user.isVerified)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: VerificationBadge(size: 18),
                ),
            ],
          ),
          loading: () => Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          error: (_, __) => Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const BackButton(color: AppTheme.textDark),
        ),
      ),

      body: profileAsync.when(
        data: (profile) => _buildProfileContent(profile, context, l10n),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorState(error, l10n),
      ),
    );
  }

  // ✅ MAIN CONTENT BUILDER
  Widget _buildProfileContent(UserProfileModel profile, BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      // Removed top padding so the header can stretch up
      child: Column(
        children: [
          _buildProfileHeader(profile),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildAboutSection(profile, context, l10n),

                if (profile.role == 'driver') ...[
                  const SizedBox(height: 24),
                  _buildVehicleSection(profile, l10n),
                ],

                const SizedBox(height: 24),
                _buildReviewsSection(profile.reviews, l10n),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HEADER SECTION (Avatar + Rating) ---

  Widget _buildProfileHeader(UserProfileModel profile) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000), // Very subtle shadow
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Spacer for AppBar
          const SizedBox(height: 100),
          _buildAvatar(profile),
          const SizedBox(height: 16),
          _buildRatingAndRole(profile),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAvatar(UserProfileModel profile) {
    final hasAvatar = profile.avatar != null && profile.avatar!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade100, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 55,
        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
        backgroundImage: hasAvatar
            ? NetworkImage(_getValidUrl(profile.avatar!))
            : null,
        child: !hasAvatar
            ? Text(
                _getInitials(profile.user.username),
                style: const TextStyle(fontSize: 40, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
              )
            : null,
      ),
    );
  }

  Widget _buildRatingAndRole(UserProfileModel profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Rating Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                profile.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB07200), // Darker amber for text
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildRoleBadge(profile.role),
      ],
    );
  }

  Widget _buildRoleBadge(String? role) {
    final isDriver = role == 'driver';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDriver ? AppTheme.primaryBlue : Colors.green,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDriver ? AppTheme.primaryBlue : Colors.green).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Text(
        (role ?? 'passenger').toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // --- ABOUT SECTION ---

  Widget _buildAboutSection(UserProfileModel profile, BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.aboutSection, Icons.person_outline),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: _modernCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.bio?.isNotEmpty == true
                    ? profile.bio!
                    : l10n.noBio,
                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 15,
                  height: 1.6, // Better readability
                ),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1, color: Color(0xFFEEEEEE)), // Subtle divider
              const SizedBox(height: 16),
              _buildJoinedDate(profile.createdAt, context, l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJoinedDate(DateTime createdAt, BuildContext context, AppLocalizations l10n) {
    String formattedDate;
    try {
      final localeCode = Localizations.localeOf(context).languageCode;
      formattedDate = DateFormat('MMMM yyyy', localeCode).format(createdAt);
    } catch (e) {
      formattedDate = DateFormat('MMMM yyyy', 'en').format(createdAt);
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
          child: const Icon(
            Icons.calendar_month_rounded,
            size: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          l10n.joinedDate(formattedDate),
          style: const TextStyle(
            color: AppTheme.textGrey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // --- VEHICLE SECTION ---

  Widget _buildVehicleSection(UserProfileModel profile, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.vehicleSection, Icons.directions_car_outlined),
        Container(
          width: double.infinity,
          decoration: _modernCardDecoration(),
          clipBehavior: Clip.antiAlias, // Ensures image corners are rounded
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVehicleImage(profile.vehiclePhoto, l10n),
              _buildVehicleDetails(profile, l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleImage(String? vehiclePhoto, AppLocalizations l10n) {
    final hasPhoto = vehiclePhoto != null && vehiclePhoto.isNotEmpty;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: hasPhoto
          ? Image.network(
              _getValidUrl(vehiclePhoto),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImageLoadingState();
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildVehiclePlaceholder(l10n);
              },
            )
          : _buildVehiclePlaceholder(l10n),
    );
  }

  Widget _buildImageLoadingState() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildVehiclePlaceholder(AppLocalizations l10n) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            l10n.noCarPhoto,
            style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetails(UserProfileModel profile, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E0), // Soft orange bg
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_taxi_rounded,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.vehicleModel?.isNotEmpty == true
                      ? profile.vehicleModel!
                      : l10n.unknownModel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    profile.vehiclePlateNumber?.isNotEmpty == true
                        ? profile.vehiclePlateNumber!
                        : l10n.noPlateInfo,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- REVIEWS SECTION ---

  Widget _buildReviewsSection(List<ReviewModel> reviews, AppLocalizations l10n) {
    if (reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        decoration: _modernCardDecoration(),
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey.shade200),
            const SizedBox(height: 12),
            Text(
              "No reviews yet",
              style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Reviews (${reviews.length})", Icons.star_outline_rounded),
        ...reviews.map((review) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: _modernCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Avatar + Name + Date
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                        backgroundImage: review.raterAvatar != null
                            ? NetworkImage(_getValidUrl(review.raterAvatar!))
                            : null,
                        child: review.raterAvatar == null
                            ? Text(
                                review.raterName.isNotEmpty ? review.raterName[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.raterName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                            ),
                            Text(
                              DateFormat('MMM d, y').format(review.createdAt),
                              style: TextStyle(color: Colors.grey[500], fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      // Star Score
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              review.score.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.amber[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // The Comment
                  if (review.comment.isNotEmpty)
                    Text(
                      review.comment,
                      style: const TextStyle(
                        color: Color(0xFF555555), 
                        height: 1.5, 
                        fontSize: 14
                      ),
                    ),
                ],
              ),
            )),
      ],
    );
  }

  // --- STYLING HELPERS ---

  /// Replaces generic card decoration with a specific clean look
  BoxDecoration _modernCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4, top: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.error_outline, size: 40, color: Colors.red.shade400),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadProfile,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textGrey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String username) {
    if (username.isEmpty) return '?';
    return username[0].toUpperCase();
  }

  String _getValidUrl(String url) {
    if (url.startsWith('http')) {
      return url;
    }
    const baseUrl = "http://127.0.0.1:8000";
    return url.startsWith('/') ? "$baseUrl$url" : "$baseUrl/$url";
  }
}