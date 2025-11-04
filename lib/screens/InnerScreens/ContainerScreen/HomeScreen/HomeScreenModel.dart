class ProductListResponse {
  final String message;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final List<ProductData> data;

  ProductListResponse({
    required this.message,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.data,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      message: json['message'] ?? '',
      totalItems: json['totalItems'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => ProductData.fromJson(item))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'totalItems': totalItems,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class ProductData {
  final String id;
  final String productId;
  final String productName;
  final int productPrice;
  final int productSellingPrice;
  final int gram;
  final String image;
  final String coverImage;
  final String createdAt;
  final String updatedAt;
  final int v;
  final int isWishlisted;
  final int inCart;

  ProductData({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productSellingPrice,
    required this.gram,
    required this.image,
    required this.coverImage,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.isWishlisted,
    required this.inCart,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      id: json['_id'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productPrice: json['productPrice'] ?? 0,
      productSellingPrice: json['productSellingPrice'] ?? 0,
      gram: json['gram'] ?? 0,
      image: json['image'] ?? '',
      coverImage: json['coverImage'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
      isWishlisted: json['isWishlisted'] ?? 0,
      inCart: json['inCart'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'productSellingPrice': productSellingPrice,
      'gram': gram,
      'image': image,
      'coverImage': coverImage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'isWishlisted': isWishlisted,
      'inCart': inCart,
    };
  }
}
