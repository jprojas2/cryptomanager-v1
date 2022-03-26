import 'package:crypto_manager/models/account.dart';
import 'package:crypto_manager/services/kucoin.dart';
import 'package:crypto_manager/services/transformer.dart';

class KucoinTransformer extends Transformer {
  late Kucoin kucoin;

  @override
  double fee = 0.001;

  KucoinTransformer(Account account, [Kucoin? client]) : super(account) {
    if (client != null) {
      kucoin = client;
    } else {
      kucoin = Kucoin(account, false);
    }
  }

  @override
  Future<bool> execute() async {
    await account.getLineItems();
    await kucoin.transferAllToTradeAccount();
    await Future.wait(transactions.where((v) => v["type"] == "sell").map((v) {
      return kucoin.createOrder(
          "${v["from"]}-${v["to"]}", "sell", "market", v["quantity"], null);
    }));
    await Future.wait(transactions.where((v) => v["type"] == "buy").map((v) {
      return kucoin.createOrder(
          "${v["from"]}-${v["to"]}", "buy", "market", null, v["quoteQuantity"]);
    }));
    await account.getLineItems();
    await kucoin.transferAllToMainAccount();
    return true;
  }

  @override
  Future<Map<String, dynamic>> getAvailableSymbols() async {
    Map<String, dynamic> symbols = await kucoin.symbols();
    Map<String, dynamic> availableSymbols = {};
    //   {
    //   "symbol": "XLM-USDT",
    //   "name": "XLM-USDT",
    //   "baseCurrency": "XLM",
    //   "quoteCurrency": "USDT",
    //   "feeCurrency": "USDT",
    //   "market": "USDS",
    //   "baseMinSize": "0.1",
    //   "quoteMinSize": "0.01",
    //   "baseMaxSize": "10000000000",
    //   "quoteMaxSize": "99999999",
    //   "baseIncrement": "0.0001",
    //   "quoteIncrement": "0.000001",
    //   "priceIncrement": "0.000001",
    //   "priceLimitRate": "0.1",
    //   "isMarginEnabled": true,
    //   "enableTrading": true
    // }
    symbols["data"].forEach((element) {
      if (element["enableTrading"] == true) {
        String symbol = element["baseCurrency"] + element["quoteCurrency"];
        availableSymbols[symbol] = {
          "stepSize": double.parse(element["baseIncrement"]),
          "quoteStepSize": double.parse(element["quoteIncrement"])
        };
      }
    });
    return availableSymbols;
  }

  @override
  Future<void> processTransaction(Map<String, dynamic> transaction) async {
    Map<String, dynamic> _availableSymbols = await getAvailableSymbols();
    if (transaction["quantity"] != null) {
      transaction["quantity"] = toLottedQuantity(
          transaction["quantity"],
          _availableSymbols[transaction["from"] + transaction["to"]]
              ["stepSize"]);
    } else if (transaction["quoteQuantity"] != null) {
      transaction["quoteQuantity"] = toLottedQuantity(
          transaction["quoteQuantity"],
          _availableSymbols[transaction["from"] + transaction["to"]]
              ["quoteStepSize"]);
    }
  }
}
