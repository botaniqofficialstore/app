import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import '../screens/InnerScreens/ContainerScreen/CartScreen/CartModel.dart';
import '../screens/InnerScreens/ContainerScreen/OrderScreen/OrderModel.dart';


//MARK: - Class Declarations
class ConstantURLs {
  static String baseUrl = 'http://192.168.43.216:5000';//'http://localhost:5000';

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
  orderDetails
}


///MARK: - Common Variables
final List<String> footerIcons = [
  objConstantAssest.homeIcon,
  objConstantAssest.reelsIcon,
  objConstantAssest.cartIcon,
  objConstantAssest.orderIcon,
  objConstantAssest.profileIcon
];



// ✅ Product List
final List<Map<String, dynamic>> products = [
  {
    "id": 5001,
    "name": "Amaranthus",
    "price": 139,
    "actualPrice": 199,
    "offer": 30,
    "gram": "80gm",
    "image": objConstantAssest.amaranthus,
    "isWish": false,
    "count": 1,
  },
  {
    "id": 5002,
    "name": "Sunflower",
    "price": 149,
    "actualPrice": 189,
    "offer": 20,
    "gram": "50gm",
    "image": objConstantAssest.sunflower,
    "isWish": false,
    "count": 1,
  },
  {
    "id": 5003,
    "name": "Green Mustard",
    "price": 149,
    "actualPrice": 179,
    "offer": 10,
    "gram": "50gm",
    "image": objConstantAssest.mustard,
    "isWish": false,
    "count": 1,
  },
  {
    "id": 5004,
    "name": "Radish Pink",
    "price": 189,
    "actualPrice": 219,
    "offer": 16,
    "gram": "80gm",
    "image": objConstantAssest.radishPink,
    "isWish": false,
    "count": 1,
  },
  {
    "id": 5005,
    "name": "Pakchoi",
    "price": 169,
    "actualPrice": 199,
    "offer": 15,
    "gram": "50gm",
    "image": objConstantAssest.pakchoi,
    "isWish": false,
    "count": 1,
  },
  {
    "id": 5006,
    "name": "Broccoli",
    "price": 159,
    "actualPrice": 189,
    "offer": 30,
    "gram": "50gm",
    "image": objConstantAssest.broccoli,
    "isWish": false,
    "count": 1,
  },
  {
    "id": 5007,
    "name": "Beetroot",
    "price": 189,
    "actualPrice": 229,
    "offer": 45,
    "gram": "50gm",
    "image": objConstantAssest.beetroot,
    "isWish": false,
    "count": 1,
  }
];


/// Example Cart Data
List<Map<String, dynamic>> cartList = [];

List<Map<String, dynamic>> wishList = [];

List<Map<String, dynamic>> productDetail = [];

List<Map<String, dynamic>> orderList = [];

List<CartItem> savedCartItems = [];
OrderDataList? savedOrderData ;
ProductDetailStatus? savedProductDetails;



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



final List<Map<String, dynamic>> productDetailsMaster = [
  {
    "id": 5001, // Amaranthus
    "image": objConstantAssest.amaranthasBackground,
    "name": "Amaranthus",
    "description": "Red Amaranthus Microgreens are the young, vibrant shoots of the red amaranth plant, harvested at their early growth stage when nutrient concentration is highest. With their striking red-purple leaves and mild, earthy flavor, they add a splash of color and a burst of nutrition to salads, wraps, smoothies, and gourmet dishes. Known for their exceptional vitamin, mineral, and antioxidant content, these microgreens are both a culinary delight and a health-boosting superfood.",
    "nutrients": [
      {
        "vitamin": "Vitamin A",
        "benefit": "Good vision & skin"
      },
      {
        "vitamin": "Vitamin C",
        "benefit": "Immunity support"
      },
      {
        "vitamin": "Vitamin K",
        "benefit": "Bone & joint strength"
      },
      {
        "vitamin": "Folate",
        "benefit": "Cell growth and repair"
      },
      {
        "vitamin": "Calcium & Magnesium",
        "benefit": "Bone health"
      },
      {
        "vitamin": "Iron",
        "benefit": "Prevents anemia, supports blood"
      },
      {
        "vitamin": "Protein",
        "benefit": "Muscle growth and repair"
      }
    ]
  },
  {
    "id": 5002, // Sunflower
    "name": "Sunflower",
    "image": objConstantAssest.sunflowerBackground,
    "description": "Sunflower Microgreens are young, tender seedlings of the sunflower plant, harvested just after the cotyledon leaves have developed. They are crisp, nutty, and slightly sweet in flavor, making them a delicious and nutrient-dense addition to salads, sandwiches, smoothies, and garnishes. Packed with essential vitamins, minerals, and plant-based protein, they are a favorite among health-conscious individuals and chefs.",
    "nutrients": [
      {
        "vitamin": "Vitamin A",
        "benefit": "Improves vision, skin, and immunity"
      },
      {
        "vitamin": "Vitamin B1 & B6",
        "benefit": "Boosts energy and brain function"
      },
      {
        "vitamin": "Vitamin C",
        "benefit": "Strengthens immunity, antioxidant"
      },
      {
        "vitamin": "Vitamin D",
        "benefit": "Supports bone health"
      },
      {
        "vitamin": "Vitamin E",
        "benefit": "Healthy skin & anti-aging"
      },
      {
        "vitamin": "Calcium & Magnesium",
        "benefit": "Strong bones and teeth"
      },
      {
        "vitamin": "Iron",
        "benefit": "Prevents anemia, improves blood health"
      }
    ]
  },
  {
    "id": 5003, // Green Mustard
    "name": "Green Mustard",
    "image": objConstantAssest.greenMustardBackground,
    "description": "Green Mustard Microgreens are the tender, young shoots of the mustard plant, harvested within 7–10 days of sprouting when their flavor and nutrients are at their peak. They have a bold, peppery taste with a hint of spice, making them a flavorful addition to salads, sandwiches, stir-fries, and garnishes. Packed with vitamins, minerals, and potent plant compounds, green mustard microgreens are a nutrient-dense superfood that supports overall health and wellness.",
    "nutrients": [
      {
        "vitamin": "Vitamin A",
        "benefit": "Improves vision & skin"
      },
      {
        "vitamin": "Vitamin C",
        "benefit": "Boosts immunity"
      },
      {
        "vitamin": "Vitamin K",
        "benefit": "Bone strength & blood clotting"
      },
      {
        "vitamin": "Folate",
        "benefit": "Supports healthy cells"
      },
      {
        "vitamin": "Calcium",
        "benefit": "Strong bones & teeth"
      },
      {
        "vitamin": "Potassium",
        "benefit": "Supports heart health & muscle function"
      },
      {
        "vitamin": "Phytonutrients",
        "benefit": "Detoxifies liver & reduces inflammation"
      }
    ]
  },
  {
    "id": 5004,
    "name": "Radish Pink",
    "image": objConstantAssest.radishPinkBackground,
    "description": "Radish Pink Microgreens are the vibrant, tender seedlings of pink radish plants, harvested just after the first leaves emerge. They have a crisp texture and a zesty, peppery flavor, adding both color and a flavorful punch to salads, sandwiches, and garnishes. Packed with essential vitamins, minerals, and antioxidants, these microgreens are as nutritious as they are beautiful, making them a favorite for both culinary use and health benefits.",
    "nutrients": [
      {
        "vitamin": "Vitamin A",
        "benefit": "Improves vision & keeps skin healthy"
      },
      {
        "vitamin": "Vitamin B6",
        "benefit": "Boosts energy and supports brain function"
      },
      {
        "vitamin": "Vitamin C",
        "benefit": "Strong immunity & collagen production"
      },
      {
        "vitamin": "Vitamin K",
        "benefit": "Strengthens bones & supports blood clotting"
      },
      {
        "vitamin": "Folate",
        "benefit": "Healthy cell growth & repair"
      },
      {
        "vitamin": "Potassium",
        "benefit": "Regulates blood pressure & muscle function"
      },
      {
        "vitamin": "Calcium & Magnesium",
        "benefit": "Strong bones & reduces muscle cramps"
      },
      {
        "vitamin": "Anthocyanins",
        "benefit": "Powerful antioxidants, anti-aging & heart protective"
      }
    ]
  },
  {
    "id": 5005, // Pakchoi (Bok Choy)
    "name": "Pakchoi",
    "image": objConstantAssest.pakchoiBackground,
    "description": "Pakchoi Microgreens are the young, tender shoots of the pakchoi (bok choy) plant, harvested within 7–10 days of germination when their flavor and nutrients are at their peak. They have a mild, slightly sweet, and cabbage-like taste, making them perfect for salads, sandwiches, soups, and stir-fry toppings. Packed with essential vitamins, minerals, and antioxidants, pakchoi microgreens are a powerhouse of nutrition in a small, delicate form.",
    "nutrients": [
      {
        "vitamin": "Vitamin A",
        "benefit": "Eye and skin health"
      },
      {
        "vitamin": "Vitamin C",
        "benefit": "Boosts immunity"
      },
      {
        "vitamin": "Vitamin K",
        "benefit": "Bone strength and blood clotting"
      },
      {
        "vitamin": "Folate",
        "benefit": "Supports cell growth and pregnancy health"
      },
      {
        "vitamin": "Calcium",
        "benefit": "Strong bones & teeth"
      },
      {
        "vitamin": "Iron",
        "benefit": "Red blood cell support"
      }
    ]
  },
  {
    "id": 5006, // Broccoli
    "name": "Broccoli",
    "image": objConstantAssest.broccoliBackground,
    "description": "Broccoli Microgreens are the young, tender shoots of the broccoli plant, harvested within 7–10 days of germination when they are at peak nutrient density. They have a mild, slightly peppery flavor and are packed with powerful phytonutrients, making them a superfood in the microgreens family. Often considered more nutrient-rich than mature broccoli, they are a favorite among health enthusiasts and chefs for both taste and wellness benefits.",
    "nutrients": [
      {
        "vitamin": "Vitamin A",
        "benefit": "Eye & skin health"
      },
      {
        "vitamin": "Vitamin C",
        "benefit": "Boosts immunity"
      },
      {
        "vitamin": "Vitamin K",
        "benefit": "Bone and heart health"
      },
      {
        "vitamin": "Folate",
        "benefit": "Healthy cell growth"
      },
      {
        "vitamin": "Calcium",
        "benefit": "Strong bones and teeth"
      },
      {
        "vitamin": "Iron",
        "benefit": "Better blood health"
      },
      {
        "vitamin": "Sulforaphane",
        "benefit": "Anti-cancer & detox support"
      }
    ]
  },
  {
    "id": 5007, // Beetroot
    "name": "Beetroot",
    "image": objConstantAssest.beetrootBackground,
    "description": "Beetroot Microgreens are the tender, colorful seedlings of the beet plant, harvested at their early growth stage when nutrient concentration is at its peak. With their vibrant red stems and earthy-sweet flavor, they add both beauty and nutrition to salads, wraps, smoothies, and gourmet dishes. These microgreens are packed with essential vitamins, minerals, and antioxidants, making them a delicious and health-boosting addition to any diet.",
    "nutrients": [
      {
        "vitamin": "Vitamin A",
        "benefit": "Healthy skin & eyes"
      },
      {
        "vitamin": "Vitamin C",
        "benefit": "Strengthens immunity"
      },
      {
        "vitamin": "Vitamin K",
        "benefit": "Blood clotting & bone strength"
      },
      {
        "vitamin": "Folate",
        "benefit": "Red blood cell formation"
      },
      {
        "vitamin": "Iron & Magnesium",
        "benefit": "Improves circulation, prevents anemia"
      },
      {
        "vitamin": "Potassium",
        "benefit": "Lowers blood pressure"
      }
    ]
  }
];













