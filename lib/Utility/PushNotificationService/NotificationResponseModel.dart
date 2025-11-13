class DeviceRegisterResponse {
  final String message;
  final DeviceData? data;

  DeviceRegisterResponse({
    required this.message,
    this.data,
  });

  factory DeviceRegisterResponse.fromJson(Map<String, dynamic> json) {
    return DeviceRegisterResponse(
      message: json['message'] ?? '',
      data: json['data'] != null ? DeviceData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class DeviceData {
  final String id;
  final String userId;
  final String deviceType;
  final String fcmToken;
  final String createdAt;
  final String updatedAt;
  final int v;

  DeviceData({
    required this.id,
    required this.userId,
    required this.deviceType,
    required this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      deviceType: json['deviceType'] ?? '',
      fcmToken: json['fcmToken'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'deviceType': deviceType,
      'fcmToken': fcmToken,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}
