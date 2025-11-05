class CountResponse {
  final String message;
  final int cartCount;
  final int wishlistCount;
  final int totalCount;

  CountResponse({
    required this.message,
    required this.cartCount,
    required this.wishlistCount,
    required this.totalCount,
  });

  factory CountResponse.fromJson(Map<String, dynamic> json) {
    return CountResponse(
      message: json['message'] ?? '',
      cartCount: json['cartCount'] ?? 0,
      wishlistCount: json['wishlistCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'cartCount': cartCount,
      'wishlistCount': wishlistCount,
      'totalCount': totalCount,
    };
  }
}
