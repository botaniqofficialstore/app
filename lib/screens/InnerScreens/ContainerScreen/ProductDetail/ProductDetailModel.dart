class ProductDetailResponse {
  final String message;
  final ProductData data;

  ProductDetailResponse({
    required this.message,
    required this.data,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponse(
      message: json['message'] ?? '',
      data: ProductData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

class ProductData {
  final String productId;
  final String productName;
  final int productPrice;
  final int productSellingPrice;
  final String image;
  final String coverImage;
  final String description;
  final List<Nutrient> nutrients;

  // 🧠 Optional local tracking fields
  int isWishlisted;
  int inCart;
  int count;

  ProductData({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productSellingPrice,
    required this.image,
    required this.coverImage,
    required this.description,
    required this.nutrients,
    this.isWishlisted = 0,
    this.inCart = 0,
    this.count = 0,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productPrice: json['productPrice'] ?? 0,
      productSellingPrice: json['productSellingPrice'] ?? 0,
      image: json['image'] ?? '',
      coverImage: json['coverImage'] ?? '',
      description: json['description'] ?? '',
      nutrients: (json['nutrients'] as List<dynamic>?)
          ?.map((e) => Nutrient.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'productSellingPrice': productSellingPrice,
      'image': image,
      'coverImage': coverImage,
      'description': description,
      'nutrients': nutrients.map((e) => e.toJson()).toList(),
      'isWishlisted': isWishlisted,
      'inCart': inCart,
      'count': count,
    };
  }
}

class Nutrient {
  final String vitamin;
  final String benefit;
  final String id;

  Nutrient({
    required this.vitamin,
    required this.benefit,
    required this.id,
  });

  factory Nutrient.fromJson(Map<String, dynamic> json) {
    return Nutrient(
      vitamin: json['vitamin'] ?? '',
      benefit: json['benefit'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vitamin': vitamin,
      'benefit': benefit,
      '_id': id,
    };
  }
}
