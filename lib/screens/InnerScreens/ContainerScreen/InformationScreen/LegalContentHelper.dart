import '../../../../constants/Constants.dart';

class LegalContentHelper {
  static String getContent(ScreenName screen) {
    switch (screen) {
      case ScreenName.privacyPolicy:
        return _privacyPolicy;
      case ScreenName.termsAndCondition:
        return _termsAndConditions;
      case ScreenName.refundPolicy:
        return _refundPolicy;
      case ScreenName.shippingPolicy:
        return _shippingPolicy;
      case ScreenName.aboutUS:
        return _aboutUs;
      default:
        return '';
    }
  }

  // ---------------- PRIVACY POLICY ----------------

  static const String _privacyPolicy = '''
At BotaniQ, we value your privacy and are committed to protecting your personal information.

Information We Collect:
We collect personal details such as name, phone number, email address, delivery address, and order details to process orders and provide customer support.

Use of Information:
Your information is used for:
• Order processing and delivery
• Customer communication
• Service improvement
• Legal and regulatory compliance

Data Sharing:
We do not sell or misuse your personal data. Information may be shared with delivery partners or service providers strictly for order fulfillment.

Data Security:
We use reasonable security practices to protect your data in accordance with the Information Technology Act, 2000.

Data Retention:
Personal data is retained only as long as required to fulfill orders or comply with legal obligations.

User Rights:
You may request access, correction, or deletion of your personal data by contacting us.

Grievance Officer:
Email: support@botaniq.in  
Response Time: Within 48 hours

By using the BotaniQ app, you consent to this Privacy Policy.
''';

  // ---------------- TERMS & CONDITIONS ----------------

  static const String _termsAndConditions = '''
By accessing or using the BotaniQ app, you agree to the following terms and conditions.

Eligibility:
Users must be at least 18 years old to place orders.

Account Responsibility:
Users are responsible for maintaining the confidentiality of their account credentials.

Pricing & Availability:
Product prices, availability, and offers may change without prior notice.

Cash on Delivery (COD):
BotaniQ currently supports Cash on Delivery only.
We reserve the right to cancel COD orders in cases of:
• Incorrect or incomplete address
• Repeated order refusals
• Suspected fraudulent activity

Misuse of COD may result in account restriction or suspension.

Limitation of Liability:
BotaniQ shall not be liable for indirect or incidental damages arising from the use of the app.

Governing Law:
These terms are governed by the laws of India.
Any disputes shall be subject to Indian jurisdiction.
''';

  // ---------------- REFUND POLICY ----------------

  static const String _refundPolicy = '''
Customer satisfaction is important to us.

Refunds may be applicable in the following cases:
• Wrong product delivered
• Damaged or expired product
• Order not delivered

Refund Request Timeline:
Refund requests must be raised within 24 hours of delivery.

Refund Method (COD Orders):
For Cash on Delivery orders, refunds will be processed via bank transfer or wallet.
Customers must provide valid bank details for refund processing.

Processing Time:
Approved refunds will be completed within 5–7 business days.

Non-Refundable Items:
Perishable goods are non-refundable unless damaged or incorrect at the time of delivery.

BotaniQ reserves the right to reject refund requests that do not meet the above conditions.
''';

  // ---------------- SHIPPING POLICY ----------------

  static const String _shippingPolicy = '''
BotaniQ delivers organic products using trusted delivery partners.

Service Availability:
Delivery is available in selected locations only.

Dispatch Timeline:
Orders are generally dispatched within 24–48 hours after confirmation.

Delivery Time:
Delivery timelines may vary based on location, weather conditions, and product availability.

Customer Responsibility:
Customers must ensure accurate address and availability at the time of delivery.
BotaniQ is not responsible for delays caused by incorrect address or unavailability.

Delivery Charges:
Any applicable delivery charges will be displayed during checkout.

Order Tracking:
Customers can track their orders through the app.
''';

  // ---------------- ABOUT US ----------------

  static const String _aboutUs = '''
BotaniQ is a platform dedicated to promoting organic and natural products from local entrepreneurs and home-based sellers.

Our mission is to support small businesses while providing customers with healthy, ethically sourced products.

We believe in transparency, sustainability, and responsible commerce.

Business Information:
BotaniQ operates in India.
For support or queries, contact: support@botaniq.in

BotaniQ brings nature closer to your doorstep.
''';
}
