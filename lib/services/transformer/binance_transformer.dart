import 'package:crypto_manager/models/account.dart';
import 'package:crypto_manager/models/template.dart';
import 'package:crypto_manager/services/binance.dart';
import 'package:crypto_manager/services/transformer.dart';
import 'package:crypto_manager/extensions.dart';

class BinanceTransformer extends Transformer {
  late Binance binance;

  @override
  double fee = 0.001;

  BinanceTransformer(Account account, [Binance? client]) : super(account) {
    if (client != null) {
      binance = client;
    } else {
      binance = Binance(account);
    }
  }

  @override
  Future<bool> execute() async {
    await Future.wait(transactions.where((v) => v["type"] == "sell").map((v) {
      return binance.createOrder(
          "${v["from"]}${v["to"]}", "sell", "market", v["quantity"], null);
    }));
    await Future.wait(transactions.where((v) => v["type"] == "buy").map((v) {
      return binance.createOrder(
          "${v["from"]}${v["to"]}", "buy", "market", null, v["quoteQuantity"]);
    }));
    return true;
  }

  @override
  Future<Map<String, dynamic>> getAvailableSymbols() async {
    if (availableSymbols != null) return availableSymbols!;
    Map<String, dynamic> exchangeInfo = await binance.exchangeInfo();
    List<dynamic> symbols = exchangeInfo["symbols"];
    availableSymbols = {};
    symbols.forEach((element) {
      if (element["status"] == "TRADING" &&
          (element["orderTypes"] as List<dynamic>).contains("MARKET")) {
        availableSymbols![element["symbol"]] = {
          "precision": element["baseAssetPrecision"],
          "quotePrecision": element["quoteAssetPrecision"]
        };
        if (element["filters"] != null &&
            element["filters"]
                    .where((v) => v["filterType"] == "LOT_SIZE")
                    .length >
                0) {
          dynamic lotSizeFilter = element["filters"].where((v) {
            return v["filterType"] == "LOT_SIZE";
          }).toList()[0];
          availableSymbols![element["symbol"]]["lotStepSize"] =
              double.parse(lotSizeFilter["stepSize"]);
        }
      }
    });
    return availableSymbols!;
  }

  @override
  Future<void> processTransaction(Map<String, dynamic> transaction) async {
    Map<String, dynamic> _availableSymbols = await getAvailableSymbols();
    if (transaction["quantity"] != null) {
      if (_availableSymbols[transaction["from"] + transaction["to"]]
                  ["lotStepSize"] !=
              null &&
          _availableSymbols[transaction["from"] + transaction["to"]]
                  ["lotStepSize"] !=
              -1) {
        transaction["quantity"] = toLottedQuantity(
            transaction["quantity"],
            _availableSymbols[transaction["from"] + transaction["to"]]
                ["lotStepSize"]);
      } else {
        transaction["quantity"] = transaction["quantity"]
            .truncateToDecimalPlaces(
                _availableSymbols[transaction["from"] + transaction["to"]]
                    ["precision"]);
      }
    } else if (transaction["quoteQuantity"] != null) {
      transaction["quoteQuantity"] = (transaction["quoteQuantity"] as double)
          .truncateToDecimalPlaces(
              _availableSymbols[transaction["from"] + transaction["to"]]
                  ["quotePrecision"]);
    }
  }
}
