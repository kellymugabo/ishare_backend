import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// 🌍 LOCALIZATION IMPORT
import 'package:ishare_app/l10n/app_localizations.dart';

import '../../constants/app_theme.dart'; // ✅ Using shared theme

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  bool _sosActivated = false;

  void _activateSOS(AppLocalizations l10n) {
    setState(() => _sosActivated = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            Text(l10n.sosActivated, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.emergencyAlertSent, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text('• ${l10n.emergencyContacts}'),
            Text('• ${l10n.ishareSupport}'),
            Text('• ${l10n.currentTripDriver}'),
            const SizedBox(height: 16),
            Text(l10n.liveLocationShared, style: const TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _callEmergency();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(l10n.call112),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _sosActivated = false);
            },
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Future<void> _callEmergency() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to make call')),
        );
      }
    }
  }

  Future<void> _makeCall(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to make call')),
        );
      }
    }
  }

  Future<void> _shareLocation(AppLocalizations l10n) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.shareLocation),
        content: Text(l10n.shareLocationDesc), // "Your current location will be shared..."
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.locationSharedSuccess),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
            child: Text(l10n.share),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Define contacts inside build to access l10n
    final List<EmergencyContact> emergencyContacts = [
      EmergencyContact(name: l10n.police, number: '112', icon: Icons.local_police, color: AppTheme.primaryBlue),
      EmergencyContact(name: l10n.emergencyServices, number: '112', icon: Icons.emergency, color: Colors.red),
      EmergencyContact(name: l10n.fireBrigade, number: '112', icon: Icons.fire_truck, color: Colors.orange),
      EmergencyContact(name: l10n.ambulance, number: '912', icon: Icons.local_hospital, color: Colors.green),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.safetyCenter, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SOS Button Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceGrey,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.emergencySOS,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sosActivated ? l10n.sosActive : l10n.pressAndHold,
                    style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onLongPress: _sosActivated ? null : () => _activateSOS(l10n),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _sosActivated 
                            ? [Colors.red.shade800, Colors.red.shade600] 
                            : [Colors.red.shade500, Colors.red.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.touch_app, color: Colors.white, size: 30),
                            Text(
                              'SOS',
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_sosActivated) ...[
                    const SizedBox(height: 16),
                    Text(
                      '🚨 ${l10n.sosActive}',
                      style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.quickActions, // "Quick Actions"
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.location_on,
                          label: l10n.shareLocation,
                          color: AppTheme.primaryBlue,
                          onTap: () => _shareLocation(l10n),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.cancel_outlined,
                          label: l10n.cancelTrip,
                          color: Colors.orange,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.tripCancelRequest)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Emergency Contacts
            Container(
              color: AppTheme.surfaceGrey,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.emergencyContacts,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 16),
                  ...emergencyContacts.map((contact) => _EmergencyContactCard(
                    contact: contact,
                    onCall: () => _makeCall(contact.number),
                    l10n: l10n,
                  )),
                ],
              ),
            ),

            // Safety Tips
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.safetyTips,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 16),
                  _SafetyTipCard(
                    icon: Icons.check_circle,
                    title: l10n.verifyDriver,
                    description: l10n.verifyDriverDesc,
                  ),
                  _SafetyTipCard(
                    icon: Icons.people,
                    title: l10n.shareTrip,
                    description: l10n.shareTripDesc,
                  ),
                  _SafetyTipCard(
                    icon: Icons.phone,
                    title: l10n.stayConnected,
                    description: l10n.stayConnectedDesc,
                  ),
                  _SafetyTipCard(
                    icon: Icons.star,
                    title: l10n.checkRatings,
                    description: l10n.checkRatingsDesc,
                  ),
                  _SafetyTipCard(
                    icon: Icons.report,
                    title: l10n.reportIssues,
                    description: l10n.reportIssuesDesc,
                  ),
                ],
              ),
            ),

            // Trust & Safety Info
            Container(
              color: AppTheme.softBlue,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield, color: AppTheme.primaryBlue, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        l10n.safetyMatters, // "Your Safety Matters"
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.safetyCommitment,
                    style: const TextStyle(height: 1.5, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '24/7 Support: support@ishare.rw',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyContact {
  final String name;
  final String number;
  final IconData icon;
  final Color color;

  EmergencyContact({
    required this.name,
    required this.number,
    required this.icon,
    required this.color,
  });
}

class _EmergencyContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback onCall;
  final AppLocalizations l10n;

  const _EmergencyContactCard({required this.contact, required this.onCall, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: contact.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(contact.icon, color: contact.color, size: 28),
        ),
        title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(contact.number),
        trailing: SizedBox(
          width: 90,
          child: ElevatedButton.icon(
            onPressed: onCall,
            icon: const Icon(Icons.phone, size: 18),
            label: Text(l10n.call), // "Call"
            style: ElevatedButton.styleFrom(
              backgroundColor: contact.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyTipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SafetyTipCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.successGreen, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: AppTheme.textGrey, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}