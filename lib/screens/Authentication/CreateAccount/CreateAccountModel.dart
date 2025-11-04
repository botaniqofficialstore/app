class CreateAccountResponse {
  String? message;
  UserData? data;

  CreateAccountResponse({this.message, this.data});

  CreateAccountResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? UserData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['message'] = message;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}

class UserData {
  String? userId;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNumber;
  String? id;
  String? createdAt;
  int? v;

  UserData({
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.mobileNumber,
    this.id,
    this.createdAt,
    this.v,
  });

  UserData.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    mobileNumber = json['mobileNumber'];
    id = json['_id'];
    createdAt = json['createdAt'];
    v = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['userId'] = userId;
    dataMap['firstName'] = firstName;
    dataMap['lastName'] = lastName;
    dataMap['email'] = email;
    dataMap['mobileNumber'] = mobileNumber;
    dataMap['_id'] = id;
    dataMap['createdAt'] = createdAt;
    dataMap['__v'] = v;
    return dataMap;
  }
}
