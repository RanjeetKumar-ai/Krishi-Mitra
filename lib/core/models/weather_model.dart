/// Weather Data Model
library;

class WeatherModel {
  final DateTime date;
  final double temperature;
  final double minTemp;
  final double maxTemp;
  final int humidity;
  final double windSpeed;
  final int rainProbability;
  final String condition; // "Sunny", "Rainy", "Cloudy", etc.
  final String iconCode;
  final String advisory;

  WeatherModel({
    required this.date,
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.humidity,
    required this.windSpeed,
    required this.rainProbability,
    required this.condition,
    required this.iconCode,
    required this.advisory,
  });

  String get tempText => '${temperature.toStringAsFixed(0)}°C';
  String get rainText => '$rainProbability%';
  String get humidityText => '$humidity%';
  String get windText => '${windSpeed.toStringAsFixed(1)} km/h';
}
