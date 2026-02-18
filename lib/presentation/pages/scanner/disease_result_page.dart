/// Enhanced Disease Detection Result Screen - FINAL FIXED
/// Collapsible header WITHOUT floating buttons + NO OVERFLOW
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

class DiseaseResultPage extends StatefulWidget {
  final String diseaseName;
  final double confidence;
  final String cropType;

  const DiseaseResultPage({
    super.key,
    required this.diseaseName,
    required this.confidence,
    required this.cropType,
  });

  @override
  State<DiseaseResultPage> createState() => _DiseaseResultPageState();
}

class _DiseaseResultPageState extends State<DiseaseResultPage>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimController;
  late AnimationController _contentAnimController;
  late AnimationController _progressController;
  late Animation<double> _headerScaleAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _progressAnimation;

  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollListener();
  }

  void _setupAnimations() {
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _headerScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimController,
        curve: Curves.elasticOut,
      ),
    );

    _contentAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimController,
        curve: Curves.easeOutCubic,
      ),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.confidence / 100,
    ).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ),
    );

    _headerAnimController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _contentAnimController.forward();
      _progressController.forward();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      setState(() {
        _scrollProgress = (_scrollController.offset / 200).clamp(0.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _contentAnimController.dispose();
    _progressController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHealthy = widget.diseaseName.toLowerCase() == 'healthy';
    final severityColor = _getSeverityColor(widget.confidence);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0D),
      body: Stack(
        children: [
          _buildAnimatedBackground(isHealthy),
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildCollapsibleHeader(context, isHealthy, severityColor),
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _contentSlideAnimation,
                  child: FadeTransition(
                    opacity: _contentAnimController,
                    child: _buildContent(context, isHealthy, severityColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== COLLAPSIBLE HEADER (REDUCED HEIGHT) ====================
  Widget _buildCollapsibleHeader(
      BuildContext context, bool isHealthy, Color severityColor) {
    return SliverAppBar(
      expandedHeight: 320, // Reduced from 380
      pinned: true,
      backgroundColor:
          isHealthy ? AppColors.successGreen : AppColors.diseaseRed,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.volume_up, color: AppColors.white),
            onPressed: () {
              HapticFeedback.mediumImpact();
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        title: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _scrollProgress > 0.5 ? 1.0 : 0.0,
          child: Text(
            widget.diseaseName,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isHealthy
                  ? [AppColors.successGreen, AppColors.healthyGreen]
                  : [AppColors.diseaseRed, AppColors.warningOrange],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: 1.0 - _scrollProgress,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Icon (Reduced)
                    ScaleTransition(
                      scale: _headerScaleAnimation,
                      child: Transform.scale(
                        scale: 1.0 - (_scrollProgress * 0.3),
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.white.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Icon(
                            isHealthy
                                ? Icons.check_circle
                                : Icons.warning_amber_rounded,
                            size: 50,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Disease Name (Reduced)
                    Text(
                      widget.diseaseName,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Crop Type Badge (Compact)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.eco,
                              color: AppColors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            widget.cropType,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Confidence Score (Inline & Compact)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.analytics,
                              color: AppColors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'AI Confidence: ',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return Text(
                                '${(_progressAnimation.value * 100).toStringAsFixed(1)}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== BACKGROUND ====================
  Widget _buildAnimatedBackground(bool isHealthy) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isHealthy
              ? [
                  const Color(0xFF1A4D1A),
                  const Color(0xFF0D1F0D),
                  const Color(0xFF000000),
                ]
              : [
                  const Color(0xFF4D1A1A),
                  const Color(0xFF1F0D0D),
                  const Color(0xFF000000),
                ],
        ),
      ),
    );
  }

  // ==================== CONTENT ====================
  Widget _buildContent(
      BuildContext context, bool isHealthy, Color severityColor) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1F0D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isHealthy) ...[
              _buildSeverityCard(context, severityColor),
              const SizedBox(height: 20),
              _buildSectionHeader(
                context,
                icon: Icons.info_outline,
                title: 'About This Disease',
                color: AppColors.accentBlue,
              ),
              const SizedBox(height: 10),
              _buildDescriptionCard(context),
              const SizedBox(height: 20),
              _buildSectionHeader(
                context,
                icon: Icons.medical_services,
                title: 'Treatment Solutions',
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 10),
              _buildEnhancedTreatmentCard(
                context,
                title: '🌿 Organic Treatment',
                subtitle: 'Natural & Safe',
                color: AppColors.healthyGreen,
                items: _getOrganicTreatment(widget.diseaseName),
              ),
              const SizedBox(height: 10),
              _buildEnhancedTreatmentCard(
                context,
                title: '🧪 Chemical Treatment',
                subtitle: 'Fast Acting',
                color: AppColors.accentOrange,
                items: _getChemicalTreatment(widget.diseaseName),
              ),
              const SizedBox(height: 20),
              _buildApplicationGuide(context),
              const SizedBox(height: 20),
              _buildSectionHeader(
                context,
                icon: Icons.shield,
                title: 'Prevention Tips',
                color: AppColors.accentBlue,
              ),
              const SizedBox(height: 10),
              _buildPreventionCard(context),
            ] else ...[
              _buildHealthyMessage(context),
            ],
            const SizedBox(height: 24),
            _buildActionButtons(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityCard(BuildContext context, Color severityColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            severityColor.withValues(alpha: 0.2),
            severityColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: severityColor, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.signal_cellular_alt, color: severityColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Severity Level',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getSeverityLevel(widget.confidence),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: severityColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getSeverityEmoji(widget.confidence),
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        _getDiseaseDescription(widget.diseaseName),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
              height: 1.6,
            ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTreatmentCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.check_circle, color: color, size: 18),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.white.withValues(alpha: 0.9),
                                height: 1.5,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationGuide(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentYellow.withValues(alpha: 0.2),
            AppColors.accentYellow.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentYellow.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentYellow.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.scale,
                    color: AppColors.accentYellow, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Application Quantity',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getQuantityGuidance(widget.diseaseName),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                    height: 1.6,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreventionCard(BuildContext context) {
    final tips = _getPreventionTips(widget.diseaseName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: tips.map((tip) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb,
                    color: AppColors.accentYellow, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tip,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHealthyMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.successGreen.withValues(alpha: 0.3),
            AppColors.successGreen.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.successGreen, width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.celebration,
              size: 70, color: AppColors.successGreen),
          const SizedBox(height: 18),
          Text(
            'Great News!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your crop appears to be healthy. Continue your good practices!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep it up! 💪',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                ..._getMaintenanceTips().map((tip) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.successGreen, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _saveToHistory(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bookmark, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Save to Crop History',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.primaryGreen, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _shareWithExpert(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.share,
                    size: 20, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Share with Expert',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: Text(
            'Back to Home',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getSeverityColor(double confidence) {
    if (confidence > 85) return AppColors.errorRed;
    if (confidence > 70) return AppColors.warningOrange;
    return AppColors.accentYellow;
  }

  String _getSeverityLevel(double confidence) {
    if (confidence > 85) return 'High Risk';
    if (confidence > 70) return 'Medium Risk';
    return 'Low Risk';
  }

  String _getSeverityEmoji(double confidence) {
    if (confidence > 85) return '🔴';
    if (confidence > 70) return '🟠';
    return '🟡';
  }

  String _getDiseaseDescription(String disease) {
    if (disease == 'Late Blight') {
      return 'Late blight is a devastating disease caused by the fungus Phytophthora infestans. '
          'It spreads rapidly in cool, wet conditions and can destroy entire crops within days. '
          'Early detection and treatment are crucial.';
    }
    if (disease == 'Leaf Spot') {
      return 'Leaf spot diseases are caused by various fungi and bacteria. '
          'They appear as brown or black spots on leaves, reducing photosynthesis and crop yield.';
    }
    return 'A common plant disease that requires immediate attention and proper treatment to prevent spread.';
  }

  List<String> _getOrganicTreatment(String disease) {
    return [
      'Apply neem oil solution (5ml per liter water) every 7 days',
      'Remove and destroy infected leaves immediately',
      'Spray Bordeaux mixture (1% solution) as preventive measure',
      'Maintain proper plant spacing for better air circulation',
      'Apply bio-fungicides like Trichoderma',
    ];
  }

  List<String> _getChemicalTreatment(String disease) {
    return [
      'Apply Mancozeb 75% WP @ 2.5g per liter of water',
      'Use Metalaxyl + Mancozeb combination @ 2g per liter',
      'Spray at 7-10 day intervals during disease season',
      'Apply early morning or late evening for best results',
      'Rotate fungicides to prevent resistance',
    ];
  }

  List<String> _getPreventionTips(String disease) {
    return [
      'Avoid overhead irrigation; use drip irrigation system',
      'Remove infected plant debris regularly from the field',
      'Ensure proper field drainage to prevent water logging',
      'Practice crop rotation with non-host crops every season',
      'Monitor crops daily for early detection of symptoms',
      'Use disease-resistant varieties when available',
    ];
  }

  List<String> _getMaintenanceTips() {
    return [
      'Continue regular watering schedule',
      'Monitor for any signs of stress or disease',
      'Maintain proper nutrient balance in soil',
      'Keep weeds under control',
      'Inspect plants weekly for early problem detection',
    ];
  }

  String _getQuantityGuidance(String disease) {
    return 'For 1 acre farmland:\n\n'
        '• Mix 2.5 kg fungicide with 200 liters of water\n'
        '• Spray uniformly covering both upper and lower leaf surfaces\n'
        '• Use proper protective equipment during application\n'
        '• Repeat application after 7-10 days if symptoms persist\n'
        '• Best time: Early morning (6-9 AM) or evening (4-6 PM)';
  }

  void _saveToHistory(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.white),
            const SizedBox(width: 10),
            const Expanded(child: Text('Saved to crop history successfully')),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareWithExpert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.share, color: AppColors.primaryGreen),
            const SizedBox(width: 10),
            Text(
              'Share with Expert',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        content: Text(
          'Send this diagnosis to an agricultural expert for review and additional advice?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.white.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.white),
                      const SizedBox(width: 10),
                      const Expanded(
                          child: Text('Shared with expert successfully')),
                    ],
                  ),
                  backgroundColor: AppColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text(
              'Send',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
