class EmergencyModel {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final String detectedText;
  final bool keywordDetected;
  final DateTime createdAt;

  EmergencyModel({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.detectedText,
    required this.keywordDetected,
    required this.createdAt,
  });

  factory EmergencyModel.fromJson(Map<String, dynamic> json) {
    return EmergencyModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      detectedText: json['detected_text'] as String? ?? '',
      keywordDetected: json['keyword_detected'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'detected_text': detectedText,
      'keyword_detected': keywordDetected,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
