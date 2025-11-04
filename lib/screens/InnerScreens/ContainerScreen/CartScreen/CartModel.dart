
//MARK :- Cart Product List
class CartResponse {
  final String message;
  final int total;
  final int page;
  final int limit;
  final List<CartItem> data;

  CartResponse({
    required this.message,
    required this.total,
    required this.page,
    required this.limit,
    required this.data,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      message: json['message'] ?? '',
      total: json['total'] ?? 0,
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => CartItem.fromJson(item))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'total': total,
      'page': page,
      'limit': limit,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class CartItem {
  final String userId;
  final String productId;
  final int productCount;
  final String addedAt;
  final ProductDetails? productDetails;

  CartItem({
    required this.userId,
    required this.productId,
    required this.productCount,
    required this.addedAt,
    this.productDetails,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      productCount: json['productCount'] ?? 0,
      addedAt: json['addedAt'] ?? '',
      productDetails: json['productDetails'] != null
          ? ProductDetails.fromJson(json['productDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': productId,
      'productCount': productCount,
      'addedAt': addedAt,
      'productDetails': productDetails?.toJson(),
    };
  }

  CartItem copyWith({
    String? userId,
    String? productId,
    int? productCount,
    String? addedAt,
    ProductDetails? productDetails,
  }) {
    return CartItem(
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productCount: productCount ?? this.productCount,
      addedAt: addedAt ?? this.addedAt,
      productDetails: productDetails ?? this.productDetails,
    );
  }

}

class ProductDetails {
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

  ProductDetails({
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
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
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
    };
  }
}


//MARK :- Update Cart Product Count
class CartUpdateResponse {
  final String message;
  final CartUpdateData? data;

  CartUpdateResponse({
    required this.message,
    this.data,
  });

  factory CartUpdateResponse.fromJson(Map<String, dynamic> json) {
    return CartUpdateResponse(
      message: json['message'] ?? '',
      data: json['data'] != null ? CartUpdateData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class CartUpdateData {
  final String id;
  final String userId;
  final String productId;
  final int productCount;
  final String createdAt;
  final String updatedAt;
  final int v;

  CartUpdateData({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productCount,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory CartUpdateData.fromJson(Map<String, dynamic> json) {
    return CartUpdateData(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      productCount: json['productCount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'productId': productId,
      'productCount': productCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}


//MARK :- Remove from Cart
class CartRemoveResponse {
  final String message;

  CartRemoveResponse({
    required this.message,
  });

  factory CartRemoveResponse.fromJson(Map<String, dynamic> json) {
    return CartRemoveResponse(
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}



//MARK :- Add to Cart
class AddToCartResponse {
  final String? message;
  final CartData? data;

  AddToCartResponse({
    this.message,
    this.data,
  });

  factory AddToCartResponse.fromJson(Map<String, dynamic> json) {
    return AddToCartResponse(
      message: json['message'] as String?,
      data: json['data'] != null ? CartData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class CartData {
  final String? userId;
  final String? productId;
  final int? productCount;
  final String? id;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  CartData({
    this.userId,
    this.productId,
    this.productCount,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory CartData.fromJson(Map<String, dynamic> json) {
    return CartData(
      userId: json['userId'] as String?,
      productId: json['productId'] as String?,
      productCount: json['productCount'] as int?,
      id: json['_id'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': productId,
      'productCount': productCount,
      '_id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}
