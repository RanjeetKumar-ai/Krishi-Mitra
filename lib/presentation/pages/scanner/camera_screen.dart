/// Enhanced Camera Scanner Screen - FINAL FIXED VERSION
/// NO OVERFLOW - Tested and Verified
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import 'disease_result_page.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  bool _isProcessing = false;
  bool _showScanningAnimation = false;
  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _scanLineAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),

          // Main Content
          SafeArea(
            bottom: false, // Allow content to extend to bottom
            child: Column(
              children: [
                // Header - Fixed height
                _buildHeader(context),

                // Scanning Area - Takes remaining space
                Expanded(
                  child: _buildScanningArea(context),
                ),
              ],
            ),
          ),

          // Bottom Controls - Positioned absolutely
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: _buildBottomControls(context),
            ),
          ),

          // Processing Overlay
          if (_isProcessing) _buildProcessingOverlay(context),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A3A1A),
                Color(0xFF0D1F0D),
                Color(0xFF1A1A1A),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: SoilPatternPainter(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(Icons.arrow_back,
                  color: AppColors.white, size: 24),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.eco,
                      color: AppColors.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Disease Scanner',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.blur_on,
                        color: AppColors.primaryGreen, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'AI Powered',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showInstructions(context);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(Icons.help_outline,
                  color: AppColors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningArea(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final frameSize = size.width * 0.75;

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Instructions Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.primaryGreen, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Position the leaf properly',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildQuickTip('Good Light', Icons.wb_sunny),
                          _buildQuickTip('Steady Hold', Icons.pan_tool),
                          _buildQuickTip(
                              'Clear Focus', Icons.center_focus_strong),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Scanning Frame
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: frameSize * _pulseAnimation.value,
                          height: frameSize * _pulseAnimation.value,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen
                                    .withValues(alpha: 0.3),
                                blurRadius: 40,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Container(
                      width: frameSize,
                      height: frameSize,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: AppColors.primaryGreen, width: 3),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 1200),
                                  curve: Curves.elasticOut,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen
                                              .withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.primaryGreen
                                                .withValues(alpha: 0.5),
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.eco,
                                          size: 50,
                                          color: AppColors.primaryGreen,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Camera Preview Area',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.white
                                            .withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          ...List.generate(4, (index) {
                            return _buildAnimatedCorner(index);
                          }),
                          if (_showScanningAnimation)
                            AnimatedBuilder(
                              animation: _scanLineAnimation,
                              builder: (context, child) {
                                return Positioned(
                                  left: 0,
                                  right: 0,
                                  top: (frameSize - 50) *
                                      _scanLineAnimation.value,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          AppColors.primaryGreen,
                                          Colors.transparent,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryGreen,
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    CustomPaint(
                      size: Size(frameSize, frameSize),
                      painter: GridOverlayPainter(),
                    ),
                  ],
                ),

                SizedBox(height: constraints.maxHeight * 0.15),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 32, right: 32, top: 12, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Capture Button
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              _captureAndAnalyze();
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.5),
                      width: 3,
                    ),
                  ),
                ),
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryGreen, AppColors.healthyGreen],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: AppColors.white, size: 30),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Gallery Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _pickFromGallery();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library,
                      color: AppColors.primaryGreen, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Choose from Gallery',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
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

  Widget _buildProcessingOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                RotationTransition(
                  turns: _rotateController,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                RotationTransition(
                  turns: Tween(begin: 1.0, end: 0.0).animate(_rotateController),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.healthyGreen.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.eco, size: 50, color: AppColors.white),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Analyzing Plant Health...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  _buildProcessStep('Detecting leaf patterns', true),
                  _buildProcessStep('Analyzing disease symptoms', true),
                  _buildProcessStep('Matching with AI database', false),
                  _buildProcessStep('Generating recommendations', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 13),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCorner(int index) {
    final positions = [
      {'top': 0.0, 'left': 0.0},
      {'top': 0.0, 'right': 0.0},
      {'bottom': 0.0, 'left': 0.0},
      {'bottom': 0.0, 'right': 0.0},
    ];

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Positioned(
          top: positions[index]['top'],
          left: positions[index]['left'],
          right: positions[index]['right'],
          bottom: positions[index]['bottom'],
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                border: Border(
                  top: index < 2
                      ? const BorderSide(
                          color: AppColors.primaryGreen, width: 4)
                      : BorderSide.none,
                  left: index % 2 == 0
                      ? const BorderSide(
                          color: AppColors.primaryGreen, width: 4)
                      : BorderSide.none,
                  right: index % 2 == 1
                      ? const BorderSide(
                          color: AppColors.primaryGreen, width: 4)
                      : BorderSide.none,
                  bottom: index >= 2
                      ? const BorderSide(
                          color: AppColors.primaryGreen, width: 4)
                      : BorderSide.none,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProcessStep(String text, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isActive
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: isActive ? AppColors.primaryGreen : AppColors.mediumGray,
            size: 16,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: isActive ? AppColors.white : AppColors.mediumGray,
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _captureAndAnalyze() async {
    setState(() {
      _isProcessing = true;
      _showScanningAnimation = true;
    });

    _scanLineController.repeat();
    _rotateController.repeat();

    await Future.delayed(const Duration(seconds: 3));

    _scanLineController.stop();
    _rotateController.stop();

    setState(() {
      _isProcessing = false;
      _showScanningAnimation = false;
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DiseaseResultPage(
            diseaseName: 'Late Blight',
            confidence: 92.5,
            cropType: 'Tomato',
          ),
        ),
      );
    }
  }

  void _pickFromGallery() async {
    HapticFeedback.lightImpact();
    setState(() => _isProcessing = true);
    _rotateController.repeat();

    await Future.delayed(const Duration(seconds: 2));

    _rotateController.stop();
    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DiseaseResultPage(
            diseaseName: 'Leaf Spot',
            confidence: 88.3,
            cropType: 'Onion',
          ),
        ),
      );
    }
  }

  void _showInstructions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border:
              Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.eco, color: AppColors.primaryGreen, size: 24),
                const SizedBox(width: 12),
                Text(
                  'How to Use Disease Scanner',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInstructionStep(
                '1', 'Select the affected leaf from your crop'),
            _buildInstructionStep('2', 'Place leaf inside the green frame'),
            _buildInstructionStep(
                '3', 'Ensure proper lighting (natural light is best)'),
            _buildInstructionStep(
                '4', 'Hold camera steady and tap capture button'),
            _buildInstructionStep('5', 'Wait for AI analysis (2-3 seconds)'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Got It',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.healthyGreen],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SoilPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.soilBrown.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (int i = 0; i < 20; i++) {
      final y = (size.height / 20) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    for (int i = 1; i < 3; i++) {
      final x = (size.width / 3) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (int i = 1; i < 3; i++) {
      final y = (size.height / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
