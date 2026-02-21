// lib/features/pages/profile/profile_page.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../pages/safety/sos_page.dart';
import '../../../services/localization/tts_service.dart';
import '../../../services/localization/tts_languages.dart';

// ═══════════════════════════════════════════════════════════════════
//  ProfilePage
// ═══════════════════════════════════════════════════════════════════

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late final AnimationController _sosBreathController;

  /// Which accordion panel is open (null = all closed)
  String? _expandedGroup;

  /// Tracks which language is currently selected — mirrors TtsService
  String _selectedLangCode = TtsService.instance.currentLanguage;

  // ─── Lifecycle ────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _sosBreathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Keep in sync if language was already changed elsewhere
    _selectedLangCode = TtsService.instance.currentLanguage;
  }

  @override
  void dispose() {
    _sosBreathController.dispose();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  /// Returns short display label for the currently selected language
  String get _langLabel {
    final match = TtsLanguages.supported.where(
      (l) => l.code == _selectedLangCode,
    );
    return match.isNotEmpty ? match.first.nativeLabel : 'English';
  }

  // ═══════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── 1. Farm-themed header ──────────────────────────────
            _buildFarmThemedHeader(context),
            const SizedBox(height: 16),

            // ── 2. Emergency SOS card ──────────────────────────────
            _buildEmergencyHelpCard(context),
            const SizedBox(height: 20),

            // ── 3. Farm management quick cards ────────────────────
            _buildFarmManagementCards(context),
            const SizedBox(height: 20),

            // ── 4. Accordion: Account ──────────────────────────────
            _buildExpandableGroup(
              context,
              groupKey: 'account',
              title: 'Account',
              icon: Icons.person,
              items: [
                _SettingItem(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () => HapticFeedback.lightImpact(),
                ),
                _SettingItem(
                  icon: Icons.phone,
                  title: 'Change Phone Number',
                  onTap: () => HapticFeedback.lightImpact(),
                ),
                _SettingItem(
                  icon: Icons.lock,
                  title: 'Privacy Settings',
                  onTap: () => HapticFeedback.lightImpact(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── 5. Accordion: Preferences (Language lives here) ────
            _buildPreferencesGroup(context),
            const SizedBox(height: 12),

            // ── 6. Accordion: Support ──────────────────────────────
            _buildExpandableGroup(
              context,
              groupKey: 'support',
              title: 'Support',
              icon: Icons.help_outline,
              items: [
                _SettingItem(
                  icon: Icons.help,
                  title: 'Help & FAQ',
                  onTap: () => HapticFeedback.lightImpact(),
                ),
                _SettingItem(
                  icon: Icons.contact_support,
                  title: 'Contact Support',
                  onTap: () => _showContactSupport(context),
                ),
                _SettingItem(
                  icon: Icons.feedback,
                  title: 'Send Feedback',
                  onTap: () => HapticFeedback.lightImpact(),
                ),
                _SettingItem(
                  icon: Icons.star,
                  title: 'Rate App',
                  onTap: () => HapticFeedback.lightImpact(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── 7. Accordion: About ────────────────────────────────
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
                  onTap: () => HapticFeedback.lightImpact(),
                ),
                _SettingItem(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  onTap: () => HapticFeedback.lightImpact(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── 8. Logout ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorRed,
                    foregroundColor: Colors.white,
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SECTION 1 — FARM HEADER
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildFarmThemedHeader(BuildContext context) {
    return Stack(
      children: [
        // Gradient bg
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF6BA368),
                const Color(0xFF7FB57D),
                const Color(0xFFF8F9FA).withValues(alpha: (0.9)),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        // Subtle overlay
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
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: [
                // Title row
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
                        onPressed: () => HapticFeedback.lightImpact(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Profile card
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
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6BA368), Color(0xFF7FB57D)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6BA368).withValues(alpha: (0.3)),
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

                      // Info
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
                                Icon(Icons.phone,
                                    size: 14, color: Colors.grey[600]),
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
                                Icon(Icons.location_on,
                                    size: 14, color: Colors.grey[600]),
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

                      // Edit icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6BA368).withValues(alpha: (0.1)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Color(0xFF6BA368),
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

  // ═══════════════════════════════════════════════════════════════════
  //  SECTION 2 — EMERGENCY SOS
  // ═══════════════════════════════════════════════════════════════════

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
              final v = _sosBreathController.value;
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(0xFFFF6B6B).withValues(alpha: (0.2 + v * 0.15)),
                      blurRadius: 12 + v * 6,
                      spreadRadius: 2 + v * 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: (0.25)),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.shield, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Help',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quick help during floods, storms, or accidents',
                        style: TextStyle(
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: (0.3)),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward,
                      color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SECTION 3 — FARM MANAGEMENT CARDS
  // ═══════════════════════════════════════════════════════════════════

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
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildSimpleCard(
            context,
            icon: Icons.history,
            title: 'Activity History',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildSimpleCard(
            context,
            icon: Icons.cloud_download,
            title: 'Offline Data',
            onTap: () {},
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
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SECTION 4 — PREFERENCES (with live language selector)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildPreferencesGroup(BuildContext context) {
    final isExpanded = _expandedGroup == 'preferences';

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
            // Header row
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _expandedGroup = isExpanded ? null : 'preferences';
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
                      child: const Icon(Icons.tune,
                          color: AppColors.primaryGreen, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Preferences',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary, size: 26),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content
            AnimatedCrossFade(
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.easeInOut,
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  const Divider(height: 1, thickness: 1),

                  // ── LANGUAGE ROW (custom, interactive) ──────────
                  _buildLanguageRow(context),

                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // ── NOTIFICATIONS ────────────────────────────────
                  _buildSettingTile(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () => HapticFeedback.lightImpact(),
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // ── VOICE GUIDANCE (live speaking status) ────────
                  _buildVoiceGuidanceTile(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Language Row ──────────────────────────────────────────────────

  Widget _buildLanguageRow(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showLanguagePicker(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.language, color: AppColors.primaryGreen, size: 22),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Language / भाषा',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            // Active language badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: (0.1)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: (0.4)),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🇮🇳', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(
                    _langLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  // ─── Voice Guidance Tile ───────────────────────────────────────────

  Widget _buildVoiceGuidanceTile(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: TtsService.instance.isSpeaking,
      builder: (_, isSpeaking, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                isSpeaking ? Icons.volume_up : Icons.volume_off_outlined,
                color: isSpeaking
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Voice Guidance',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      isSpeaking
                          ? 'Speaking now...'
                          : 'Tap 🔊 anywhere to listen',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSpeaking
                            ? AppColors.primaryGreen
                            : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSpeaking)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    TtsService.instance.stop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: (0.1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.stop_circle_outlined,
                        color: AppColors.errorRed, size: 20),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ─── Language Picker Bottom Sheet ─────────────────────────────────

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LanguagePickerSheet(
        selectedCode: _selectedLangCode,
        onSelected: (code) async {
          HapticFeedback.selectionClick();

          // 1. Update TtsService language
          await TtsService.instance.setLanguage(code);

          // 2. Reflect in UI
          setState(() => _selectedLangCode = code);

          // 3. Speak confirmation in newly selected language
          final isHindi = code == TtsLanguages.hiIN;
          await TtsService.instance.speak(
            isHindi
                ? 'भाषा हिंदी में बदल गई। अब सभी आवाज़ें हिंदी में बजेंगी।'
                : 'Language changed to English. Voice guidance will now play in English.',
            languageCode: code,
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  GENERIC EXPANDABLE GROUP
  // ═══════════════════════════════════════════════════════════════════

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
                      child:
                          Icon(icon, color: AppColors.primaryGreen, size: 22),
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
                      child: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary, size: 26),
                    ),
                  ],
                ),
              ),
            ),
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
            if (item.trailing != null) ...[
              Text(
                item.trailing!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return _buildSettingItemWidget(
      context,
      _SettingItem(icon: icon, title: title, trailing: trailing, onTap: onTap),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  DIALOGS & SHEETS
  // ═══════════════════════════════════════════════════════════════════

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
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              // TODO: clear session, navigate to login
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  URL LAUNCHERS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _launchCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

// ═══════════════════════════════════════════════════════════════════
//  _SettingItem data class
// ═══════════════════════════════════════════════════════════════════

class _SettingItem {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });
}

// ═══════════════════════════════════════════════════════════════════
//  Language Picker Bottom Sheet
// ═══════════════════════════════════════════════════════════════════

class _LanguagePickerSheet extends StatefulWidget {
  final String selectedCode;
  final ValueChanged<String> onSelected;

  const _LanguagePickerSheet({
    required this.selectedCode,
    required this.onSelected,
  });

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  late String _previewCode;

  @override
  void initState() {
    super.initState();
    _previewCode = widget.selectedCode;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: (0.12)),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: (0.12)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.language,
                      color: AppColors.primaryGreen, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Select Language',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'भाषा चुनें',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Language options
          ...TtsLanguages.supported.map((lang) {
            final isSelected = lang.code == _previewCode;
            return GestureDetector(
              onTap: () {
                setState(() => _previewCode = lang.code);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen.withValues(alpha: (0.07))
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : Colors.grey.shade200,
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(lang.flag, style: const TextStyle(fontSize: 30)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.nativeLabel,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : Colors.black87,
                            ),
                          ),
                          Text(
                            lang.label,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedScale(
                      scale: isSelected ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 8),

          // Preview voice button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side:
                    const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 0),
              ),
              icon: const Icon(Icons.play_circle_outline,
                  color: AppColors.primaryGreen),
              label: Text(
                _previewCode == TtsLanguages.hiIN
                    ? 'आवाज़ सुनें (Voice Preview)'
                    : 'Voice Preview',
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                TtsService.instance.speak(
                  _previewCode == TtsLanguages.hiIN
                      ? 'नमस्ते किसान भाई! आपकी फसल की प्रगति अच्छी है।'
                      : 'Hello farmer! Your crop progress is looking good.',
                  languageCode: _previewCode,
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Confirm button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 0),
              ),
              onPressed: () {
                Navigator.pop(context);
                widget.onSelected(_previewCode);
              },
              child: Text(
                _previewCode == TtsLanguages.hiIN
                    ? 'हिंदी सेट करें ✓'
                    : 'Set English ✓',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
