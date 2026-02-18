/// Weather Dashboard Screen
/// Displays weather forecast and agricultural advisories
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/weather_model.dart';
import '../../../data/dummy_data.dart';

class WeatherDashboardPage extends StatelessWidget {
  const WeatherDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final forecast = DummyData.weatherForecast;
    final today = forecast.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather & Forecast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Change location
            },
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              HapticFeedback.mediumImpact();
              // Play weather summary via TTS
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Weather Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: _getWeatherGradient(today.condition),
              ),
              child: Column(
                children: [
                  // Location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Hyderabad, Telangana',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.white,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Weather Icon & Temperature
                  Text(
                    today.iconCode,
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    today.tempText,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 56,
                        ),
                  ),
                  Text(
                    today.condition,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Min/Max Temp
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTempRange(context, 'Min', today.minTemp),
                      const SizedBox(width: 24),
                      _buildTempRange(context, 'Max', today.maxTemp),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Weather Details Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDetailCard(
                      context,
                      icon: Icons.water_drop,
                      label: 'Rain',
                      value: today.rainText,
                      color: AppColors.waterBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailCard(
                      context,
                      icon: Icons.water,
                      label: 'Humidity',
                      value: today.humidityText,
                      color: AppColors.accentBlue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDetailCard(
                      context,
                      icon: Icons.air,
                      label: 'Wind',
                      value: today.windText,
                      color: AppColors.mediumGray,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailCard(
                      context,
                      icon: Icons.wb_sunny,
                      label: 'UV Index',
                      value: 'Moderate',
                      color: AppColors.accentYellow,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Advisory
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.accentOrange),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info,
                        color: AppColors.accentOrange, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Advisory',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            today.advisory,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 7-Day Forecast
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '7-Day Forecast',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Forecast Cards
                  ...forecast.map((day) => _buildForecastCard(context, day)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Alert History
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Weather Alerts',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildAlertHistoryItem(
                    context,
                    icon: Icons.thunderstorm,
                    title: 'Thunderstorm Warning',
                    date: '30 Jan, 2026',
                  ),
                  _buildAlertHistoryItem(
                    context,
                    icon: Icons.wb_sunny,
                    title: 'Heatwave Alert',
                    date: '25 Jan, 2026',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTempRange(BuildContext context, String label, double temp) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white.withValues(alpha: 0.8),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '${temp.toStringAsFixed(0)}°',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(BuildContext context, WeatherModel weather) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Date
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDayName(weather.date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${weather.date.day} Feb',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Weather Icon
          Text(weather.iconCode, style: const TextStyle(fontSize: 32)),

          const SizedBox(width: 16),

          // Temperature
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.tempText,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  weather.condition,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Rain Probability
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.waterBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.water_drop,
                    color: AppColors.waterBlue, size: 16),
                const SizedBox(width: 4),
                Text(
                  weather.rainText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.waterBlue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertHistoryItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentOrange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  LinearGradient _getWeatherGradient(String condition) {
    if (condition.toLowerCase().contains('rain')) {
      return const LinearGradient(
        colors: [AppColors.waterBlue, AppColors.accentBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (condition.toLowerCase().contains('sunny')) {
      return const LinearGradient(
        colors: [AppColors.accentYellow, AppColors.accentOrange],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return AppColors.primaryGradient;
  }

  String _getDayName(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
