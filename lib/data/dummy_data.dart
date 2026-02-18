/// Dummy Data for Development & Testing
library;

import '../core/models/alert_model.dart';
import '../core/models/task_model.dart';
import '../core/models/crop_model.dart';
import '../core/models/weather_model.dart';

class DummyData {
  // ==================== ALERTS ====================
  static List<AlertModel> alerts = [
    AlertModel(
      id: 'alert_1',
      title: 'Heavy Rain Expected',
      description:
          'Heavy rainfall expected in your area within the next 2 hours. Take necessary precautions.',
      type: AlertType.rain,
      severity: AlertSeverity.high,
      timestamp: DateTime.now(),
      doList: [
        'Cover your crops if possible',
        'Check drainage systems',
        'Store harvested crops safely',
        'Secure farm equipment',
      ],
      dontList: [
        'Don\'t apply fertilizers before rain',
        'Avoid irrigation for next 24 hours',
        'Don\'t leave tools outside',
      ],
    ),
    AlertModel(
      id: 'alert_2',
      title: 'Armyworm Pest Alert',
      description:
          'Armyworm outbreak reported in neighboring farms. Monitor your crops closely.',
      type: AlertType.pest,
      severity: AlertSeverity.medium,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      doList: [
        'Inspect crops daily for damage',
        'Apply organic neem oil spray',
        'Remove affected leaves immediately',
        'Set up pest traps',
      ],
      dontList: [
        'Don\'t ignore early signs',
        'Avoid chemical pesticides initially',
        'Don\'t delay treatment',
      ],
    ),
    AlertModel(
      id: 'alert_3',
      title: 'Heatwave Warning',
      description: 'Temperature will rise above 42°C for the next 3 days.',
      type: AlertType.heatwave,
      severity: AlertSeverity.high,
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      doList: [
        'Increase irrigation frequency',
        'Apply mulch to retain moisture',
        'Provide shade for sensitive crops',
      ],
      dontList: [
        'Don\'t irrigate during peak afternoon',
        'Avoid pruning during heatwave',
      ],
    ),
  ];

  // ==================== TASKS ====================
  static List<TaskModel> tasks = [
    TaskModel(
      id: 'task_1',
      title: 'Water the north field',
      cropName: 'Onion',
      fieldSize: 2.0,
      dueTime: DateTime.now().add(const Duration(hours: 2)),
      instructions: [
        'Check soil moisture before watering',
        'Use drip irrigation if available',
        'Water early morning (6-8 AM)',
        'Ensure even distribution',
      ],
      quantity: '500L per acre',
    ),
    TaskModel(
      id: 'task_2',
      title: 'Apply NPK Fertilizer',
      cropName: 'Tomato',
      fieldSize: 1.5,
      dueTime: DateTime.now().add(const Duration(hours: 5)),
      instructions: [
        'Mix NPK 19:19:19 with water',
        'Apply 10kg per acre',
        'Water immediately after application',
        'Avoid contact with leaves',
      ],
      quantity: '15kg (10kg/acre)',
      videoUrl: 'https://example.com/fertilizer-guide',
    ),
    TaskModel(
      id: 'task_3',
      title: 'Check for pest activity',
      cropName: 'Chilli',
      fieldSize: 1.0,
      dueTime: DateTime.now().add(const Duration(hours: 1)),
      instructions: [
        'Inspect undersides of leaves',
        'Look for holes or discoloration',
        'Check for insect eggs',
        'Take photos if pests found',
      ],
    ),
  ];

  // ==================== CROPS ====================
  static List<CropModel> crops = [
    CropModel(
      id: 'crop_1',
      name: 'Onion',
      iconEmoji: '🧅',
      currentPhase: CropPhase.vegetative,
      progressPercentage: 35,
      sowDate: DateTime.now().subtract(const Duration(days: 45)),
      fieldSize: 2.0,
      soilType: 'Loamy',
      healthStatus: CropHealthStatus.good,
      expectedHarvestDate: DateTime.now().add(const Duration(days: 85)),
      recentActions: [
        'Watered on ${DateTime.now().subtract(const Duration(days: 1)).day} Jan',
        'Applied fertilizer on ${DateTime.now().subtract(const Duration(days: 7)).day} Jan',
      ],
      upcomingTasks: [
        'Apply NPK in 5 days',
        'Weed removal in 3 days',
      ],
      nextPhase: CropPhase.flowering,
      daysToNextPhase: 20,
    ),
    CropModel(
      id: 'crop_2',
      name: 'Tomato',
      iconEmoji: '🍅',
      currentPhase: CropPhase.flowering,
      progressPercentage: 55,
      sowDate: DateTime.now().subtract(const Duration(days: 60)),
      fieldSize: 1.5,
      soilType: 'Sandy Loam',
      healthStatus: CropHealthStatus.warning,
      expectedHarvestDate: DateTime.now().add(const Duration(days: 50)),
      recentActions: [
        'Pest spray applied',
        'Pruned lateral branches',
      ],
      upcomingTasks: [
        'Check for pests daily',
        'Apply phosphorus boost',
      ],
      nextPhase: CropPhase.fruiting,
      daysToNextPhase: 15,
    ),
    CropModel(
      id: 'crop_3',
      name: 'Chilli',
      iconEmoji: '🌶️',
      currentPhase: CropPhase.seedling,
      progressPercentage: 15,
      sowDate: DateTime.now().subtract(const Duration(days: 20)),
      fieldSize: 1.0,
      soilType: 'Clay Loam',
      healthStatus: CropHealthStatus.good,
      expectedHarvestDate: DateTime.now().add(const Duration(days: 110)),
      recentActions: [
        'Transplanted seedlings',
      ],
      upcomingTasks: [
        'First watering',
        'Mulch application',
      ],
      nextPhase: CropPhase.vegetative,
      daysToNextPhase: 25,
    ),
  ];

  // ==================== WEATHER ====================
  static List<WeatherModel> weatherForecast = [
    WeatherModel(
      date: DateTime.now(),
      temperature: 28,
      minTemp: 22,
      maxTemp: 32,
      humidity: 65,
      windSpeed: 12.5,
      rainProbability: 80,
      condition: 'Rainy',
      iconCode: '🌧️',
      advisory: 'Heavy rain expected. Avoid field work.',
    ),
    WeatherModel(
      date: DateTime.now().add(const Duration(days: 1)),
      temperature: 26,
      minTemp: 21,
      maxTemp: 30,
      humidity: 70,
      windSpeed: 10.0,
      rainProbability: 40,
      condition: 'Cloudy',
      iconCode: '☁️',
      advisory: 'Good day for fertilizer application.',
    ),
    WeatherModel(
      date: DateTime.now().add(const Duration(days: 2)),
      temperature: 30,
      minTemp: 24,
      maxTemp: 35,
      humidity: 55,
      windSpeed: 8.5,
      rainProbability: 10,
      condition: 'Sunny',
      iconCode: '☀️',
      advisory: 'Increase irrigation. Avoid afternoon field work.',
    ),
  ];
}
