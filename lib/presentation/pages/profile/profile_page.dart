/// Profile & Settings Screen - REDESIGNED
/// Safety-first, farmer-friendly, calm farm-themed header
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../pages/safety/sos_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _sosBreathController;

  // Accordion expansion states
  String? _expandedGroup;

  @override
  void initState() {
    super.initState();
    _sosBreathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sosBreathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Section 1: Profile Header - REDESIGNED (Farm-themed, calm)
            _buildFarmThemedHeader(context),

            const SizedBox(height: 16),

            // Section 2: Emergency Help Card (FIXED navigation)
            _buildEmergencyHelpCard(context),

            const SizedBox(height: 20),

            // Section 3: Farm Management (Simple cards)
            _buildFarmManagementCards(context),

            const SizedBox(height: 20),

            // Section 4: Expandable Settings Groups
            _buildExpandableGroup(
              context,
              groupKey: 'account',
              title: 'Account',
              icon: Icons.person,
              items: [
                _SettingItem(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Navigate to edit profile
                  },
                ),
                _SettingItem(
                  icon: Icons.phone,
                  title: 'Change Phone Number',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Navigate to change phone
                  },
                ),
                _SettingItem(
                  icon: Icons.lock,
                  title: 'Privacy Settings',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Navigate to privacy settings
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildExpandableGroup(
              context,
              groupKey: 'preferences',
              title: 'Preferences',
              icon: Icons.tune,
              items: [
                _SettingItem(
                  icon: Icons.language,
                  title: 'Language',
                  trailing: 'English',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Show language picker
                  },
                ),
                _SettingItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Navigate to notifications settings
                  },
                ),
                _SettingItem(
                  icon: Icons.volume_up,
                  title: 'Voice Guidance',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Navigate to voice settings
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildExpandableGroup(
              context,
              groupKey: 'support',
              title: 'Support',
              icon: Icons.help_outline,
              items: [
                _SettingItem(
                  icon: Icons.help,
                  title: 'Help & FAQ',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Navigate to help
                  },
                ),
                _SettingItem(
                  icon: Icons.contact_support,
                  title: 'Contact Support',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showContactSupport(context);
                  },
                ),
                _SettingItem(
                  icon: Icons.feedback,
                  title: 'Send Feedback',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Navigate to feedback
                  },
                ),
                _SettingItem(
                  icon: Icons.star,
                  title: 'Rate App',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Launch Play Store rating
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildExpandableGroup(
              context,
              groupKey: 'about',
              title: 'About',
              icon: Icons.info_outline,
              items: [
                _SettingItem(
                  icon: Icons.info,
                  title: 'App Version',
                  trailing: '1.0.0',
                  onTap: () {},
                ),
                _SettingItem(
                  icon: Icons.description,
                  title: 'Terms & Conditions',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Show terms
                  },
                ),
                _SettingItem(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Show privacy policy
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _showLogoutDialog(context);
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ==================== SECTION 1: FARM-THEMED HEADER (REDESIGNED) ====================
  Widget _buildFarmThemedHeader(BuildContext context) {
    return Stack(
      children: [
        // Background with subtle farm pattern
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF6BA368), // Calm farm green
                const Color(0xFF7FB57D),
                const Color(0xFFF8F9FA).withValues(alpha: (0.9)),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Farm field pattern (subtle)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: (0.05)),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: [
                // Title and Settings Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile & Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: (0.2)),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          // Settings already on this page
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Profile Info Card (compact, calm)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: (0.08)),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar with farmer icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6BA368),
                              const Color(0xFF7FB57D),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6BA368)
                                  .withValues(alpha: (0.3)),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Farmer Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'किसान (Farmer)',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+91 98765 43210',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Hyderabad, Telangana',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Edit button
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF6BA368).withValues(alpha: (0.1)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: const Color(0xFF6BA368),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== SECTION 2: EMERGENCY HELP CARD (FIXED NAVIGATION) ====================
  Widget _buildEmergencyHelpCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SOSPage()),
            );
          },
          child: AnimatedBuilder(
            animation: _sosBreathController,
            builder: (context, child) {
              final breathValue = _sosBreathController.value;
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B6B).withValues(alpha: (0.9)),
                      const Color(0xFFFF8E53).withValues(alpha: (0.9)),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B)
                          .withValues(alpha: (0.2 + breathValue * 0.15)),
                      blurRadius: 12 + breathValue * 6,
                      spreadRadius: 2 + breathValue * 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Shield Icon
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: (0.25)),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency Help',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quick help during floods, storms, or accidents',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: (0.95)),
                                  fontSize: 13,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Arrow
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: (0.3)),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ==================== SECTION 3: FARM MANAGEMENT CARDS ====================
  Widget _buildFarmManagementCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'Farm Management',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          _buildSimpleCard(
            context,
            icon: Icons.local_florist,
            title: 'My Farms',
            onTap: () {
              // TODO: Navigate to farms list
            },
          ),
          const SizedBox(height: 10),
          _buildSimpleCard(
            context,
            icon: Icons.history,
            title: 'Activity History',
            onTap: () {
              // TODO: Navigate to activity history
            },
          ),
          const SizedBox(height: 10),
          _buildSimpleCard(
            context,
            icon: Icons.cloud_download,
            title: 'Offline Data',
            onTap: () {
              // TODO: Navigate to offline data management
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: (0.06))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: (0.04)),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: (0.12)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryGreen, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SECTION 4: EXPANDABLE SETTINGS GROUPS ====================
  Widget _buildExpandableGroup(
    BuildContext context, {
    required String groupKey,
    required String title,
    required IconData icon,
    required List<_SettingItem> items,
  }) {
    final isExpanded = _expandedGroup == groupKey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded
                ? AppColors.primaryGreen.withValues(alpha: (0.3))
                : Colors.black.withValues(alpha: (0.06)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: (0.04)),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _expandedGroup = isExpanded ? null : groupKey;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: (0.12)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.primaryGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expandable content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  const Divider(height: 1, thickness: 1),
                  ...items
                      .map((item) => _buildSettingItemWidget(context, item)),
                ],
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItemWidget(BuildContext context, _SettingItem item) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        item.onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(item.icon, color: AppColors.primaryGreen, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (item.trailing != null)
              Text(
                item.trailing!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CONTACT SUPPORT ====================
  void _showContactSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Support',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.phone, color: AppColors.primaryGreen),
              title: const Text('Call Support'),
              subtitle: const Text('+91 1800-xxx-xxxx'),
              onTap: () {
                Navigator.pop(context);
                _launchCall('+911800xxxxxxx');
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppColors.primaryGreen),
              title: const Text('Email Support'),
              subtitle: const Text('support@krishimitra.com'),
              onTap: () {
                Navigator.pop(context);
                _launchEmail('support@krishimitra.com');
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ==================== LOGOUT DIALOG ====================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              // TODO: Perform logout (clear user data, navigate to login)
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // ==================== URL LAUNCHERS ====================
  Future<void> _launchCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

// ==================== HELPER CLASSES ====================

class _SettingItem {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  _SettingItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });
}
