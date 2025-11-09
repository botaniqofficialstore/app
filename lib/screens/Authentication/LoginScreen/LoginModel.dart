class LoginResponse {
  String? message;
  String? userId;
  String? accessToken;
  String? refreshToken;
  String? loginActivityId;

  LoginResponse({this.message, this.userId, this.accessToken, this.refreshToken, this.loginActivityId });

  LoginResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    userId = json['userId'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    loginActivityId = json['loginActivityId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['userId'] = userId;
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    data['loginActivityId'] = loginActivityId;
    return data;
  }
}