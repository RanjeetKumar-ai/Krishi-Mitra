import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/localization/tts_service.dart';
import '../../../services/localization/tts_languages.dart';
import '../../widgets/common/tts_language_sheet.dart';

// ==================== DATA MODELS (Same as before) ====================

enum PriceTrend { rising, falling, stable }

enum TrendAlertType { risingFast, dropping, stable }

class CropPriceModel {
  final String cropId;
  final String cropName;
  final String cropEmoji;
  final double currentPrice;
  final double weeklyChangePercent;
  final PriceTrend trend;
  final String nearestMandi;
  final String unit;

  CropPriceModel({
    required this.cropId,
    required this.cropName,
    required this.cropEmoji,
    required this.currentPrice,
    required this.weeklyChangePercent,
    required this.trend,
    required this.nearestMandi,
    this.unit = 'quintal',
  });
}

class TrendAlert {
  final String id;
  final String cropName;
  final String cropEmoji;
  final TrendAlertType alertType;
  final String message;
  final String recommendation;
  final Color color;

  TrendAlert({
    required this.id,
    required this.cropName,
    required this.cropEmoji,
    required this.alertType,
    required this.message,
    required this.recommendation,
    required this.color,
  });
}

class MandiPrice {
  final String id;
  final String mandiName;
  final double distance;
  final double price;
  final String cropName;
  final DateTime lastUpdated;

  MandiPrice({
    required this.id,
    required this.mandiName,
    required this.distance,
    required this.price,
    required this.cropName,
    required this.lastUpdated,
  });
}

class WeeklyPriceData {
  final String day;
  final double price;
  final PriceTrend trend;

  WeeklyPriceData({
    required this.day,
    required this.price,
    required this.trend,
  });
}

class SellOpportunity {
  final String cropName;
  final String cropEmoji;
  final String reason;
  final bool isGoodTime;

  SellOpportunity({
    required this.cropName,
    required this.cropEmoji,
    required this.reason,
    required this.isGoodTime,
  });
}

// ==================== DUMMY DATA ====================

class MarketData {
  static final List<CropPriceModel> myCropsPrices = [
    CropPriceModel(
      cropId: '1',
      cropName: 'Tomato',
      cropEmoji: '🍅',
      currentPrice: 2500,
      weeklyChangePercent: 12.5,
      trend: PriceTrend.rising,
      nearestMandi: 'Hyderabad APMC',
    ),
    CropPriceModel(
      cropId: '2',
      cropName: 'Onion',
      cropEmoji: '🧅',
      currentPrice: 1800,
      weeklyChangePercent: -5.2,
      trend: PriceTrend.falling,
      nearestMandi: 'Secunderabad Mandi',
    ),
    CropPriceModel(
      cropId: '3',
      cropName: 'Wheat',
      cropEmoji: '🌾',
      currentPrice: 2100,
      weeklyChangePercent: 0.5,
      trend: PriceTrend.stable,
      nearestMandi: 'Medchal Mandi',
    ),
  ];

  static final List<TrendAlert> trendAlerts = [
    TrendAlert(
      id: '1',
      cropName: 'Tomato',
      cropEmoji: '🍅',
      alertType: TrendAlertType.risingFast,
      message: 'Tomato prices rising rapidly',
      recommendation: 'Good time to sell. Price increased 12% this week',
      color: const Color(0xFF2E7D32),
    ),
    TrendAlert(
      id: '2',
      cropName: 'Onion',
      cropEmoji: '🧅',
      alertType: TrendAlertType.dropping,
      message: 'Onion prices declining',
      recommendation: 'Consider holding or selling at nearby premium markets',
      color: const Color(0xFFD32F2F),
    ),
  ];

  static final List<MandiPrice> nearbyMandis = [
    MandiPrice(
      id: '1',
      mandiName: 'Hyderabad APMC',
      distance: 5.2,
      price: 2500,
      cropName: 'Tomato',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    MandiPrice(
      id: '2',
      mandiName: 'Secunderabad Mandi',
      distance: 8.5,
      price: 2450,
      cropName: 'Tomato',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    MandiPrice(
      id: '3',
      mandiName: 'Medchal Mandi',
      distance: 12.0,
      price: 2350,
      cropName: 'Tomato',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  static final List<WeeklyPriceData> weeklyPrices = [
    WeeklyPriceData(day: 'Mon', price: 2200, trend: PriceTrend.stable),
    WeeklyPriceData(day: 'Tue', price: 2250, trend: PriceTrend.rising),
    WeeklyPriceData(day: 'Wed', price: 2300, trend: PriceTrend.rising),
    WeeklyPriceData(day: 'Thu', price: 2350, trend: PriceTrend.rising),
    WeeklyPriceData(day: 'Fri', price: 2400, trend: PriceTrend.rising),
    WeeklyPriceData(day: 'Sat', price: 2450, trend: PriceTrend.rising),
    WeeklyPriceData(day: 'Sun', price: 2500, trend: PriceTrend.rising),
  ];

  static final SellOpportunity sellOpportunity = SellOpportunity(
    cropName: 'Tomato',
    cropEmoji: '🍅',
    reason: 'Price at 3-month high and demand increasing',
    isGoodTime: true,
  );
}

// ==================== MAIN MARKET OVERVIEW SCREEN ====================

class MarketOverviewScreen extends StatefulWidget {
  const MarketOverviewScreen({super.key});

  @override
  State<MarketOverviewScreen> createState() => _MarketOverviewScreenState();
}

class _MarketOverviewScreenState extends State<MarketOverviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _priceAnimController;
  late AnimationController _voiceRippleController;

  bool _notifyPriceRise = true;
  bool _notifyPriceDrop = true;
  String _selectedCrop = 'Tomato';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _priceAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _voiceRippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _priceAnimController.dispose();
    _voiceRippleController.dispose();
    super.dispose();
  }

// ✅ TTS: Updated voice summary with English + Hindi
  Future<void> _playVoiceSummary() async {
    HapticFeedback.lightImpact();
    _voiceRippleController.forward(from: 0);

    final tts = TtsService.instance;
    final lang = tts.currentLanguage;

    // English summary
    final summaryEN =
        "Market Overview. Tomato 2500 rupees per quintal, up 12.5 percent. "
        "Onion 1800 rupees per quintal, down 5.2 percent. "
        "Good time to sell Tomato.";

    // Hindi summary
    final summaryHI =
        "बाजार जानकारी. टमाटर 2500 रुपये प्रति क्विंटल, 12.5 प्रतिशत ऊपर. "
        "प्याज़ 1800 रुपये प्रति क्विंटल, 5.2 प्रतिशत नीचे. "
        "टमाटर बेचने का अच्छा समय है।";

    await tts.speak(
      lang == TtsLanguages.hiIN ? summaryHI : summaryEN,
      languageCode: lang,
    );
  }

  // ✅ TTS: Nearby Mandis voice summary
  Future<void> _playMandiSummary() async {
    HapticFeedback.lightImpact();

    final tts = TtsService.instance;
    final lang = tts.currentLanguage;

    final summaryEN = "Nearby mandi prices for Tomato. "
        "Hyderabad APMC: 2500 rupees, 5.2 kilometers away. "
        "Secunderabad Mandi: 2450 rupees, 8.5 kilometers away. "
        "Medchal Mandi: 2350 rupees, 12 kilometers away.";

    final summaryHI = "टमाटर के लिए पास की मंडियों के भाव. "
        "हैदराबाद APMC: 2500 रुपये, 5.2 किलोमीटर दूर. "
        "सिकंदराबाद मंडी: 2450 रुपये, 8.5 किलोमीटर दूर. "
        "मेडचल मंडी: 2350 रुपये, 12 किलोमीटर दूर.";

    await tts.speak(
      lang == TtsLanguages.hiIN ? summaryHI : summaryEN,
      languageCode: lang,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                await Future.delayed(const Duration(seconds: 1));
                setState(() {
                  _priceAnimController.forward(from: 0);
                });
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Section 1: My Crops Price Summary - FIXED
                    _buildMyCropsPriceSection(),
                    const SizedBox(height: 20),
                    // Section 2: Trending Price Alerts
                    _buildTrendingAlertsSection(),
                    const SizedBox(height: 20),
                    // Section 6: Sell Opportunity CTA
                    if (MarketData.sellOpportunity.isGoodTime)
                      _buildSellOpportunityCTA(),
                    if (MarketData.sellOpportunity.isGoodTime)
                      const SizedBox(height: 20),
                    // Section 4: 7 Day Price Movement
                    _buildWeeklyTrendSection(),
                    const SizedBox(height: 20),
                    // Section 3: Current Nearby Mandi Prices
                    _buildNearbyMandiSection(),
                    const SizedBox(height: 20),
                    // Section 5: Price Alert Controls
                    _buildPriceAlertControls(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== APP BAR ====================
// ✅ TTS: Enhanced app bar with language switcher
  Widget _buildAppBar(BuildContext context) {
    final tts = TtsService.instance;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Market Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                ),
                Text(
                  'Live market prices and trends',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ✅ TTS: Language switcher (EN/HI)
          ValueListenableBuilder<bool>(
            valueListenable: tts.isSpeaking,
            builder: (_, __, ___) {
              final isHindi = tts.currentLanguage == TtsLanguages.hiIN;
              return GestureDetector(
                onTap: () => showTtsLanguageSheet(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isHindi ? "HI" : "EN",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),

          // ✅ TTS: Voice summary button (now functional)
          GestureDetector(
            onTap: _playVoiceSummary,
            child: AnimatedBuilder(
              animation: _voiceRippleController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    boxShadow: _voiceRippleController.isAnimating
                        ? [
                            BoxShadow(
                              color: Colors.white.withValues(
                                alpha: 0.5 * (1 - _voiceRippleController.value),
                              ),
                              blurRadius: 20 * _voiceRippleController.value,
                              spreadRadius: 10 * _voiceRippleController.value,
                            ),
                          ]
                        : [],
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 24,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SECTION 1: MY CROPS PRICE SUMMARY - FIXED ====================
  // Update in _buildMyCropsPriceSection method
// Replace the SizedBox height

  Widget _buildMyCropsPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'My Crops',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        SizedBox(
          height: 142, // Final optimized height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: MarketData.myCropsPrices.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < MarketData.myCropsPrices.length - 1 ? 12 : 0,
                ),
                child: _buildCropPriceCard(MarketData.myCropsPrices[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCropPriceCard(CropPriceModel crop) {
    final isRising = crop.trend == PriceTrend.rising;
    final isFalling = crop.trend == PriceTrend.falling;
    final trendColor = isRising
        ? const Color(0xFF2E7D32)
        : isFalling
            ? const Color(0xFFD32F2F)
            : const Color(0xFFF57C00);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedCrop = crop.cropName);
        // Navigate to detailed crop price screen
      },
      child: Container(
        width: 165, // Further reduced from 170
        padding: const EdgeInsets.all(10), // Reduced from 12
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _selectedCrop == crop.cropName
                ? const Color(0xFF2E7D32)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Crop icon and trend indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7), // Reduced from 8
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    crop.cropEmoji,
                    style: const TextStyle(fontSize: 22), // Reduced from 24
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRising
                            ? Icons.trending_up
                            : isFalling
                                ? Icons.trending_down
                                : Icons.trending_flat,
                        size: 11, // Reduced from 12
                        color: trendColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${crop.weeklyChangePercent.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: trendColor,
                          fontSize: 9, // Reduced from 10
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6), // Reduced from 8
            // Crop name
            Text(
              crop.cropName,
              style: const TextStyle(
                fontSize: 14, // Reduced from 15
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 2),
            // Current price with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: crop.currentPrice),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        '₹${value.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18, // Reduced from 20
                          fontWeight: FontWeight.bold,
                          color: trendColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Text(
                        '/${crop.unit}',
                        style: TextStyle(
                          fontSize: 9, // Reduced from 10
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 6), // Added explicit spacer
            // Nearest mandi
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 10, // Reduced from 11
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    crop.nearestMandi,
                    style: TextStyle(
                      fontSize: 9, // Reduced from 10
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SECTION 2: TRENDING PRICE ALERTS ====================
  Widget _buildTrendingAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Price Alerts',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: MarketData.trendAlerts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < MarketData.trendAlerts.length - 1 ? 12 : 0,
              ),
              child: _buildTrendAlertCard(MarketData.trendAlerts[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrendAlertCard(TrendAlert alert) {
    IconData alertIcon;
    switch (alert.alertType) {
      case TrendAlertType.risingFast:
        alertIcon = Icons.arrow_upward;
        break;
      case TrendAlertType.dropping:
        alertIcon = Icons.arrow_downward;
        break;
      case TrendAlertType.stable:
        alertIcon = Icons.trending_flat;
        break;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showAlertDetailDialog(alert);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: alert.color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: alert.color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Alert icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: alert.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    alert.cropEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    alertIcon,
                    color: alert.color,
                    size: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.message,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: alert.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.recommendation,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showAlertDetailDialog(TrendAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Text(alert.cropEmoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                alert.cropName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert.message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: alert.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              alert.recommendation,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  // ==================== SECTION 3: NEARBY MANDI PRICES ====================
  Widget _buildNearbyMandiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nearby Mandis',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
              ),
              // ✅ TTS: Now functional
              GestureDetector(
                onTap: _playMandiSummary,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.volume_up,
                        size: 14,
                        color: Color(0xFF2E7D32),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Listen',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: MarketData.nearbyMandis.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < MarketData.nearbyMandis.length - 1 ? 10 : 0,
              ),
              child: _buildMandiListItem(MarketData.nearbyMandis[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMandiListItem(MandiPrice mandi) {
    final timeDiff = DateTime.now().difference(mandi.lastUpdated);
    final hoursAgo = timeDiff.inHours;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate to mandi details or show directions
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Location icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.store,
                color: Color(0xFF1976D2),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Mandi info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mandi.mandiName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${mandi.distance.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${hoursAgo}h ago',
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
            // Price
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${mandi.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    '/quintal',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SECTION 4: WEEKLY PRICE TREND ====================
  Widget _buildWeeklyTrendSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '7-Day Price Movement',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.trending_up,
                        size: 14,
                        color: Color(0xFF2E7D32),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Rising',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Daily trend arrows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: MarketData.weeklyPrices.map((data) {
                return _buildDayTrendIndicator(data);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTrendIndicator(WeeklyPriceData data) {
    final isRising = data.trend == PriceTrend.rising;
    final isFalling = data.trend == PriceTrend.falling;
    final trendColor = isRising
        ? const Color(0xFF2E7D32)
        : isFalling
            ? const Color(0xFFD32F2F)
            : const Color(0xFFF57C00);

    return Column(
      children: [
        Icon(
          isRising
              ? Icons.arrow_upward
              : isFalling
                  ? Icons.arrow_downward
                  : Icons.remove,
          color: trendColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          data.day,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '₹${(data.price / 1000).toStringAsFixed(1)}k',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // ==================== SECTION 5: PRICE ALERT CONTROLS ====================
  Widget _buildPriceAlertControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 16),
            _buildAlertToggle(
              icon: Icons.trending_up,
              label: 'Notify when price rises above threshold',
              value: _notifyPriceRise,
              onChanged: (value) {
                setState(() => _notifyPriceRise = value);
                HapticFeedback.selectionClick();
              },
            ),
            const SizedBox(height: 12),
            _buildAlertToggle(
              icon: Icons.trending_down,
              label: 'Notify when price drops below threshold',
              value: _notifyPriceDrop,
              onChanged: (value) {
                setState(() => _notifyPriceDrop = value);
                HapticFeedback.selectionClick();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertToggle({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF212121),
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: const Color(0xFF2E7D32),
          activeThumbColor: Colors.white,
        ),
      ],
    );
  }

  // ==================== SECTION 6: SELL OPPORTUNITY CTA ====================
  Widget _buildSellOpportunityCTA() {
    final opportunity = MarketData.sellOpportunity;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          // Navigate to marketplace/buyers screen
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      opportunity.cropEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Good time to sell ${opportunity.cropName}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          opportunity.reason,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.people,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Find Buyers Nearby',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF2E7D32),
                      size: 18,
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
}
