library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/task_model.dart';
import '../../../core/models/crop_model.dart';
import '../../../core/models/alert_model.dart';
import '../../../data/dummy_data.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/home/enhanced_task_card.dart';
import '../../widgets/home/enhanced_crop_card.dart';
import '../../widgets/home/weather_preview_widget.dart';
import '../../widgets/home/offline_banner_widget.dart';
import '../../widgets/home/quick_action_button.dart';
import '../alerts/alert_details_page.dart';
import '../tasks/task_details_page.dart';
import '../crops/crop_detail_page.dart';
import '../crops/crops_list_page.dart';
import '../scanner/camera_screen.dart';
import '../weather/weather_dashboard_page.dart';
import '../market/market_overview_screen.dart';
import '../knowledge/knowledge_hub_page.dart';
import '../profile/profile_page.dart';
import '../growth_phase/phase_preparation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isOffline = false;
  bool _isSyncing = false;
  bool _isSynced = true;
  late AnimationController _headerAnimController;
  late AnimationController _contentAnimController;
  late AnimationController _syncIconController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _simulateConnectivityCheck();
  }

  void _setupAnimations() {
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOutCubic,
    ));

    _contentAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimController,
        curve: Curves.easeIn,
      ),
    );

    _syncIconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _headerAnimController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _contentAnimController.forward();
    });
  }

  void _simulateConnectivityCheck() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isOffline = false;
          _isSynced = true;
        });
      }
    });
  }

  void _handleManualSync() async {
    setState(() {
      _isSyncing = true;
      _isSynced = false;
    });
    _syncIconController.repeat();

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _isSynced = true;
      });
      _syncIconController.stop();
      _syncIconController.reset();

      // Show subtle haptic feedback instead of SnackBar
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _contentAnimController.dispose();
    _syncIconController.dispose();
    super.dispose();
  }

  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const CropsListPage();
      case 2:
        return const CameraScreen();
      case 3:
        return const WeatherDashboardPage();
      case 4:
        return const ProfilePage();
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentPage(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          HapticFeedback.selectionClick();
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    final alerts = DummyData.alerts;
    final tasks = DummyData.tasks;
    final crops = DummyData.crops;
    final todayWeather = DummyData.weatherForecast.first;

    final hasCriticalWeather = todayWeather.rainProbability > 70;

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        _handleManualSync();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // ==================== ANIMATED HEADER (FIXED) ====================
            SlideTransition(
              position: _headerSlideAnimation,
              child: _buildCompactHeader(context, todayWeather),
            ),

            const SizedBox(height: 12),

            // Wrap only content in SafeArea
            SafeArea(
              top: false, // Don't apply safe area to top (header handles it)
              child: FadeTransition(
                opacity: _contentFadeAnimation,
                child: Column(
                  children: [
                    // ==================== OFFLINE BANNER ====================
                    OfflineBannerWidget(
                      isOffline: _isOffline,
                      onSync: _handleManualSync,
                    ),

                    const SizedBox(height: 12),

                    // ==================== CRITICAL WEATHER WARNING ====================
                    if (hasCriticalWeather)
                      _buildCriticalWeatherBanner(context, todayWeather),

                    if (hasCriticalWeather) const SizedBox(height: 12),

                    // ==================== ACTIVE ALERTS ====================
                    _buildEnhancedAlerts(context, alerts),

                    const SizedBox(height: 20),

                    // ==================== TODAY'S TASKS ====================
                    _buildEnhancedTasks(context, tasks),

                    const SizedBox(height: 20),

                    // ==================== MY CROPS ====================
                    _buildEnhancedCrops(context, crops),

                    const SizedBox(height: 20),

                    // ==================== QUICK ACTIONS ====================
                    _buildEnhancedQuickActions(context),

                    const SizedBox(height: 20),

                    // ==================== UPCOMING PHASES ====================
                    _buildEnhancedUpcomingPhases(context, crops.first),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// ==================== COMPACT HEADER (FIXED ALIGNMENT) ====================
  Widget _buildCompactHeader(BuildContext context, weather) {
    return Container(
      // Extend to top of screen (including status bar)
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12, // Add status bar height
        16,
        16,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Greeting with Farmer Name + Sync + Settings
          Row(
            children: [
              // Greeting with Farmer Name
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'नमस्ते',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(width: 6),
                    const Text('👋', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    // Farmer Name
                    Flexible(
                      child: Text(
                        'किसान',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Sync Status Icon (Top Right beside Settings)
              GestureDetector(
                onTap: () {
                  if (!_isOffline) {
                    HapticFeedback.lightImpact();
                    _handleManualSync();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: _isSyncing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: RotationTransition(
                            turns: _syncIconController,
                            child: const Icon(
                              Icons.sync,
                              color: AppColors.white,
                              size: 18,
                            ),
                          ),
                        )
                      : Icon(
                          _isSynced ? Icons.cloud_done : Icons.cloud_off,
                          color: _isSynced
                              ? AppColors.white
                              : AppColors.white.withValues(alpha: 0.5),
                          size: 18,
                        ),
                ),
              ),

              const SizedBox(width: 8),

              // Settings Button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.settings,
                      color: AppColors.white, size: 20),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedIndex = 4);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Location (Compact)
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.white, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Hyderabad • 7 Feb 2026',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Weather Preview (Compact)
          WeatherPreviewWidget(
            weather: weather,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedIndex = 3);
            },
          ),
        ],
      ),
    );
  }

  // ==================== CRITICAL WEATHER BANNER ====================
  Widget _buildCriticalWeatherBanner(BuildContext context, weather) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.errorRed, AppColors.warningOrange],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.errorRed.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.white,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEATHER ALERT',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Heavy rain expected. Avoid field work.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.95),
                        fontSize: 12,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() => _selectedIndex = 3);
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ENHANCED ALERTS (ISSUE 3 FIXED - PROPER SWIPE) ====================
  Widget _buildEnhancedAlerts(BuildContext context, List<AlertModel> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    AppStrings.activeAlerts,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                  ),
                  const SizedBox(width: 8),
                  if (alerts.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${alerts.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                      ),
                    ),
                ],
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                child: Text(
                  AppStrings.viewAll,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Alert Cards - ISSUE 3 FIXED: Proper horizontal scrolling
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < alerts.length - 1 ? 12 : 0,
                ),
                child: SizedBox(
                  width: 300,
                  child: _buildSimpleAlertCard(context, alerts[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Simple Alert Card (Non-Dismissible for horizontal scroll)
  Widget _buildSimpleAlertCard(BuildContext context, AlertModel alert) {
    final severityColor = _getSeverityColor(alert.severity);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlertDetailsPage(alert: alert),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: severityColor.withValues(alpha: 0.08),
          border: Border.all(
            color: severityColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    alert.typeIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: severityColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          alert.severityText,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        alert.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              alert.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: severityColor,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlertDetailsPage(alert: alert),
                    ),
                  );
                },
                child: Text(
                  'View Details',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return AppColors.infoBlue;
      case AlertSeverity.medium:
        return AppColors.warningOrange;
      case AlertSeverity.high:
        return AppColors.errorRed;
      case AlertSeverity.critical:
        return AppColors.diseaseRed;
    }
  }

  // ==================== ENHANCED TASKS ====================
  Widget _buildEnhancedTasks(BuildContext context, List<TaskModel> tasks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.todaysTasks,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tasks.where((t) => t.status == TaskStatus.pending).length} pending',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tasks.take(3).toList().asMap().entries.map((entry) {
            final int index = entry.key;
            final TaskModel task = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: EnhancedTaskCard(
                task: task,
                number: index + 1,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailsPage(task: task),
                    ),
                  );
                },
                onComplete: (completedTask) {
                  HapticFeedback.heavyImpact();
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==================== ENHANCED CROPS (ISSUE 1 FIXED - NO OVERFLOW) ====================
  Widget _buildEnhancedCrops(BuildContext context, List<CropModel> crops) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.myCrops,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedIndex = 1);
                },
                child: Text(
                  AppStrings.viewAll,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ISSUE 1 FIXED: Proper height to prevent overflow
        SizedBox(
          height: 325, // Exact height to prevent 2px overflow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: crops.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < crops.length - 1 ? 14 : 0,
                ),
                child: SizedBox(
                  width: 260,
                  child: EnhancedCropCard(
                    crop: crops[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CropDetailPage(crop: crops[index]),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== ENHANCED QUICK ACTIONS ====================
  Widget _buildEnhancedQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              QuickActionButton(
                icon: Icons.camera_alt,
                label: 'Scanner',
                color: AppColors.diseaseRed,
                voiceHint: 'Open camera to scan plant diseases',
                onTap: () {
                  setState(() => _selectedIndex = 2);
                },
              ),
              QuickActionButton(
                icon: Icons.add_circle,
                label: 'Add Crop',
                color: AppColors.primaryGreen,
                voiceHint: 'Add a new crop to your farm',
                onTap: () {},
              ),
              QuickActionButton(
                icon: Icons.trending_up,
                label: 'Market',
                color: const Color(0xFFE65100),
                voiceHint: 'Check market prices and trends',
                onTap: () {
                  // Changed navigation target
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MarketOverviewScreen(),
                    ),
                  );
                },
              ),
              QuickActionButton(
                icon: Icons.lightbulb,
                label: 'Tips',
                color: AppColors.accentYellow,
                voiceHint: 'Learn farming tips and best practices',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KnowledgeHubPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== ENHANCED UPCOMING PHASES ====================
  Widget _buildEnhancedUpcomingPhases(BuildContext context, CropModel crop) {
    if (crop.nextPhase == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.upcomingPhases,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhasePreparationPage(crop: crop),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentBlue, AppColors.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          crop.iconEmoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${crop.name} - Next Phase',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getPhaseText(crop.nextPhase!),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${crop.daysToNextPhase}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                            ),
                            Text(
                              'days',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        AppColors.white.withValues(alpha: 0.9),
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.accentBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text(
                        'Prepare Now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PhasePreparationPage(crop: crop),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPhaseText(CropPhase phase) {
    switch (phase) {
      case CropPhase.seedling:
        return 'Seedling';
      case CropPhase.vegetative:
        return 'Vegetative';
      case CropPhase.flowering:
        return 'Flowering';
      case CropPhase.fruiting:
        return 'Fruiting';
      case CropPhase.maturation:
        return 'Maturation';
      case CropPhase.harvest:
        return 'Harvest';
    }
  }
}
