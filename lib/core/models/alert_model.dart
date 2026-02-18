/// Alert Data Model
/// Represents weather and pest alerts
library;

enum AlertType { rain, pest, heatwave, flood, drought, frost }

enum AlertSeverity { low, medium, high, critical }

class AlertModel {
  final String id;
  final String title;
  final String description;
  final AlertType type;
  final AlertSeverity severity;
  final DateTime timestamp;
  final List<String> doList;
  final List<String> dontList;
  final String? audioUrl;
  final bool isAcknowledged;

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.timestamp,
    required this.doList,
    required this.dontList,
    this.audioUrl,
    this.isAcknowledged = false,
  });

  AlertModel copyWith({
    String? id,
    String? title,
    String? description,
    AlertType? type,
    AlertSeverity? severity,
    DateTime? timestamp,
    List<String>? doList,
    List<String>? dontList,
    String? audioUrl,
    bool? isAcknowledged,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      doList: doList ?? this.doList,
      dontList: dontList ?? this.dontList,
      audioUrl: audioUrl ?? this.audioUrl,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
    );
  }

  String get severityText {
    switch (severity) {
      case AlertSeverity.low:
        return 'LOW';
      case AlertSeverity.medium:
        return 'MEDIUM';
      case AlertSeverity.high:
        return 'HIGH';
      case AlertSeverity.critical:
        return 'CRITICAL';
    }
  }

  String get typeIcon {
    switch (type) {
      case AlertType.rain:
        return '☔';
      case AlertType.pest:
        return '🐛';
      case AlertType.heatwave:
        return '🌡️';
      case AlertType.flood:
        return '🌊';
      case AlertType.drought:
        return '🏜️';
      case AlertType.frost:
        return '❄️';
    }
  }
}
