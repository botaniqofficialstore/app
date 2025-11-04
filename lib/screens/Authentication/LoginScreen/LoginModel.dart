class LoginResponse {
  String? message;
  String? userID;
  String? accessToken;
  String? refreshToken;
  String? loginActivityId;

  LoginResponse({this.message, this.accessToken, this.refreshToken, this.loginActivityId, this.userID});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    userID = json['userId'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    loginActivityId = json['loginActivityId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['userId'] = userID;
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    data['loginActivityId'] = loginActivityId;
    return data;
  }
}