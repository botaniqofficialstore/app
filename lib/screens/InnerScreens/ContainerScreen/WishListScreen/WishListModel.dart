class WishListResponse {
  final String? message;
  final int? total;
  final int? page;
  final int? limit;
  final List<WishListItem>? data;

  WishListResponse({
    this.message,
    this.total,
    this.page,
    this.limit,
    this.data,
  });

  factory WishListResponse.fromJson(Map<String, dynamic> json) {
    return WishListResponse(
      message: json['message'],
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => WishListItem.fromJson(e))
          .toList(),
    );
  }
}

class WishListItem {
  final String? userId;
  final String? productId;
  final DateTime? addedAt;
  final int? inCart; // ✅ Move this here (from ProductDetailsData)
  final ProductDetailsData? productDetails;

  WishListItem({
    this.userId,
    this.productId,
    this.addedAt,
    this.inCart,
    this.productDetails,
  });

  factory WishListItem.fromJson(Map<String, dynamic> json) {
    return WishListItem(
      userId: json['userId'],
      productId: json['productId'],
      addedAt: json['addedAt'] != null
          ? DateTime.tryParse(json['addedAt'])
          : null,
      inCart: json['inCart'], // ✅ Correct mapping
      productDetails: json['productDetails'] != null
          ? ProductDetailsData.fromJson(json['productDetails'])
          : null,
    );
  }
}


class ProductDetailsData {
  final String? id;
  final String? productId;
  final String? productName;
  final int? productPrice;
  final int? productSellingPrice;
  final int? gram;
  final String? image;
  final String? coverImage;

  ProductDetailsData({
    this.id,
    this.productId,
    this.productName,
    this.productPrice,
    this.productSellingPrice,
    this.gram,
    this.image,
    this.coverImage,
  });

  factory ProductDetailsData.fromJson(Map<String, dynamic> json) {
    return ProductDetailsData(
      id: json['_id'],
      productId: json['productId'],
      productName: json['productName'],
      productPrice: json['productPrice'],
      productSellingPrice: json['productSellingPrice'],
      gram: json['gram'],
      image: json['image'],
      coverImage: json['coverImage'],
    );
  }
}



class WishListRemoveResponse {
  final String message;

  WishListRemoveResponse({
    required this.message,
  });

  factory WishListRemoveResponse.fromJson(Map<String, dynamic> json) {
    return WishListRemoveResponse(
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}


class AddToWishlistResponse {
  final String? message;
  final WishlistData? data;

  AddToWishlistResponse({
    this.message,
    this.data,
  });

  factory AddToWishlistResponse.fromJson(Map<String, dynamic> json) {
    return AddToWishlistResponse(
      message: json['message'] as String?,
      data: json['data'] != null
          ? WishlistData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class WishlistData {
  final String? userId;
  final String? productId;
  final String? id;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  WishlistData({
    this.userId,
    this.productId,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory WishlistData.fromJson(Map<String, dynamic> json) {
    return WishlistData(
      userId: json['userId'] as String?,
      productId: json['productId'] as String?,
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
      '_id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}
