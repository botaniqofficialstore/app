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

  static const String _privacyPolicy = '''
At BotaniQ, your privacy is important to us.

We collect personal information such as your name, phone number, email address, and delivery address to process orders and provide a better experience.

Your data is used only for order fulfillment, communication, and service improvement.

We do not sell or misuse your personal information. Industry-standard security measures are used to protect your data.

Third-party services like payment gateways and analytics tools may collect data under their respective privacy policies.

You may request access, correction, or deletion of your personal data at any time.
''';

  static const String _termsAndConditions = '''
By using the BotaniQ app, you agree to the following terms.

Users must be at least 18 years old to place orders.

Product prices, availability, and offers may change without prior notice.

Users are responsible for maintaining the confidentiality of their account details.

Any misuse, fraudulent activity, or violation of applicable laws may result in account suspension.
''';

  static const String _refundPolicy = '''
Customer satisfaction is important to us.

Refunds may be provided in the following cases:
• Wrong product delivered
• Damaged or expired product
• Order not delivered

Refund requests must be raised within 24 hours of delivery.

Approved refunds will be processed to the original payment method within 5–7 business days.

Perishable items are non-refundable unless damaged or incorrect.
''';

  static const String _shippingPolicy = '''
BotaniQ delivers organic products using trusted delivery partners.

Delivery is available in selected cities and locations.

Estimated delivery time may vary depending on location and product availability.

Delivery charges, if applicable, will be displayed during checkout.

Customers can track their orders in real time through the app.
''';

  static const String _aboutUs = '''
BotaniQ is a platform built to support local organic entrepreneurs and home-based sellers.

Our mission is to connect customers with natural and organic products while empowering small businesses.

We believe in healthy living, ethical sourcing, and transparent commerce.

BotaniQ brings nature closer to your doorstep.
''';
}
