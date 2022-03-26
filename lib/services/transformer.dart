import 'package:crypto_manager/models/account.dart';
import 'package:crypto_manager/models/line_item.dart';
import 'package:crypto_manager/models/template.dart';
import 'package:crypto_manager/models/template_item.dart';
import 'package:crypto_manager/services/price_finder.dart';
import 'package:decimal/decimal.dart';

class Transformer {
  late Account account;

  final double fee = 0.0;
  late PriceFinder _priceFinder;

  List<Map<String, dynamic>> transactions = [];
  Map<String, dynamic>? availableSymbols;

  Transformer(this.account) {
    _priceFinder = PriceFinder.instances[account.type];
  }

  Future<List<Map<String, dynamic>>> transform(Template template) async {
    Map<String, double> positiveDiff = {};
    Map<String, double> negativeDiff = {};

    Map<String, LineItem> indexedLineItems = {};
    Map<String, TemplateItem> indexedTemplateItems = {};

    List<String> templateCoins = template.items.map((v) {
      indexedTemplateItems[v.coin!] = v;
      return v.coin!;
    }).toList();
    List<String> accountCoins = account.lineItems.map((v) {
      indexedLineItems[v.coin!] = v;
      return v.coin!;
    }).toList();

    List<String> allCoins = (templateCoins + accountCoins).toSet().toList();
    await Future.wait(allCoins.map((coin) async {
      LineItem? lineItem = indexedLineItems[coin];
      TemplateItem? templateItem = indexedTemplateItems[coin];
      double finalWeight = templateItem != null ? templateItem.weight : 0.0;
      double valorizedElement = finalWeight * account.valorizedTotal();
      double price = await _priceFinder.currentPrice(coin);
      double finalQty = valorizedElement / price;
      double initialQty = lineItem != null ? lineItem.quantity : 0.0;
      if (finalQty > initialQty) {
        positiveDiff[coin] = finalQty - initialQty;
      } else {
        negativeDiff[coin] = initialQty - finalQty;
      }
    }));

    Map<String, dynamic> _availableSymbols = await getAvailableSymbols();

    for (String from in negativeDiff.keys) {
      for (String to in positiveDiff.keys) {
        if (_availableSymbols[from + to] == null &&
            _availableSymbols[to + from] == null) continue;
        Map<String, dynamic> transaction = {};

        if (negativeDiff[from]! <= 0) break;
        if (positiveDiff[from] != null && positiveDiff[from]! > 0) {
          double spotPrice = await _priceFinder.currentPrice(from, to);
          double maxTransaction = spotPrice * negativeDiff[from]!;
          double soldQty = 0;
          if (maxTransaction > positiveDiff[to]!) {
            soldQty = positiveDiff[to]! / spotPrice;
          } else {
            soldQty = negativeDiff[from]!;
          }
          double boughtQty = soldQty * spotPrice;
          if (soldQty > 0) {
            if (_availableSymbols[from + to] != null) {
              transaction["from"] = from;
              transaction["to"] = to;
              transaction["quantity"] = soldQty;
              transaction["type"] = "sell";
            } else {
              transaction["from"] = to;
              transaction["to"] = from;
              transaction["type"] = "buy";
              transaction["quoteQuantity"] = soldQty;
            }
            double price = await _priceFinder.currentPrice(from);
            transaction["fee"] = soldQty * price * fee;
            await processTransaction(transaction);
            transactions.add(transaction);
            negativeDiff[from] = negativeDiff[from]! - soldQty;
            positiveDiff[to] = positiveDiff[to]! - boughtQty;
          }
        }
      }
    }

    double cash = 0.0;
    for (String key in negativeDiff.keys) {
      Map<String, dynamic> transaction = {};
      if (negativeDiff[key]! > 0 && key != "USDT") {
        if (_availableSymbols[key + "USDT"] == null) continue;
        transaction["from"] = key;
        transaction["to"] = "USDT";
        transaction["quantity"] = negativeDiff[key]!;
        transaction["type"] = "sell";
        double price = await _priceFinder.currentPrice(key, "USDT");
        cash = cash + negativeDiff[key]! * price;
        transaction["fee"] = price * negativeDiff[key]! * fee;
        await processTransaction(transaction);
        transactions.add(transaction);
      }
    }
    for (String key in positiveDiff.keys) {
      Map<String, dynamic> transaction = {};
      if (positiveDiff[key]! > 0 && key != "USDT") {
        if (_availableSymbols[key + "USDT"] == null) continue;
        transaction["from"] = key;
        transaction["to"] = "USDT";
        double price = await _priceFinder.currentPrice(key, "USDT");
        transaction["quoteQuantity"] = (positiveDiff[key]! * price);
        transaction["type"] = "buy";
        transaction["fee"] = price * positiveDiff[key]! * fee;
        await processTransaction(transaction);
        transactions.add(transaction);
      }
    }
    return transactions;
  }

  double getTotalFees() {
    return transactions.fold(
        0.0, (prev, elem) => (prev as double) + elem["fee"]);
  }

  Future<bool> liquidateCoin(String coin) async {
    await account.getLineItems();
    Map<String, dynamic> _availableSymbols = await getAvailableSymbols();
    if (_availableSymbols[coin + "USDT"] == null) return false;
    LineItem? lineItem =
        account.lineItems.where((v) => v.coin == coin).toList()[0];
    if (lineItem != null) {
      double price = await _priceFinder.currentPrice(coin);
      transactions.add({
        "from": lineItem.coin,
        "to": "USDT",
        "type": "sell",
        "quantity": lineItem.quantity,
        "fee": fee * price * lineItem.quantity
      });
    }
    return true;
  }

  Future<bool> execute() async {
    throw UnimplementedError();
  }

  Future<bool> executeOffline() async {
    Map<String, LineItem> indexedLineItems = {};
    Map<String, TemplateItem> indexedTemplateItems = {};

    account.lineItems.forEach((v) {
      indexedLineItems[v.coin!] = v;
    });

    transactions.forEach((v) {
      if (!indexedLineItems.keys.contains(v["from"])) {
        LineItem newLineItem = LineItem(v["from"], account);
        newLineItem.quantity = 0.0;
        account.lineItems.add(newLineItem);
        indexedLineItems[newLineItem.coin!] = newLineItem;
      }
      if (!indexedLineItems.keys.contains(v["to"])) {
        LineItem newLineItem = LineItem(v["to"], account);
        newLineItem.quantity = 0.0;
        account.lineItems.add(newLineItem);
        indexedLineItems[newLineItem.coin!] = newLineItem;
      }
    });

    await Future.wait(transactions.map((v) async {
      double price = await _priceFinder.currentPrice(v["from"], v["to"]);
      if (v["type"] == "buy") {
        indexedLineItems[v["from"]]!.quantity += v["quoteQuantity"] / price;
        indexedLineItems[v["to"]]!.quantity -= v["quoteQuantity"];
      } else {
        indexedLineItems[v["from"]]!.quantity -= v["quantity"];
        indexedLineItems[v["to"]]!.quantity += v["quantity"] * price;
      }
    }));
    return true;
  }

  void reset() {
    transactions = [];
  }

  Future<void> processTransaction(Map<String, dynamic> transaction) async {
    throw UnimplementedError();
  }

  Future<Map<String, dynamic>> getAvailableSymbols() async {
    throw UnimplementedError();
  }

  double toLottedQuantity(double quantity, double lotSize) {
    final d = (double s) => Decimal.parse(s.toString());
    return (d((d(quantity) / d(lotSize)).toDouble()).floor() * d(lotSize))
        .toDouble();
  }
}
