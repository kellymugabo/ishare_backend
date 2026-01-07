import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// 🌍 LOCALIZATION IMPORT
import 'package:ishare_app/l10n/app_localizations.dart';

import '../../constants/app_theme.dart'; // ✅ Using shared theme

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  // 📍 LOCATION: Gishushu, Gasabo, Kigali
  // We keep these coordinates to generate the link
  final double _lat = -1.9515;
  final double _lng = 30.1028;

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=iShare Inquiry',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _openMaps() async {
    // 🗺️ Universal Google Maps Link
    // This opens the external app directly
    final Uri googleMapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$_lat,$_lng'
    );
    
    try {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.surfaceGrey,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(l10n),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildWelcomeCard(l10n),
                const SizedBox(height: 32),
                
                // 📍 Location Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.location_on, color: Colors.red[700], size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.findUsHere, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 🗺️ STATIC MAP CARD (No API Key Needed)
                _buildStaticMapCard(l10n),

                const SizedBox(height: 40),
                _buildGetInTouchHeader(l10n),
                const SizedBox(height: 20),
                _buildContactCards(l10n),
                const SizedBox(height: 40),
                _buildOfficeHours(l10n),
                const SizedBox(height: 40),
                _buildSocialMedia(l10n),
                const SizedBox(height: 40),
                _buildSendMessageCTA(l10n),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSliverAppBar(AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryBlue,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
        title: Text(
          l10n.contactUs,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1565C0), // Darker Blue
                    AppTheme.primaryBlue,
                  ],
                ),
              ),
            ),
            Positioned(
              right: -40,
              top: -40,
              child: Icon(
                Icons.support_agent_rounded,
                size: 200,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.waving_hand, color: AppTheme.primaryBlue, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.hereToHelp,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.reachOutMsg,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textGrey, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticMapCard(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        child: InkWell(
          onTap: _openMaps,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              // Simulating a map background with a gradient
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[100]!, Colors.grey[50]!],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Pattern (Optional)
                Opacity(
                  opacity: 0.05,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
                    itemBuilder: (_, __) => const Icon(Icons.map, size: 40),
                    itemCount: 24,
                  ),
                ),
                
                // Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.location_on, size: 40, color: Colors.red[700]),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gishushu, Kigali',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gasabo District',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            l10n.directions, // "Directions"
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGetInTouchHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.phone_in_talk, color: Colors.blue[700], size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.getInTouch,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCards(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _CompactContactCard(
                  icon: Icons.location_on_rounded,
                  title: l10n.address,
                  content: 'Gishushu, Gasabo\nKigali',
                  gradient: LinearGradient(colors: [Colors.red[400]!, Colors.red[600]!]),
                  onTap: _openMaps,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CompactContactCard(
                  icon: Icons.phone_rounded,
                  title: l10n.callUs,
                  content: '+250 793\n487 065',
                  gradient: LinearGradient(colors: [Colors.green[400]!, Colors.green[600]!]),
                  onTap: () => _launchPhone('+250793487065'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CompactContactCard(
                  icon: Icons.email_rounded,
                  title: l10n.email,
                  content: 'support@\nishare.rw',
                  gradient: LinearGradient(colors: [Colors.blue[400]!, Colors.blue[600]!]),
                  onTap: () => _launchEmail('support@ishare.rw'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CompactContactCard(
                  icon: Icons.access_time_rounded,
                  title: l10n.hours,
                  content: 'Mon-Fri\n8AM-6PM',
                  gradient: LinearGradient(colors: [Colors.orange[400]!, Colors.orange[600]!]),
                  onTap: null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeHours(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: AppTheme.primaryBlue, size: 24),
                const SizedBox(width: 12),
                Text(
                  l10n.officeHours,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _HoursRow(day: l10n.monFri, time: '8:00 AM - 6:00 PM'),
            const SizedBox(height: 12),
            _HoursRow(day: l10n.saturday, time: '9:00 AM - 2:00 PM'),
            const SizedBox(height: 12),
            _HoursRow(day: l10n.sunday, time: l10n.closed, isClosed: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMedia(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.connectWithUs,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.textDark),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ModernSocialButton(
                icon: Icons.facebook,
                label: 'Facebook',
                color: const Color(0xFF1877F2),
                onTap: () => launchUrl(Uri.parse('https://facebook.com/ishare'), mode: LaunchMode.externalApplication),
              ),
              _ModernSocialButton(
                icon: Icons.alternate_email,
                label: 'Twitter',
                color: const Color(0xFF1DA1F2),
                onTap: () => launchUrl(Uri.parse('https://twitter.com/ishare'), mode: LaunchMode.externalApplication),
              ),
              _ModernSocialButton(
                icon: Icons.camera_alt,
                label: 'Instagram',
                color: const Color(0xFFE4405F),
                onTap: () => launchUrl(Uri.parse('https://instagram.com/murenzi893'), mode: LaunchMode.externalApplication),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSendMessageCTA(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue,
              Color(0xFF1565C0),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.haveQuestions,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.sendMessageDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchEmail('support@ishare.rw'),
                icon: const Icon(Icons.send_rounded),
                label: Text(
                  l10n.sendMessage,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HELPER CLASSES ---

class _CompactContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Gradient gradient;
  final VoidCallback? onTap;

  const _CompactContactCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: gradient.colors.first.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String day;
  final String time;
  final bool isClosed;

  const _HoursRow({
    required this.day,
    required this.time,
    this.isClosed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: const TextStyle(fontSize: 14, color: AppTheme.textGrey, fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isClosed ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            time,
            style: TextStyle(fontSize: 13, color: isClosed ? Colors.red[700] : Colors.green[700], fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _ModernSocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModernSocialButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: color,
          borderRadius: BorderRadius.circular(20),
          elevation: 4,
          shadowColor: color.withOpacity(0.4),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontWeight: FontWeight.w600)),
      ],
    );
  }
}