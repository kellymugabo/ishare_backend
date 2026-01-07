import 'dart:async';
import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Required for state
import 'package:ishare_app/l10n/app_localizations.dart';

import '../../constants/app_theme.dart';
import '../../providers/locale_provider.dart'; // ✅ Import your locale provider
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> with TickerProviderStateMixin {
  // 🎬 Animation Controllers
  late AnimationController _bgController;
  late AnimationController _textController;
  late Animation<double> _bgAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // 🎠 Carousel Content
  int _currentPage = 0;
  final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 1. Background Zoom Animation (The "Ken Burns" Effect)
    _bgController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true); 

    _bgAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );

    // 2. Text Entrance Animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic)),
    );

    // 3. Auto-Slide Carousel
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuint,
        );
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _textController.dispose();
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    // ✅ LOCALIZED DATA (Updates automatically when language changes)
    final List<Map<String, String>> onboardingData = [
      {
        "title": l10n.onboardTitle1,
        "desc": l10n.onboardDesc1
      },
      {
        "title": l10n.onboardTitle2,
        "desc": l10n.onboardDesc2
      },
      {
        "title": l10n.onboardTitle3,
        "desc": l10n.onboardDesc3
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ====================================================
          // 1. CINEMATIC ANIMATED BACKGROUND
          // ====================================================
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bgAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        // You can replace this with 'assets/images/welcome_bg.png' if you have it locally
                        image: const NetworkImage(
                          'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?q=80&w=1000&auto=format&fit=crop',
                        ),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3), 
                          BlendMode.darken
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 🌈 Gradient Overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.3),
                    AppTheme.primaryBlue.withOpacity(0.8),
                    AppTheme.primaryBlue,
                  ],
                  stops: const [0.0, 0.5, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // ====================================================
          // 2. CONTENT LAYER
          // ====================================================
          SafeArea(
            child: Column(
              children: [
                // Top Bar: Branding & Language Switcher
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo / Brand Name
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Icon(Icons.directions_car, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.appName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),

                      // 🌍 LANGUAGE SELECTOR (Popup Menu)
                      PopupMenuButton<Locale>(
                        onSelected: (Locale newLocale) {
                          ref.read(localeProvider.notifier).state = newLocale;
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        color: Colors.white,
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: Locale('en'),
                            child: _LanguageItem(flag: "🇺🇸", name: "English"),
                          ),
                          const PopupMenuItem(
                            value: Locale('rw'),
                            child: _LanguageItem(flag: "🇷🇼", name: "Kinyarwanda"),
                          ),
                          const PopupMenuItem(
                            value: Locale('fr'),
                            child: _LanguageItem(flag: "🇫🇷", name: "Français"),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.language, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                currentLocale.languageCode == 'en' ? 'EN' : 
                                currentLocale.languageCode == 'rw' ? 'RW' : 'FR',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(), // Pushes content to bottom

                // 🎡 CAROUSEL & ACTIONS CARD
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🎠 Text Carousel
                          SizedBox(
                            height: 140,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: onboardingData.length,
                              onPageChanged: (index) {
                                setState(() => _currentPage = index);
                              },
                              itemBuilder: (context, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      onboardingData[index]['title']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textDark,
                                        height: 1.1,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      onboardingData[index]['desc']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[600],
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          // 🔵 Page Indicators (Dots)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              onboardingData.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                height: 6,
                                width: _currentPage == index ? 24 : 6,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? AppTheme.primaryBlue
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // 🚀 Primary Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                l10n.getStarted, 
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 🗝️ Secondary Action
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${l10n.alreadyHaveAccount} ", 
                                style: TextStyle(
                                  color: Colors.grey[600], 
                                  fontSize: 14
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  );
                                },
                                child: Text(
                                  l10n.login,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
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
}

// ✨ Helper for Language Menu Items
class _LanguageItem extends StatelessWidget {
  final String flag;
  final String name;
  const _LanguageItem({required this.flag, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(flag, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}