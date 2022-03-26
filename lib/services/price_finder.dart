import 'dart:async';
import 'dart:convert';

import 'package:crypto_manager/services/lock_manager.dart';

import 'binance.dart';
import 'package:http/http.dart' as http;

import 'kucoin.dart';

class PriceFinder with LockManager {
  Map<String, double> _allPrices = {};
  Map<dynamic, double> _historicPrices = {};
  List<Map<String, dynamic>> callHistory = [];
  bool throttling = false;
  late int type;
  Locker locker = LockManager.getLocker();

  static const basePriceAPIUrl = "https://min-api.cryptocompare.com";

  PriceFinder._privateConstructor(int this.type);
  static final List<PriceFinder> instances =
      [0, 1, 2, 3].map((e) => PriceFinder._privateConstructor(e)).toList();

  void reset() {
    _allPrices = {};
    callHistory = [];
  }

  static void resetAll() {
    PriceFinder.instances.forEach((e) => e.reset());
  }

  Future<void> throttle(event) async {
    callHistory.add(event);
    print("SHOULD THROTTLE?: " + callHistory.length.toString());
    _recall() {
      return throttle(event);
    }

    if (locker.locked) {
      print("WAITING LOCK");
      return await locker.waitLock();
    }
    locker.setFunction(_recall);
    if (callHistory.length >= 20) {
      locker.lock();
      print("LOCKED");
      await Future.delayed(const Duration(seconds: 8));
      callHistory = [];
      locker.unlock();
    }
  }

  Future<double> currentPrice(coin1, [String? coin2]) async {
    if (coin1 == "USDT") {
      return 1.0;
    }
    if (coin2 == null) {
      coin2 = "USDT";
    }
    //print("FINDING ${coin1 + coin2}");
    var price = await _getPrice(coin1 + coin2);
    return price;
  }

  Future<double> historicPrice(String coin, DateTime time) async {
    if (coin == "USDT") {
      return 1.0;
    }
    if (_historicPrices[[coin, time]] != null) {
      return _historicPrices[[coin, time]]!;
    }
    DateTime toTime =
        DateTime.utc(time.year, time.month, time.day, time.hour + 1);
    int toTimeInSeconds =
        time.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    String url = basePriceAPIUrl +
        "/data/v2/histominute?fsym=${coin}&tsym=USDT&limit=10&toTs=${toTimeInSeconds}";
    print(url);
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    };
    try {
      await throttle({"e": 1});
      final response = await http
          .get(Uri.parse(url), headers: requestHeaders)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(
            'The connection has timed out, Please try again!');
      });
      var jsonResponse = jsonDecode(response.body);
      String key = coin + "-" + time.toString();
      if (response.statusCode == 200 && jsonResponse["Response"] == "Success") {
        var candle = jsonResponse["Data"]["Data"];
        candle = candle[candle.length - 1];
        var avg = (candle["high"] + candle["low"]) / 2;
        int secondsSinceEpoch =
            time.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
        //print(coin + ": " + candle["close"]);
        _historicPrices[key] = candle["close"].toDouble();
        return _historicPrices[key]!;
      } else {
        print(jsonResponse);
        return 0.0;
      }
    } on TimeoutException {
      print("TIMEOUT");
      return 0.0;
    }
  }

  Future<void> getAllPrices() async {
    if (type == 2) {
      Map<String, dynamic> kucoinAllTickers = await Kucoin.getAllTickers();
      List<dynamic> tickers = kucoinAllTickers["data"]["ticker"];
      tickers.forEach((v) {
        _allPrices[v["symbol"].split("-").join()] = double.parse(v["last"]);
      });
    } else {
      List<dynamic> binanceAllPrices = await Binance.allPrices();
      binanceAllPrices.forEach((v) {
        _allPrices[v["symbol"]] = double.parse(v["price"]);
      });
    }
  }

  Future<double> _getPrice(String ticker) async {
    if (_allPrices.isEmpty) {
      await getAllPrices();
    }
    if (_allPrices[ticker] != null) {
      return _allPrices[ticker]!;
    } else {
      return 0.0;
    }
  }
}
