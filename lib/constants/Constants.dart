import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import '../screens/InnerScreens/ContainerScreen/CartScreen/CartModel.dart';
import '../screens/InnerScreens/ContainerScreen/OrderScreen/OrderModel.dart';


//MARK: - Class Declarations
class ConstantURLs {
  static String baseUrl = 'https://app-1q5g.onrender.com'; //'http://192.168.43.216:5000';

  ///Authentication API URL's
  static String manualLoginUrl = "$baseUrl/api/login";
  static String socialLoginUrl = "$baseUrl/api/social-login";
  static String createPasswordUrl = "$baseUrl/api/create-password";
  static String getOtpUrl = "$baseUrl/api/send-otp";
  static String changePassword = "$baseUrl/api/update-password";
  static String resendOtpUrl = "$baseUrl/api/resend-otp";
  static String verifyOtpUrl = "$baseUrl/api/verify-otp";
  static String logoutUrl = "$baseUrl/api/logout";
  static String refreshTokenUrl = "$baseUrl/api/refresh-token";

  static String sendOTPUrl = "$baseUrl/api/send-otp";
  static String verifyOTPUrl = "$baseUrl/api/verify-otp";
  static String reSendOTPUrl = "$baseUrl/api/resend-otp";

  ///Customer API URL's
  static String createUser = "$baseUrl/api/users";
  static String updateCustomerUrl = "$baseUrl/api/users/";
  static String deleteCustomer = "$baseUrl/api/users/";
  static String customerProfileUrl = "$baseUrl/api/users/";

  ///Product Master API URL's
  static String productListUrl = "$baseUrl/api/product?";
  static String productDetailsUrl = "$baseUrl/api/product-details/";

  ///Wish List API URL's
  static String addRemoveWishListUrl = "$baseUrl/api/wishlist";
  static String getWishListUrl = "$baseUrl/api/wishlist?";

  ///Cart API URL's
  static String addRemoveCountUpdateCartUrl = "$baseUrl/api/cart";
  static String cartListUrl = "$baseUrl/api/cart?";

  ///Order API URL's
  static String placeOrderUrl = "$baseUrl/api/orders";
  static String orderListUrl = "$baseUrl/api/orders?";

  ///Count API URL
  static String countUrl = "$baseUrl/api/count?userId=";

  ///Notification API URL
  static String deviceRegisterUrl = "$baseUrl/api/notifications/register";
  static String deviceUnregisterUrl = "$baseUrl/api/notifications/unregister";

  ///Reels API URL
  static String reelListUrl = '$baseUrl/api/reels/list';
  static String reelLikeDislikeUrl = '$baseUrl/api/reels/like';


}

class NotificationCenterId {
  static String updateUserProfile = 'UpdateUserProfile';
  static String refreshTokenAPIResponse = 'refreshTokenAPIResponse';
  static String apnPushNotificationResponse = 'apnPushNotificationResponse';
  static String refreshFooterCount = 'refreshFooterCount';
}



///MARK: - Enum
enum ScreenName {
  home,
  reels,
  cart,
  profile,
  editProfile,
  orders,
  wishList,
  productDetail,
  orderSummary,
  login,
  otp,
  createAccount,
  forgotPassword,
  orderDetails,
  map,
  information,
  privacyPolicy,
  termsAndCondition,
  refundPolicy,
  shippingPolicy,
  aboutUS
}


///MARK: - Common Variables
final List<String> footerIcons = [
  objConstantAssest.homeIcon,
  objConstantAssest.reelsIcon,
  objConstantAssest.cartIcon,
  objConstantAssest.orderIcon,
  objConstantAssest.profileIcon
];





/// Local Saved Arrays
List<CartItem> savedCartItems = [];
OrderDataList? savedOrderData ;
ProductDetailStatus? savedProductDetails;
FooterCount ? savedFooterCount;
ScreenName? userFrom;
String exactAddress = '';
ScreenName? selectedLegalInformation;


//This Class is used to save Footer Count
class FooterCount {
  int cartCount;
  int wishListCount;

  FooterCount({
    this.cartCount = 0,
    this.wishListCount = 0
  });

  Map<String, dynamic> toJson() {
    return {
      'cartCount': cartCount,
      'wishListCount': wishListCount
    };
  }
}



//This method is used to store the product details and shared to product details screen
class ProductDetailStatus {
  int isWishlisted;
  int inCart;
  int count;
  String coverImage;
  String productID;

  ProductDetailStatus({
    this.isWishlisted = 0,
    this.inCart = 0,
    this.count = 0,
    this.coverImage = '',
    this.productID = ''
  });

  // Convert to JSON (for storing in local storage or APIs)
  Map<String, dynamic> toJson() {
    return {
      'isWishlisted': isWishlisted,
      'inCart': inCart,
      'count': count,
      'coverImage': coverImage,
      'productID': productID
    };
  }

  // Create from JSON (for reading from storage or APIs)
  factory ProductDetailStatus.fromJson(Map<String, dynamic> json) {
    return ProductDetailStatus(
      isWishlisted: json['isWishlisted'] ?? 0,
      inCart: json['inCart'] ?? 0,
      count: json['count'] ?? 0,
      coverImage: json['coverImage'] ?? '',
        productID: json['productID'] ?? ''
    );
  }
}


final steps = [
  "Order Placed",
  "Order Confirmed",
  "Harvested",
  "Packed & Shipped",
  "Out for Delivery",
  "Delivered",
];
















