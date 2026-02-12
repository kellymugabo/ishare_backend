import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ishare_app/l10n/app_localizations.dart';

// --- Services & Models ---
import '../../constants/app_theme.dart';
import '../../models/trip_model.dart';
import '../../constants/app_constants.dart';
import '../../providers/recommended_trips_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/api_service.dart';

// --- Screens ---
import 'about_screen.dart' as about_ui;
import 'safety_screen.dart' as safety_ui;
import 'profile_screen.dart';
import 'create_trips_screen.dart';
import 'my_trips.dart';
import 'FindRides.dart';
import 'package:ishare_app/features/subscription/subscription_screen.dart';

// ==============================================================================
// STATE MANAGEMENT & ROLE PROVIDER
// ==============================================================================
final selectedIndexProvider = StateProvider<int>((ref) => 0);

// Detects if the current user is a Driver or Passenger
final userRoleProvider = FutureProvider<String?>((ref) async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'user_role');
});

// ==============================================================================
// MAIN WRAPPER
// ==============================================================================
class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final roleAsync = ref.watch(userRoleProvider);
    final l10n = AppLocalizations.of(context)!;

    return roleAsync.when(
      data: (role) {
        final bool isDriver = role == 'driver';

        final List<Widget> screens = [
          const HomeScreen(),       // 0
          const FindRidesScreen(),  // 1
          const MyTripsScreen(),    // 2
          const ProfileScreen(),    // 3
        ];

        return Scaffold(
          // IndexedStack keeps the state of pages alive when switching tabs
          body: IndexedStack(
            index: selectedIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home_rounded, 
                  label: l10n.home, 
                  isActive: selectedIndex == 0, 
                  onTap: () => ref.read(selectedIndexProvider.notifier).state = 0
                ),
                _NavBarItem(
                  icon: isDriver ? Icons.directions_car_filled_rounded : Icons.search_rounded, 
                  label: isDriver ? "My Drive" : l10n.find, 
                  isActive: selectedIndex == 1, 
                  onTap: () => ref.read(selectedIndexProvider.notifier).state = 1
                ),
                _NavBarItem(
                  icon: Icons.confirmation_number_rounded, 
                  label: l10n.trips, 
                  isActive: selectedIndex == 2, 
                  onTap: () => ref.read(selectedIndexProvider.notifier).state = 2
                ),
                _NavBarItem(
                  icon: Icons.person_rounded, 
                  label: l10n.profile, 
                  isActive: selectedIndex == 3, 
                  onTap: () => ref.read(selectedIndexProvider.notifier).state = 3
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const WelcomeScreen(),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppTheme.primaryBlue : AppTheme.textGrey, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.primaryBlue : AppTheme.textGrey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 11
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// HOME SCREEN
// ==============================================================================
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendedAsync = ref.watch(recommendedTripsProvider);
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width > 900 ? 60.0 : 20.0;

    return Scaffold(
      backgroundColor: AppTheme.surfaceGrey,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF06B6D4)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 40),
                  child: const _WelcomeHeader(),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  _SectionHeader(title: l10n.quickActions, actionText: ""),
                  const SizedBox(height: 20),
                  _buildImageActionsGrid(context, ref, size, l10n),
                  
                  const SizedBox(height: 32),
                  const _PremiumBanner(),

                  const SizedBox(height: 50),
                  _SectionHeader(title: l10n.recommended, actionText: l10n.seeAll),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 350,
                    child: recommendedAsync.when(
                      data: (trips) {
                        if (trips.isEmpty) return _buildEmptyState(l10n);
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: trips.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 24),
                          itemBuilder: (context, index) => _ModernTripCard(
                            trip: trips[index],
                            l10n: l10n,
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Center(child: Text("Unable to load trips")),
                    ),
                  ),
                  const SizedBox(height: 50),
                  _SectionHeader(title: l10n.whyIshare, actionText: ""),
                  const SizedBox(height: 20),
                  _buildValueProps(l10n),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageActionsGrid(BuildContext context, WidgetRef ref, Size size, AppLocalizations l10n) {
    final role = ref.watch(userRoleProvider).value;
    final bool isDriver = role == 'driver';

    final actions = [
      _ActionItem(
        title: l10n.findRide,
        subtitle: l10n.bookNow,
        imagePath: 'assets/images/offer.jpeg',
        onTap: () => ref.read(selectedIndexProvider.notifier).state = 1
      ),
      if (isDriver)
        _ActionItem(
          title: l10n.offerRide,
          subtitle: l10n.earnMoney,
          imagePath: 'assets/images/offer_ride.jpeg',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTripScreen()))
        ),
      _ActionItem(
        title: l10n.safetyCenter,
        subtitle: l10n.guidelines,
        imagePath: 'assets/images/about_ishare.jpeg',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const safety_ui.SafetyScreen()))
      ),
      _ActionItem(
        title: l10n.aboutUs,
        subtitle: l10n.ourStory,
        imagePath: 'assets/images/ishare_logo.jpeg',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const about_ui.AboutScreen()))
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size.width > 900 ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 220,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => _ImageActionCard(item: actions[index]),
    );
  }

  Widget _buildValueProps(AppLocalizations l10n) {
    return Column(
      children: [
        _ValuePropTile(icon: Icons.savings_rounded, color: AppTheme.accentPurple, title: l10n.saveCosts, subtitle: l10n.saveCostsDesc),
        const SizedBox(height: 16),
        _ValuePropTile(icon: Icons.forest_rounded, color: Colors.teal, title: l10n.ecoFriendly, subtitle: l10n.ecoFriendlyDesc),
        const SizedBox(height: 16),
        _ValuePropTile(icon: Icons.favorite_rounded, color: Colors.pink, title: l10n.community, subtitle: l10n.communityDesc),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_rounded, size: 60, color: AppTheme.textGrey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(l10n.noRidesAvailable, style: const TextStyle(color: AppTheme.textGrey, fontSize: 16)),
        ],
      ),
    );
  }
}

// ==============================================================================
// SUB-COMPONENTS
// ==============================================================================

class _WelcomeHeader extends ConsumerWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _LanguageChip(currentLocale: currentLocale),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.waving_hand_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.welcomeTitle, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text(l10n.welcomeSubtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            )
          ],
        )
      ],
    );
  }
}

class _LanguageChip extends ConsumerWidget {
  final Locale currentLocale;
  const _LanguageChip({required this.currentLocale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final code = currentLocale.languageCode;
        final newLocale = code == 'en' ? const Locale('rw') : code == 'rw' ? const Locale('fr') : const Locale('en');
        ref.read(localeProvider.notifier).state = newLocale;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
        child: Text(currentLocale.languageCode.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  const _SectionHeader({required this.title, required this.actionText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        if (actionText.isNotEmpty) Text(actionText, style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ActionItem {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;
  _ActionItem({required this.title, required this.subtitle, required this.imagePath, required this.onTap});
}

class _ImageActionCard extends StatelessWidget {
  final _ActionItem item;
  const _ImageActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(item.imagePath, fit: BoxFit.cover, width: double.infinity),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(item.subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ModernTripCard extends StatelessWidget {
  final TripModel trip;
  final AppLocalizations l10n;
  const _ModernTripCard({required this.trip, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.directions_car, color: AppTheme.primaryBlue),
              Text(AppConstants.formatCurrency(trip.pricePerSeat), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const Spacer(),
          Text(trip.startLocationName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Icon(Icons.arrow_downward, size: 16, color: Colors.grey),
          Text(trip.destinationName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(l10n.seatsLeft(trip.availableSeats), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ValuePropTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _ValuePropTile({required this.icon, required this.color, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }
}

// ==============================================================================
// PREMIUM BANNER
// ==============================================================================
class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
        leading: const Icon(Icons.workspace_premium, color: Colors.amber, size: 30),
        title: const Text("Upgrade to Premium", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: const Text("Unlock exclusive discounts", style: TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      ),
    );
  }
}