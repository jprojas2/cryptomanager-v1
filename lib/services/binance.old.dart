import 'dart:async';

import 'package:crypto_manager/models/account.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Binance {
  static const apiUrl = "https://api.binance.com";

  static Future<bool> testTrade(Account account) async {
    return buyMarket(account, "BTCUSDT", 0.1, null, true);
  }

  static Future<bool> buyMarket(
      Account account, String symbol, double? quantity, double? quoteQuantity,
      [bool? test]) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'X-MBX-APIKEY': account.encApiKey
    };
    var endpoint = "/api/v3/order";
    if (test != null && test) endpoint += "/test";
    var queryBody = {
      "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
      "symbol": symbol,
      "side": "BUY",
      "type": "MARKET",
    };
    if (quantity != null) {
      queryBody["quantity"] = quantity.toString();
    } else if (quoteQuantity != null) {
      queryBody["quoteOrderQty"] = quoteQuantity.toString();
    }
    var _signature =
        signature(account.encSecretKey, queryMapToString(queryBody), null);
    queryBody["signature"] = _signature;
    var url = apiUrl + endpoint + "?" + queryMapToString(queryBody);
    try {
      final response = await http
          .post(Uri.parse(url), headers: requestHeaders)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(
            'The connection has timed out, Please try again!');
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        print(response.body);
        print("RESPONSE CODE: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> sellMarket(
      Account account, String symbol, double? quantity, double? quoteQuantity,
      [bool? test]) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'X-MBX-APIKEY': account.encApiKey
    };
    var endpoint = "/api/v3/order";
    if (test != null && test) endpoint += "/test";
    var queryBody = {
      "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
      "symbol": symbol,
      "side": "SELL",
      "type": "MARKET",
    };
    if (quantity != null) {
      queryBody["quantity"] = quantity.toString();
    } else if (quoteQuantity != null) {
      queryBody["quoteOrderQty"] = quoteQuantity.toString();
    }
    var _signature =
        signature(account.encSecretKey, queryMapToString(queryBody), null);
    queryBody["signature"] = _signature;
    var url = apiUrl + endpoint + "?" + queryMapToString(queryBody);
    print(url);
    try {
      final response = await http
          .post(Uri.parse(url), headers: requestHeaders)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(
            'The connection has timed out, Please try again!');
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        print(response.body);
        if (jsonDecode(response.body)["code"] == -2010) {
          print(quantity);
        }
        print("RESPONSE CODE: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  static holdings(Account account) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'X-MBX-APIKEY': account.encApiKey
    };
    var endpoint = "/api/v3/account";
    var queryString =
        "timestamp=" + DateTime.now().millisecondsSinceEpoch.toString();
    var _signature = signature(account.encSecretKey, queryString, null);
    try {
      final response = await http
          .get(
              Uri.parse(apiUrl +
                  endpoint +
                  "?" +
                  queryString +
                  "&signature=" +
                  _signature),
              headers: requestHeaders)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(
            'The connection has timed out, Please try again!');
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"balances": []};
      }
    } catch (e) {
      print(e);
      return {"balances": []};
    }
  }

  static allPrices() async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    };
    var endpoint = "/api/v1/ticker/allPrices";
    final response =
        await http.get(Uri.parse(apiUrl + endpoint), headers: requestHeaders);
    List<dynamic> _json = jsonDecode(response.body);
    return _json;
  }

  Future<List<dynamic>> symbols() async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    };
    var endpoint = "/api/v3/exchangeInfo";
    final response =
        await http.get(Uri.parse(apiUrl + endpoint), headers: requestHeaders);
    List<dynamic> _json = jsonDecode(response.body)["symbols"];
    return _json;
  }

  Future<dynamic> coins(Account account) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'X-MBX-APIKEY': account.encApiKey
    };
    var endpoint = "/sapi/v1/capital/config/getall";
    var queryString =
        "timestamp=" + DateTime.now().millisecondsSinceEpoch.toString();
    var _signature = signature(account.encSecretKey, queryString, null);
    final response = await http.get(
        Uri.parse(
            apiUrl + endpoint + "?" + queryString + "&signature=" + _signature),
        headers: requestHeaders);
    return jsonDecode(response.body);
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
