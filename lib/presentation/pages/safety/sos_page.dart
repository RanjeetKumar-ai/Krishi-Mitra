/// Emergency SOS Screen - Farmer-first safety
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class SOSPage extends StatelessWidget {
  const SOSPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        title: const Text('Emergency Assistance'),
        backgroundColor: const Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle
              Text(
                'Choose help you need now',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 24),

              // Emergency Actions (large buttons)
              Expanded(
                child: ListView(
                  children: [
                    _buildEmergencyButton(
                      context,
                      icon: Icons.phone,
                      title: 'Call Emergency Contact',
                      subtitle: 'Saved contact: +91 98765 43210',
                      color: const Color(0xFFFF6B6B),
                      onTap: () => _launchCall('+919876543210'),
                    ),
                    const SizedBox(height: 14),
                    _buildEmergencyButton(
                      context,
                      icon: Icons.my_location,
                      title: 'Share Live Location',
                      subtitle: 'Send location via SMS or WhatsApp',
                      color: const Color(0xFF4ECDC4),
                      onTap: () => _shareLocation(context),
                    ),
                    const SizedBox(height: 14),
                    _buildEmergencyButton(
                      context,
                      icon: Icons.contact_phone,
                      title: 'Disaster Helpline Numbers',
                      subtitle: 'NDMA, Police, Fire, Ambulance',
                      color: const Color(0xFFFF8E53),
                      onTap: () => _showHelplineNumbers(context),
                    ),
                    const SizedBox(height: 14),
                    _buildEmergencyButton(
                      context,
                      icon: Icons.volume_up,
                      title: 'Voice Guided Instructions',
                      subtitle: 'Listen to safety steps (offline)',
                      color: const Color(0xFF9B59B6),
                      onTap: () => _playVoiceInstructions(context),
                    ),
                  ],
                ),
              ),

              // Footer note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade800),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'For urgent situations only.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: (0.3)), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: (0.15)),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: (0.15)),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 18, color: color),
          ],
        ),
      ),
    );
  }

  // ==================== ACTIONS ====================

  Future<void> _launchCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _shareLocation(BuildContext context) {
    // Implement location sharing (use geolocator + share_plus)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fetching location...')),
    );
  }

  void _showHelplineNumbers(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Helpline Numbers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildHelplineItem('Police', '100'),
            _buildHelplineItem('Ambulance', '108'),
            _buildHelplineItem('Fire Brigade', '101'),
            _buildHelplineItem('NDMA (Disaster)', '1078'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHelplineItem(String label, String number) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.phone, color: AppColors.primaryGreen),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Text(number,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      onTap: () => _launchCall(number),
    );
  }

  void _playVoiceInstructions(BuildContext context) {
    // Integrate with TtsService (call speak with emergency instructions)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Playing safety instructions...')),
    );
  }
}
