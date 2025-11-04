class OrdersResponse {
  final String message;
  final int total;
  final int page;
  final int limit;
  final List<OrderDataList> data;

  OrdersResponse({
    required this.message,
    required this.total,
    required this.page,
    required this.limit,
    required this.data,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      message: json['message'] ?? '',
      total: json['total'] ?? 0,
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => OrderDataList.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'total': total,
    'page': page,
    'limit': limit,
    'data': data.map((e) => e.toJson()).toList(),
  };
}

class OrderDataList {
  final String orderId;
  final String userId;
  final String orderDate;
  final String? deliveryDate;
  final int currentOrderStatus;
  final String currentOrderStatusDate;
  final int orderTotalAmount;
  final List<OrderDetail> orderDetails;
  final List<OrderTracking> orderTracking;

  OrderDataList({
    required this.orderId,
    required this.userId,
    required this.orderDate,
    this.deliveryDate,
    required this.currentOrderStatus,
    required this.currentOrderStatusDate,
    required this.orderTotalAmount,
    required this.orderDetails,
    required this.orderTracking,
  });

  factory OrderDataList.fromJson(Map<String, dynamic> json) {
    return OrderDataList(
      orderId: json['orderId'] ?? '',
      userId: json['userId'] ?? '',
      orderDate: json['orderDate'] ?? '',
      deliveryDate: json['deliveryDate'],
      currentOrderStatus: json['currentOrderStatus'] ?? 0,
      currentOrderStatusDate: json['currentOrderStatusDate'] ?? '',
        orderTotalAmount: json['orderTotalAmount'] ?? 0,
      orderDetails: (json['orderDetails'] as List<dynamic>?)
          ?.map((e) => OrderDetail.fromJson(e))
          .toList() ??
          [],
      orderTracking: (json['orderTracking'] as List<dynamic>?)
          ?.map((e) => OrderTracking.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'userId': userId,
    'orderDate': orderDate,
    'deliveryDate': deliveryDate,
    'currentOrderStatus': currentOrderStatus,
    'currentOrderStatusDate': currentOrderStatusDate,
    'orderTotalAmount': orderTotalAmount,
    'orderDetails': orderDetails.map((e) => e.toJson()).toList(),
    'orderTracking': orderTracking.map((e) => e.toJson()).toList(),
  };
}

class OrderDetail {
  final String productId;
  final int productCount;
  final int totalPrice;
  final ProductDetails productDetails;

  OrderDetail({
    required this.productId,
    required this.productCount,
    required this.totalPrice,
    required this.productDetails,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      productId: json['productId'] ?? '',
      productCount: json['productCount'] ?? 0,
      totalPrice: json['totalPrice'] ?? 0,
      productDetails: ProductDetails.fromJson(json['productDetails'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productCount': productCount,
    'totalPrice': totalPrice,
    'productDetails': productDetails.toJson(),
  };
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

  Map<String, dynamic> toJson() => {
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

class OrderTracking {
  final int orderStatus;
  final String orderStatusDate;

  OrderTracking({
    required this.orderStatus,
    required this.orderStatusDate,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      orderStatus: json['orderStatus'] ?? 0,
      orderStatusDate: json['orderStatusDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'orderStatus': orderStatus,
    'orderStatusDate': orderStatusDate,
  };
}








class CancelOrderResponseModel {
  final String message;
  final int deletedCount;
  final OrderStatus? orderStatus;

  CancelOrderResponseModel({
    required this.message,
    required this.deletedCount,
    this.orderStatus,
  });

  factory CancelOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return CancelOrderResponseModel(
      message: json['message'] ?? '',
      deletedCount: json['deletedCount'] ?? 0,
      orderStatus: json['orderStatus'] != null
          ? OrderStatus.fromJson(json['orderStatus'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'deletedCount': deletedCount,
      'orderStatus': orderStatus?.toJson(),
    };
  }
}

class OrderStatus {
  final String id;
  final String userId;
  final String orderId;
  final int orderStatus;
  final String orderStatusDate;

  OrderStatus({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.orderStatus,
    required this.orderStatusDate,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      orderId: json['orderId'] ?? '',
      orderStatus: json['orderStatus'] ?? 0,
      orderStatusDate: json['orderStatusDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'orderId': orderId,
      'orderStatus': orderStatus,
      'orderStatusDate': orderStatusDate,
    };
  }
}
