import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../services/api_service.dart';
import '../../constants/app_theme.dart';
import '../home/main_wrapper.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

// 👇 IMPORTANT: Import the file where 'currentUserProvider' is defined
import '../home/profile_screen.dart'; 

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  late AnimationController _entranceController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isDriver = false; 

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shakeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ ROBUST LOGIN LOGIC
  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;

    // 1. Input Validation
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _shakeController.forward().then((_) => _shakeController.reset());
      HapticFeedback.heavyImpact();
      _showErrorSnackBar(l10n.fillAllFields);
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final initialApi = ref.read(apiServiceProvider);

      // 2. Perform Login (Get Token)
      final response = await initialApi.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        role: _isDriver ? 'driver' : 'passenger',
      );

      var token = response.data['access'];
      if (token == null) throw Exception("No token received");

      // 3. Save Token Temporarily
      await _storage.write(key: 'auth_token', value: token);

      // ============================================================
      // 🛑 CRITICAL FIX: REFRESH CONNECTION & STATE
      // ============================================================
      
      // A. Force ApiService to restart so it reads the NEW token from storage
      ref.invalidate(apiServiceProvider);
      
      // B. Clear any old user profile data from memory (Reset Profile Screen)
      ref.invalidate(currentUserProvider);

      // C. Get the NEW ApiService (now authenticated with the new token)
      final freshApi = ref.read(apiServiceProvider);

      // ============================================================
      // 🛡️ STRICT ROLE VERIFICATION
      // ============================================================
      try {
        final userProfile = await freshApi.fetchMyProfile();
        
        // ✅ FIX: Safe access to role with default value to prevent crash
        final String realRole = (userProfile.role ?? "").toLowerCase();

        // CASE A: User selected "Driver" but is actually a "Passenger"
        if (_isDriver && realRole != 'driver') {
          throw "Access Denied: You are not a registered Driver.";
        }
        
        // CASE B: User selected "Passenger" but is actually a "Driver"
        if (!_isDriver && realRole == 'driver') {
          throw "Access Denied: You are a Driver. Please switch to Driver login.";
        }

        // Success: Save role
        await _storage.write(key: 'user_role', value: realRole);

      } catch (roleError) {
        // If Role Mismatch: Logout immediately
        await _storage.deleteAll();
        ref.invalidate(apiServiceProvider);
        
        // Show error in SnackBar
        throw roleError.toString(); 
      }
      // ============================================================

      // 4. Navigate to Home (MainWrapper)
      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainWrapper(),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _shakeController.forward().then((_) => _shakeController.reset());
        HapticFeedback.vibrate();

        // Clean up error message for display
        String msg = e.toString().replaceAll("Exception: ", "");
        
        if (msg.contains("401") || msg.contains("400")) {
          msg = l10n.incorrectCredentials;
        }
        
        _showErrorSnackBar(msg);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width > 400 ? 28.0 : 20.0;
    
    // Calculate width here instead of using LayoutBuilder inside Column
    final double fullButtonWidth = size.width - (horizontalPadding * 2); 

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, 
      body: Stack(
        children: [
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.primaryBlue.withOpacity(0.2), Colors.white.withOpacity(0)],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false, 
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                        
                        const SizedBox(height: 20),

                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [AppTheme.primaryBlue, Color(0xFF4C8CFF)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: Text(
                                    l10n.welcomeBack,
                                    style: const TextStyle(
                                      fontSize: 38, fontWeight: FontWeight.w900,
                                      color: Colors.white, height: 1.1, letterSpacing: -1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  l10n.loginSecurely,
                                  style: TextStyle(
                                    fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        _buildRoleSelector(),
                        
                        const SizedBox(height: 25),

                        AnimatedBuilder(
                          animation: _shakeController,
                          builder: (context, child) {
                            final sineValue = sin(4 * pi * _shakeController.value);
                            return Transform.translate(
                              offset: Offset(sineValue * 10, 0),
                              child: child,
                            );
                          },
                          child: Column(
                            children: [
                              _buildGlassInput(
                                controller: _usernameController,
                                hint: l10n.username,
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 20),
                              _buildGlassInput(
                                controller: _passwordController,
                                hint: l10n.password,
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                              ),
                            ],
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                              );
                            },
                            child: Text(
                              l10n.forgotPassword,
                              style: TextStyle(
                                color: AppTheme.primaryBlue.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _isLoading ? 60 : fullButtonWidth,
                            height: 56,
                            curve: Curves.easeInOut,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(_isLoading ? 50 : 18),
                                ),
                                elevation: _isLoading ? 0 : 8,
                                shadowColor: AppTheme.primaryBlue.withOpacity(0.4),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24, height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${l10n.login} (${_isDriver ? "Driver" : "Passenger"})", 
                                          style: const TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${l10n.newToApp} ", style: TextStyle(color: Colors.grey[600])),
                              GestureDetector(
                                onTap: () => Navigator.pushReplacement(
                                  context, 
                                  MaterialPageRoute(builder: (_) => const RegisterScreen())
                                ),
                                child: Text(
                                  l10n.register,
                                  style: const TextStyle(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildRoleSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedAlign(
                alignment: _isDriver ? Alignment.centerRight : Alignment.centerLeft,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Container(
                  width: constraints.maxWidth / 2,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isDriver = false),
                      behavior: HitTestBehavior.translucent,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: !_isDriver ? AppTheme.primaryBlue : Colors.grey[500],
                          ),
                          child: const Text("Passenger"),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isDriver = true),
                      behavior: HitTestBehavior.translucent,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: _isDriver ? AppTheme.primaryBlue : Colors.grey[500],
                          ),
                          child: const Text("Driver"),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(icon, color: AppTheme.primaryBlue),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    color: Colors.grey[400],
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        ),
      ),
    );
  }
}