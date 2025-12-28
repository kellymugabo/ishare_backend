import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 🌍 LOCALIZATION IMPORT
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../services/api_service.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';
import '../../constants/app_theme.dart';
import '../profile/edit_profile_screen.dart';
import 'safety_screen.dart';
import 'contact_us_screen.dart';
import 'about_screen.dart';

// 👇 1. IMPORT YOUR REQUESTS SCREEN
import '../driver_requests_screen.dart';

// Provider to get current user data
final currentUserProvider = FutureProvider<UserProfileModel>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.fetchMyProfile();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.surfaceGrey,
      body: userAsync.when(
        data: (profile) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // ==============================
                // 1. BLUE HEADER SECTION
                // ==============================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, bottom: 30),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 47,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: (profile.profilePicture != null)
                              ? NetworkImage(profile.profilePicture!)
                              : null,
                          child: (profile.profilePicture == null)
                              ? Text(
                                  profile.user.username.isNotEmpty
                                      ? profile.user.username[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontSize: 35,
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      Text(
                        "${profile.user.firstName ?? profile.user.username} ${profile.user.lastName ?? ''}".trim(),
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),

                      // Email
                      Text(
                        profile.user.email,
                        style: TextStyle(
                            fontSize: 14, color: Colors.white.withOpacity(0.9)),
                      ),

                      const SizedBox(height: 20),

                      // Edit Profile Button
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EditProfileScreen()),
                          ).then((_) {
                            ref.invalidate(currentUserProvider);
                          });
                        },
                        icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                        label: Text(l10n.editProfile,
                            style: const TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ==============================
                // 2. SETTINGS LIST
                // ==============================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.accountSettings,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 10),

                      // 👇 2. ADD RIDE REQUESTS TILE HERE
                      _buildSettingsTile(
                        Icons.notifications_active_outlined, // Notification icon
                        l10n.rideRequests,                   // "Ride Requests"
                        () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => const DriverRequestsScreen())
                        ),
                      ),

                      _buildSettingsTile(
                        Icons.security, 
                        l10n.safetyCenter, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SafetyScreen())),
                      ),
                      _buildSettingsTile(
                        Icons.info_outline, 
                        l10n.aboutUs, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                      ),
                      _buildSettingsTile(
                        Icons.headset_mic_outlined, 
                        l10n.contactUs, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen())),
                      ),

                      const SizedBox(height: 30),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () async {
                            await ref.read(apiServiceProvider).logout();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            l10n.logOut,
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Scaffold(
          backgroundColor: AppTheme.surfaceGrey,
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration:
              BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
          child: Icon(icon, color: AppTheme.textDark, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}