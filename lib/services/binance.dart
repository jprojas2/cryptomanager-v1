import 'dart:async';

import 'package:crypto_manager/models/account.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class Binance {
  static const apiUrl = "https://api.binance.com";
  late Account? account;

  static Future<dynamic> testTrade(Account account) async {
    try {
      await Binance(account).buyMarket("BTCUSDT", 0.1, null, true);
    } catch (e) {
      return false;
    }
    return true;
  }

  Binance(this.account);

  Future<dynamic> request(String method, String endpoint,
      [String? urlParams, Map<String, dynamic>? body]) async {
    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
    };
    if (body != null)
      requestHeaders['Content-Type'] = 'application/json; charset=UTF-8';
    if (account != null) {
      requestHeaders['X-MBX-APIKEY'] = account!.encApiKey;
      if (body != null) {
        body["timestamp"] = DateTime.now().millisecondsSinceEpoch.toString();
      } else if (urlParams != null) {
        urlParams +=
            "&timestamp=" + DateTime.now().millisecondsSinceEpoch.toString();
      } else {
        urlParams =
            "timestamp=" + DateTime.now().millisecondsSinceEpoch.toString();
      }
      String _signature = signature(account!.encSecretKey, urlParams, body);
      if (body != null) {
        body["signature"] = _signature;
      } else if (urlParams != null) {
        urlParams += "&signature=${_signature}";
      }
    }
    var url = apiUrl + endpoint;
    if (urlParams != null) {
      url = url + "?" + urlParams;
    }
    print("${method} ${url}");
    try {
      var response;
      if (method == "GET") {
        response = await http
            .get(Uri.parse(url), headers: requestHeaders)
            .timeout(const Duration(seconds: 10), onTimeout: () {
          throw TimeoutException(
              'The connection has timed out, Please try again!');
        });
      } else if (method == "POST") {
        response = await http
            .post(Uri.parse(url),
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null)
            .timeout(const Duration(seconds: 10), onTimeout: () {
          throw TimeoutException(
              'The connection has timed out, Please try again!');
        });
      } else if (method == "PUT") {
        response = await http
            .put(Uri.parse(url),
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null)
            .timeout(const Duration(seconds: 10), onTimeout: () {
          throw TimeoutException(
              'The connection has timed out, Please try again!');
        });
      } else {
        throw Exception("Method not supported");
      }
      if (response.statusCode / 100 == 2) {
        return jsonDecode(response.body);
      } else {
        print(response.body);
        print("RESPONSE CODE: ${response.statusCode}");
        throw Exception("RESPONSE CODE: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<dynamic> createOrder(String symbol, String side, String type,
      double? quantity, double? quoteQuantity,
      [bool? test]) async {
    var endpoint = "/api/v3/order";
    if (test != null && test) endpoint += "/test";
    Map<String, dynamic> body = {"side": side, "symbol": symbol, "type": type};
    if (quantity != null) {
      body["quantity"] = quantity;
    } else if (quoteQuantity != null) {
      body["quoteOrderQty"] = quoteQuantity;
    }
    return await request("POST", endpoint, queryMapToString(body), null);
  }

  Future<dynamic> buyMarket(
      String symbol, double? quantity, double? quoteQuantity,
      [bool? test]) async {
    return await createOrder(
        symbol, "BUY", "MARKET", quantity, quoteQuantity, test);
  }

  Future<bool> sellMarket(
      String symbol, double? quantity, double? quoteQuantity,
      [bool? test]) async {
    return await createOrder(
        symbol, "SELL", "MARKET", quantity, quoteQuantity, test);
  }

  static holdings(Account account) async {
    return await Binance(account).request("GET", "/api/v3/account");
  }

  Future<dynamic> getAccount() async {
    return await request("GET", "/api/v3/account");
  }

  static allPrices() async {
    return await Binance(null).request("GET", "/api/v1/ticker/allPrices");
  }

  Future<Map<String, dynamic>> exchangeInfo() async {
    return await Binance(null).request("GET", "/api/v3/exchangeInfo");
  }

  Future<dynamic> coins(Account account) async {
    return await Binance(account)
        .request("GET", "/api/v1/capital/config/getall");
  }

  static String signature(
      String secret_key, String? query_string, Map<String, dynamic>? body) {
    String base64Key = secret_key;
    String message = "";
    if (query_string != null) {
      message = query_string;
    } else if (body != null) {
      message = queryMapToString(body);
    }
    var key = utf8.encode(base64Key);
    var bytes = utf8.encode(message);

    var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
    var digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  static String queryMapToString(Map<String, dynamic> queryMap) {
    return queryMap.keys.map((v) => "${v}=${queryMap[v].toString()}").join("&");
  }
}
