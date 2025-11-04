class OrderResponse {
  final String? message;
  final String? orderId;
  final List<OrderData>? data;
  final OrderStatus? orderStatus;

  OrderResponse({
    this.message,
    this.orderId,
    this.data,
    this.orderStatus,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      message: json['message'],
      orderId: json['orderId'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => OrderData.fromJson(e))
          .toList(),
      orderStatus: json['orderStatus'] != null
          ? OrderStatus.fromJson(json['orderStatus'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'orderId': orderId,
      'data': data?.map((e) => e.toJson()).toList(),
      'orderStatus': orderStatus?.toJson(),
    };
  }
}

class OrderData {
  final String? userId;
  final String? orderId;
  final String? productId;
  final int? productCount;
  final int? totalPrice;
  final int? currentOrderStatus;
  final DateTime? currentOrderStatusDate;
  final DateTime? deliveryDate;
  final String? id;
  final DateTime? orderDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  OrderData({
    this.userId,
    this.orderId,
    this.productId,
    this.productCount,
    this.totalPrice,
    this.currentOrderStatus,
    this.currentOrderStatusDate,
    this.deliveryDate,
    this.id,
    this.orderDate,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      userId: json['userId'],
      orderId: json['orderId'],
      productId: json['productId'],
      productCount: json['productCount'],
      totalPrice: json['totalPrice'],
      currentOrderStatus: json['currentOrderStatus'],
      currentOrderStatusDate: json['currentOrderStatusDate'] != null
          ? DateTime.tryParse(json['currentOrderStatusDate'])
          : null,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.tryParse(json['deliveryDate'])
          : null,
      id: json['_id'],
      orderDate: json['orderDate'] != null
          ? DateTime.tryParse(json['orderDate'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'orderId': orderId,
      'productId': productId,
      'productCount': productCount,
      'totalPrice': totalPrice,
      'currentOrderStatus': currentOrderStatus,
      'currentOrderStatusDate': currentOrderStatusDate?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      '_id': id,
      'orderDate': orderDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }
}

class OrderStatus {
  final String? userId;
  final String? orderId;
  final int? orderStatus;
  final DateTime? orderStatusDate;
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  OrderStatus({
    this.userId,
    this.orderId,
    this.orderStatus,
    this.orderStatusDate,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      userId: json['userId'],
      orderId: json['orderId'],
      orderStatus: json['orderStatus'],
      orderStatusDate: json['orderStatusDate'] != null
          ? DateTime.tryParse(json['orderStatusDate'])
          : null,
      id: json['_id'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'orderId': orderId,
      'orderStatus': orderStatus,
      'orderStatusDate': orderStatusDate?.toIso8601String(),
      '_id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }
}
