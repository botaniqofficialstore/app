class UserProfileResponse {
  final String message;
  final UserData data;

  UserProfileResponse({
    required this.message,
    required this.data,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      message: json['message'] ?? '',
      data: UserData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

class UserData {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String mobileNumber;
  final String createdAt;
  final String address;

  UserData({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNumber,
    required this.createdAt,
    required this.address,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      createdAt: json['createdAt'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobileNumber': mobileNumber,
      'createdAt': createdAt,
      'address': address,
    };
  }
}
