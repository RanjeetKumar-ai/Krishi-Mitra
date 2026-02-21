library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/weather_model.dart';
import '../../../data/dummy_data.dart';

class WeatherDashboardPage extends StatefulWidget {
  const WeatherDashboardPage({super.key});

  @override
  State<WeatherDashboardPage> createState() => _WeatherDashboardPageState();
}

class _WeatherDashboardPageState extends State<WeatherDashboardPage>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _pulseController;
  late final AnimationController _slideController;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forecast = DummyData.weatherForecast;
    final today = forecast.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F0),
      // ── Use NestedScrollView for reliable pinned header ──────────
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              expandedHeight: 190,
              // ✅ FIX: No collapsedHeight — let SliverAppBar handle it
              backgroundColor: _getHeaderColor(today.condition),
              forceElevated: innerBoxIsScrolled,
              // ✅ FIX: actions declared directly on SliverAppBar
              actions: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) => GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _isSpeaking = !_isSpeaking);
                      if (_isSpeaking) {
                        _speakWeatherSummary(
                            today); // ✅ 'today' already in scope from build()
                      } else {
                        debugPrint('TTS: stopped');
                      }
                    },
                    child: Container(
                      margin:
                          const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isSpeaking
                            ? Colors.white.withValues(
                                alpha: (0.4 + 0.2 * _pulseController.value))
                            : Colors.white.withValues(alpha: (0.25)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isSpeaking ? Icons.stop_circle : Icons.volume_up,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
              // ✅ FIX: FlexibleSpaceBar with no `title` to avoid positional arg error
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                // ✅ background replaces title for the expanded hero header
                background: _buildExpandedHeader(context, today),
              ),
              // ✅ Pinned collapsed state title shown via `title` on SliverAppBar
              title: innerBoxIsScrolled
                  ? _buildCollapsedBar(today)
                  : const SizedBox.shrink(),
              titleSpacing: 0,
            ),
          ];
        },
        body: _buildScrollBody(context, today, forecast),
      ),
    );
  }

  // ══════════════════ EXPANDED HEADER ════════════════════════════════

  Widget _buildExpandedHeader(BuildContext context, WeatherModel today) {
    return Container(
      decoration: BoxDecoration(
        gradient: _getWeatherGradient(today.condition),
      ),
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Floating weather emoji
          AnimatedBuilder(
            animation: _floatController,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, -6 * _floatController.value),
              child: Text(
                today.iconCode,
                style: const TextStyle(fontSize: 62),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Temp + condition + location
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Hyderabad, Telangana',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Big temperature
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      today.tempText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            today.condition,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _miniTempBadge(
                                '↓ ${today.minTemp.toStringAsFixed(0)}°',
                                Colors.lightBlueAccent,
                              ),
                              const SizedBox(width: 6),
                              _miniTempBadge(
                                '↑ ${today.maxTemp.toStringAsFixed(0)}°',
                                Colors.orangeAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniTempBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: (0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ✅ Collapsed bar shown when scrolled (pinned AppBar content)
  Widget _buildCollapsedBar(WeatherModel today) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(today.iconCode, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        Text(
          '${today.tempText} · ${today.condition}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ══════════════════ SCROLL BODY ═════════════════════════════════════

  Widget _buildScrollBody(
    BuildContext context,
    WeatherModel today,
    List<WeatherModel> forecast,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Horizontal stats strip
          _buildStatsStrip(context, today),

          const SizedBox(height: 14),

          // Kisan Advisory banner
          _buildAdvisoryBanner(context, today),

          const SizedBox(height: 16),

          // Khet impact tips
          _buildKhetImpactSection(context, today),

          const SizedBox(height: 16),

          // 7-day forecast horizontal scroll
          _buildForecastSection(context, forecast),

          const SizedBox(height: 16),

          // Recent alerts
          _buildAlertsSection(context),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  // ══════════════════ STATS STRIP ════════════════════════════════════

  Widget _buildStatsStrip(BuildContext context, WeatherModel today) {
    return SizedBox(
      height: 86,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildStatChip(Icons.water_drop, 'Rain', today.rainText,
              const Color(0xFF2196F3)),
          _buildStatChip(Icons.waves, 'Humidity', today.humidityText,
              const Color(0xFF00ACC1)),
          _buildStatChip(
              Icons.air, 'Wind', today.windText, const Color(0xFF78909C)),
          _buildStatChip(Icons.wb_sunny_outlined, 'UV Index', 'Moderate',
              const Color(0xFFFB8C00)),
          _buildStatChip(
            Icons.thermostat,
            'Feels Like',
            '${today.minTemp.toStringAsFixed(0)}°C',
            const Color(0xFFAB47BC),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
      IconData icon, String label, String value, Color color) {
    return FadeTransition(
      opacity: _slideController,
      child: Container(
        width: 92,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: color.withValues(alpha: (0.25)), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: (0.08)),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════ ADVISORY BANNER ════════════════════════════════

  Widget _buildAdvisoryBanner(BuildContext context, WeatherModel today) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (_, child) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color.lerp(
                const Color(0xFFFFA726),
                const Color(0xFFFF7043),
                _pulseController.value,
              )!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFA726).withValues(alpha: (0.12)),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFA726).withValues(alpha: (0.15)),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_rounded,
                color: Color(0xFFFB8C00),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kisan Advisory',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    today.advisory,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                      height: 1.3,
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

  // ══════════════════ KHET IMPACT CARDS ══════════════════════════════

  Widget _buildKhetImpactSection(BuildContext context, WeatherModel today) {
    final tips = _getKhetTips(today.condition);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: (0.12)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.agriculture,
                  color: AppColors.primaryGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Aaj Khet Mein kya karein?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: tips.length,
            itemBuilder: (context, i) => _buildKhetTipCard(tips[i], i),
          ),
        ),
      ],
    );
  }

  Widget _buildKhetTipCard(_KhetTip tip, int index) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _slideController,
        curve: Interval(
          (index * 0.1).clamp(0.0, 0.9),
          1.0,
          curve: Curves.easeOut,
        ),
      ),
      child: Container(
        width: 175,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: tip.color.withValues(alpha: (0.3)), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: tip.color.withValues(alpha: (0.08)),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: tip.color.withValues(alpha: (0.15)),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(tip.icon, color: tip.color, size: 16),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    tip.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: tip.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              tip.body,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════ 7-DAY FORECAST ═════════════════════════════════

  Widget _buildForecastSection(
      BuildContext context, List<WeatherModel> forecast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '7-Day Forecast',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 106,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: forecast.length,
            itemBuilder: (context, i) {
              return _buildForecastDayCard(forecast[i], i == 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForecastDayCard(WeatherModel day, bool isToday) {
    final gradient = isToday
        ? _getWeatherGradient(day.condition)
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday ? Colors.transparent : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: (0.06)),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isToday ? 'Today' : _getDayName(day.date),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isToday ? Colors.white : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 3),
          Text(day.iconCode, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 3),
          Text(
            day.tempText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isToday ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.water_drop,
                size: 9,
                color: isToday
                    ? Colors.white.withValues(alpha: (0.85))
                    : const Color(0xFF2196F3),
              ),
              const SizedBox(width: 2),
              Text(
                day.rainText,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isToday
                      ? Colors.white.withValues(alpha: (0.85))
                      : const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════ RECENT ALERTS ══════════════════════════════════

  Widget _buildAlertsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Weather Alerts',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          _buildAlertRow(
            emoji: '⛈️',
            title: 'Thunderstorm Warning',
            subtitle: '30 Jan, 2026',
            color: const Color(0xFF7B1FA2),
          ),
          const SizedBox(height: 10),
          _buildAlertRow(
            emoji: '🌡️',
            title: 'Heatwave Alert',
            subtitle: '25 Jan, 2026',
            color: const Color(0xFFE53935),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertRow({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: color.withValues(alpha: (0.25)), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: (0.06)),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: (0.1)),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // ══════════════════ HELPERS ═════════════════════════════════════════

  List<_KhetTip> _getKhetTips(String condition) {
    if (condition.toLowerCase().contains('rain')) {
      return [
        _KhetTip(
            Icons.umbrella,
            'Khet Mein Ruko',
            'Avoid open field work today. Heavy rain expected.',
            const Color(0xFF1976D2)),
        _KhetTip(
            Icons.water_damage,
            'Paani Nikaas',
            'Ensure proper drainage in paddy/vegetable beds.',
            const Color(0xFF00897B)),
        _KhetTip(
            Icons.pest_control,
            'Fungal Risk',
            'High humidity may trigger fungal diseases. Stay alert.',
            const Color(0xFFE53935)),
        _KhetTip(Icons.opacity, 'Sinchai Rokein',
            'No irrigation needed today. Save water.', const Color(0xFF7B1FA2)),
      ];
    } else if (condition.toLowerCase().contains('sunny')) {
      return [
        _KhetTip(
            Icons.wb_sunny,
            'Khet Ready',
            'Good day for field operations and harvesting.',
            const Color(0xFFFB8C00)),
        _KhetTip(
            Icons.water_drop,
            'Sinchai Zaruri',
            'Hot day ahead – irrigate in evening for best results.',
            const Color(0xFF1976D2)),
        _KhetTip(
            Icons.pest_control,
            'Keet Spray',
            'Ideal to spray pesticide in morning hours.',
            const Color(0xFF388E3C)),
        _KhetTip(
            Icons.thermostat,
            'Dhoop Se Bachao',
            'Cover seedlings with shade nets if above 35°C.',
            const Color(0xFFE53935)),
      ];
    }
    return [
      _KhetTip(
          Icons.cloud,
          'Cloudy Day',
          'Moderate conditions. Good for transplanting seedlings.',
          const Color(0xFF607D8B)),
      _KhetTip(Icons.grass, 'Weeding Time',
          'Soft soil – ideal for manual weeding.', const Color(0xFF388E3C)),
      _KhetTip(
          Icons.vaccines,
          'Fertilizer',
          'Apply fertilizer today before next rainfall.',
          const Color(0xFFFB8C00)),
    ];
  }

  LinearGradient _getWeatherGradient(String condition) {
    if (condition.toLowerCase().contains('rain')) {
      return const LinearGradient(
        colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (condition.toLowerCase().contains('sunny')) {
      return const LinearGradient(
        colors: [Color(0xFFFB8C00), Color(0xFFFFA726)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (condition.toLowerCase().contains('cloud')) {
      return const LinearGradient(
        colors: [Color(0xFF546E7A), Color(0xFF78909C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color _getHeaderColor(String condition) {
    if (condition.toLowerCase().contains('rain')) {
      return const Color(0xFF1565C0);
    }
    if (condition.toLowerCase().contains('sunny')) {
      return const Color(0xFFFB8C00);
    }
    if (condition.toLowerCase().contains('cloud')) {
      return const Color(0xFF546E7A);
    }
    return const Color(0xFF2E7D32);
  }

  String _getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
  // ══════════════════ TTS VOICE SUMMARY ══════════════════════════════
  // ✅ ADD THIS METHOD HERE — right before the closing } of the class

  void _speakWeatherSummary(WeatherModel today) {
    final summaryEN = "Today's weather in Hyderabad, Telangana. "
        '${today.condition}. Temperature ${today.tempText}. '
        'Minimum ${today.minTemp.toStringAsFixed(0)} degrees, '
        'Maximum ${today.maxTemp.toStringAsFixed(0)} degrees. '
        'Rain chance ${today.rainText}. '
        'Humidity ${today.humidityText}. '
        'Wind speed ${today.windText}. '
        'Advisory: ${today.advisory}';

    // Uncomment when TtsService is wired up in your project:
    // TtsService.instance.speak(summaryEN);

    debugPrint('TTS Weather Summary: $summaryEN');
  }
}

// ══════════════════ DATA CLASS ══════════════════════════════════════════

class _KhetTip {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _KhetTip(this.icon, this.title, this.body, this.color);
}
