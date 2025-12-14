import 'package:intl/intl.dart';

class DeliveryUtils {

  /// Returns expected delivery text like: "Delivery expected by 6 Dec, Sat"
  static String getExpectedDeliveryDate(int dayCount) {
    // Current date in IST
    DateTime now = DateTime.now().toLocal();

    // Add the number of days
    DateTime deliveryDate = now.add(Duration(days: dayCount));

    // Format date as "6 Dec"
    String formattedDate = DateFormat("d MMM").format(deliveryDate);

    // Format weekday as "Sat, Mon..."
    String formattedDay = DateFormat("EEE").format(deliveryDate);

    // Return formatted string
    return 'Delivery expected by $formattedDate, $formattedDay';
  }
}
