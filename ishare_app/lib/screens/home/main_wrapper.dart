import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// --- Services & Models ---
import '../../constants/app_theme.dart';
import '../../models/trip_model.dart';
import '../../constants/app_constants.dart';
import '../../providers/recommended_trips_provider.dart';
import '../../providers/locale_provider.dart';

// --- Screens ---
import 'about_screen.dart' as about_ui;
import 'safety_screen.dart' as safety_ui;
import 'profile_screen.dart';
import 'create_trips_screen.dart';
import 'my_trips.dart';
import 'FindRides.dart';


// ==============================================================================
// STATE MANAGEMENT
// ==============================================================================
final selectedIndexProvider = StateProvider<int>((ref) => 0);

// ==============================================================================
// MAIN WRAPPER (Bottom Navigation Only)
// ==============================================================================
class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final l10n = AppLocalizations.of(context)!;

    // ✅ CLEANED UP: Only 4 Screens
    final List<Widget> screens = [
      const HomeScreen(),       // 0
      const FindRidesScreen(),  // 1
      const MyTripsScreen(),    // 2 (Includes History)
      const ProfileScreen(),    // 3
    ];

    return Scaffold(
      extendBody: false,
      body: screens[selectedIndex], // Safe because we removed index 4
      bottomNavigationBar: Container(
        height: 60,
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
            // 0. Home
            _NavBarItem(
              icon: Icons.home_rounded, 
              label: l10n.home, 
              isActive: selectedIndex == 0, 
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 0
            ),
            
            // 1. Search
            _NavBarItem(
              icon: Icons.search_rounded, 
              label: l10n.find, 
              isActive: selectedIndex == 1, 
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 1
            ),
            
            // 2. Trips (History is here now)
            _NavBarItem(
              icon: Icons.directions_car_rounded, 
              label: l10n.trips, 
              isActive: selectedIndex == 2, 
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 2
            ),

            // ❌ REMOVED: History Tab (Index 3) to prevent errors

            // 3. Profile
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
          Icon(icon, color: isActive ? AppTheme.primaryBlue : AppTheme.textGrey, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.primaryBlue : AppTheme.textGrey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 10
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
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;
    final horizontalPadding = isDesktop ? 60.0 : 20.0;

    return Scaffold(
      backgroundColor: AppTheme.surfaceGrey,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Welcome Header
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E3A8A),
                        Color(0xFF2563EB),
                        Color(0xFF06B6D4)
                      ],
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
                      
                      // Quick Actions Section
                      _SectionHeader(title: l10n.quickActions, actionText: ""),
                      const SizedBox(height: 20),
                      _buildImageActionsGrid(context, ref, isDesktop, isTablet, l10n),
                      
                      const SizedBox(height: 50),
                      
                      // Recommended Trips Section
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
                              clipBehavior: Clip.none,
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              itemCount: trips.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 24),
                              itemBuilder: (context, index) => _ModernTripCard(
                                trip: trips[index],
                                isDesktop: isDesktop,
                                l10n: l10n,
                              ),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const Center(child: Text("Unable to load trips")),
                        ),
                      ),
                      
                      const SizedBox(height: 50),
                      
                      // Why iShare Section
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
        ),
      ),
    );
  }

  Widget _buildImageActionsGrid(BuildContext context, WidgetRef ref, bool isDesktop, bool isTablet, AppLocalizations l10n) {
    final actions = [
      _ActionItem(
        title: l10n.findRide,
        subtitle: l10n.bookNow,
        imagePath: 'assets/images/offer.jpeg',
        onTap: () => ref.read(selectedIndexProvider.notifier).state = 1
      ),
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

    if (isDesktop || isTablet) {
      return Row(
        children: actions.map((a) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _ImageActionCard(item: a)
          )
        )).toList()
      );
    }
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _ImageActionCard(item: actions[0])),
            const SizedBox(width: 16),
            Expanded(child: _ImageActionCard(item: actions[1]))
          ]
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _ImageActionCard(item: actions[2])),
            const SizedBox(width: 16),
            Expanded(child: _ImageActionCard(item: actions[3]))
          ]
        ),
      ],
    );
  }

  Widget _buildValueProps(AppLocalizations l10n) {
    return Column(
      children: [
        _ValuePropTile(
          icon: Icons.savings_rounded,
          color: AppTheme.accentPurple,
          title: l10n.saveCosts,
          subtitle: l10n.saveCostsDesc
        ),
        const SizedBox(height: 16),
        _ValuePropTile(
          icon: Icons.forest_rounded,
          color: Colors.teal,
          title: l10n.ecoFriendly,
          subtitle: l10n.ecoFriendlyDesc
        ),
        const SizedBox(height: 16),
        _ValuePropTile(
          icon: Icons.favorite_rounded,
          color: Colors.pink,
          title: l10n.community,
          subtitle: l10n.communityDesc
        ),
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
          Text(
            l10n.noRidesAvailable,
            style: const TextStyle(color: AppTheme.textGrey, fontSize: 16)
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// WELCOME HEADER
// ==============================================================================
class _WelcomeHeader extends ConsumerWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          left: -40,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Switcher
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    final currentCode = currentLocale.languageCode;
                    final Locale newLocale;
                    if (currentCode == 'en') {
                      newLocale = const Locale('rw');
                    } else if (currentCode == 'rw') {
                      newLocale = const Locale('fr');
                    } else {
                      newLocale = const Locale('en');
                    }
                    ref.read(localeProvider.notifier).state = newLocale;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentLocale.languageCode == 'en' ? '🇺🇸' : 
                          currentLocale.languageCode == 'rw' ? '🇷🇼' : '🇫🇷',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currentLocale.languageCode == 'en' ? 'EN' : 
                          currentLocale.languageCode == 'rw' ? 'RW' : 'FR',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Welcome Message
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.waving_hand_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.welcomeTitle,
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.1),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.welcomeSubtitle,
                          style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Stats Row
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatBadge(icon: Icons.people_rounded, label: l10n.statUsers, value: "5K+"),
                  Container(width: 1.5, height: 50, color: Colors.white.withOpacity(0.3)),
                  _StatBadge(icon: Icons.route_rounded, label: l10n.statTrips, value: "200+"),
                  Container(width: 1.5, height: 50, color: Colors.white.withOpacity(0.3)),
                  _StatBadge(icon: Icons.star_rounded, label: l10n.statRating, value: "4.8"),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatBadge({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1, // Prevents Overflow
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// HELPER COMPONENTS
// ==============================================================================
class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  const _SectionHeader({required this.title, required this.actionText});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
        if (actionText.isNotEmpty)
          Text(actionText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue))
      ]
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
    return Container(
      height: 250,
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 70,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(item.imagePath, fit: BoxFit.cover, errorBuilder: (ctx, _, __) => Container(color: AppTheme.surfaceGrey)),
                      Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppTheme.textDark.withOpacity(0.05)])))
                    ]
                  )
                )
              ),
              Expanded(
                flex: 30,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(item.subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.textGrey, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)
                    ]
                  )
                )
              )
            ]
          )
        )
      )
    );
  }
}

class _ModernTripCard extends StatelessWidget {
  final TripModel trip;
  final bool isDesktop;
  final AppLocalizations l10n;
  
  const _ModernTripCard({required this.trip, required this.isDesktop, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isDesktop ? 360 : 320,
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: AppTheme.surfaceGrey, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.textDark),
                          const SizedBox(width: 8),
                          Text(l10n.today, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark))
                        ]
                      )
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: AppTheme.accentTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(l10n.seatsLeft(trip.availableSeats), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accentTeal))
                    )
                  ]
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.circle, size: 12, color: AppTheme.primaryBlue),
                          Expanded(child: Container(width: 2, color: AppTheme.surfaceGrey)),
                          const Icon(Icons.location_on, size: 18, color: AppTheme.accentTeal)
                        ]
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip.startLocationName, 
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textDark),
                                  maxLines: 1, 
                                  overflow: TextOverflow.ellipsis
                                ),
                                const SizedBox(height: 4),
                                Text(l10n.pickUp, style: const TextStyle(fontSize: 13, color: AppTheme.textGrey))
                              ]
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip.destinationName,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textDark),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis
                                ),
                                const SizedBox(height: 4),
                                Text(l10n.dropOff, style: const TextStyle(fontSize: 13, color: AppTheme.textGrey))
                              ]
                            )
                          ]
                        )
                      )
                    ]
                  )
                ),
                const SizedBox(height: 24),
                const Divider(height: 1, color: AppTheme.surfaceGrey),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.totalPrice, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textGrey)),
                        const SizedBox(height: 4),
                        Text(AppConstants.formatCurrency(trip.pricePerSeat), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue, letterSpacing: -0.5))
                      ]
                    ),
                    Container(
                      height: 44, width: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                      ),
                      child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20)
                    )
                  ]
                )
              ]
            )
          )
        )
      )
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow, border: Border.all(color: AppTheme.surfaceGrey)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textDark)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.4))
              ]
            )
          )
        ]
      )
    );
  }
}