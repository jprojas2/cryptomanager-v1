import 'package:crypto_manager/models/concerns/valorizable.dart';
import 'package:crypto_manager/services/price_finder.dart';
import 'account.dart';

class LineItem extends Valorizable {
  double quantity = 0.0;
  late double price;
  late double buyPrice;
  double amount = 0.0;
  late double profit;
  late Account account;

  LineItem(String coin, this.account,
      [double? quantity, PriceFinder? priceFinder])
      : super(coin) {
    if (priceFinder != null) {
      this.priceFinder = priceFinder;
    } else {
      this.priceFinder = PriceFinder.instances[0];
    }
    if (quantity != null) this.quantity = quantity;
  }
}
