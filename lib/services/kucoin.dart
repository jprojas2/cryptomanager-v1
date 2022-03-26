import 'dart:async';

import 'package:crypto_manager/models/account.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Kucoin {
  late String apiUrl;
  late Account? account;

  Kucoin(this.account, [bool? test]) {
    if (test != null && test) {
      apiUrl = "https://sandbox.kucoin.com";
    } else {
      apiUrl = "https://api.kucoin.com";
    }
  }

  Future<dynamic> request(String method, String endpoint,
      [String? urlParams, Map<String, dynamic>? body]) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (account != null) {
      requestHeaders['KC-API-KEY'] = account!.encApiKey;
      requestHeaders['KC-API-PASSPHRASE'] = _encryptedPassphrase(account!);
      requestHeaders['KC-API-KEY-VERSION'] = "2";
      requestHeaders['KC-API-TIMESTAMP'] =
          DateTime.now().millisecondsSinceEpoch.toString();
      String signature = _signature(account!, method, endpoint, urlParams, body,
          requestHeaders['KC-API-TIMESTAMP']!);
      requestHeaders["KC-API-SIGN"] = signature;
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

  static Future<dynamic> getAllTickers() async {
    return await Kucoin(null).request("GET", "/api/v1/market/allTickers");
  }

  Future<dynamic> getAccounts() async {
    return await request("GET", "/api/v1/accounts");
  }

  Future<dynamic> getSubAccounts() async {
    return await request("GET", "/api/v1/sub-accounts");
  }

  Future<dynamic> getBalance() async {
    return await request("GET", "/api/v1/account/balance");
  }

  Future<dynamic> transferAllToTradeAccount() async {
    dynamic accountsResponse = await getAccounts();
    List<dynamic> accounts = accountsResponse["data"];
    List<dynamic> mainAccounts =
        accounts.where((el) => el["type"] == "main").toList();
    if (mainAccounts.isNotEmpty) {
      await Future.wait(mainAccounts.map((v) => innerTransfer(
          v["currency"], "main", "trade", double.parse(v["balance"]))));
    }
  }

  Future<dynamic> transferAllToMainAccount() async {
    dynamic accountsResponse = await getAccounts();
    List<dynamic> accounts = accountsResponse["data"];
    List<dynamic> tradeAccounts =
        accounts.where((el) => el["type"] == "trade").toList();
    if (tradeAccounts.isNotEmpty) {
      await Future.wait(tradeAccounts.map((v) => innerTransfer(
          v["currency"], "trade", "main", double.parse(v["balance"]))));
    }
  }

  //{
  //  "currentPage":1,
  //  "pageSize":1,
  //  "totalNum":251915,
  //  "totalPage":251915,
  //  "items":[
  //      {
  //          "symbol":"BTC-USDT",    //symbol
  //          "tradeId":"5c35c02709e4f67d5266954e",   //trade id
  //          "orderId":"5c35c02703aa673ceec2a168",   //order id
  //          "counterOrderId":"5c1ab46003aa676e487fa8e3",  //counter order id
  //          "side":"buy",   //transaction direction,include buy and sell
  //          "liquidity":"taker",  //include taker and maker
  //          "forceTaker":true,  //forced to become taker
  //          "price":"0.083",   //order price
  //          "size":"0.8424304",  //order quantity
  //          "funds":"0.0699217232",  //order funds
  //          "fee":"0",  //fee
  //          "feeRate":"0",  //fee rate
  //          "feeCurrency":"USDT",  // charge fee currency
  //          "stop":"",        // stop type
  //          "type":"limit",  // order type,e.g. limit,market,stop_limit.
  //          "createdAt":1547026472000,  //time
  //          "tradeType": "TRADE"
  //      }
  //  ]
  //}
  Future<dynamic> getFills() async {
    return await getAllPaginatedResults("/api/v1/fills");
  }

  //{
  //  "currentPage":1,
  //  "pageSize":5,
  //  "totalNum":2,
  //  "totalPage":1,
  //  "items":[
  //      {
  //          "address":"0x5f047b29041bcfdbf0e4478cdfa753a336ba6989",
  //          "memo":"5c247c8a03aa677cea2a251d",
  //          "amount":1,
  //          "fee":0.0001,
  //          "currency":"KCS",
  //          "isInner":false,
  //          "walletTxId":"5bbb57386d99522d9f954c5a@test004",
  //          "status":"SUCCESS",
  //          "remark":"test",
  //          "createdAt":1544178843000,
  //          "updatedAt":1544178891000
  //      },
  //      {
  //          "address":"0x5f047b29041bcfdbf0e4478cdfa753a336ba6989",
  //          "memo":"5c247c8a03aa677cea2a251d",
  //          "amount":1,
  //          "fee":0.0001,
  //          "currency":"KCS",
  //          "isInner":false,
  //          "walletTxId":"5bbb57386d99522d9f954c5a@test003",
  //          "status":"SUCCESS",
  //          "remark":"test",
  //          "createdAt":1544177654000,
  //          "updatedAt":1544178733000
  //      }
  //  ]
  //}
  // PAGINATED
  //
  Future<dynamic> getDeposits() async {
    return await getAllPaginatedResults("/api/v1/deposits");
  }

  //{
  //  "currentPage":1,
  //  "pageSize":10,
  //  "totalNum":1,
  //  "totalPage":1,
  //  "items":[
  //      {
  //          "id":"5c2dc64e03aa675aa263f1ac",
  //          "address":"0x5bedb060b8eb8d823e2414d82acce78d38be7fe9",
  //          "memo":"",
  //          "currency":"ETH",
  //          "amount":1,
  //          "fee":0.01,
  //          "walletTxId":"3e2414d82acce78d38be7fe9",
  //          "isInner":false,
  //          "status":"FAILURE",
  //          "remark":"test",
  //          "createdAt":1546503758000,
  //          "updatedAt":1546504603000
  //      }
  //  ]
  //}
  Future<dynamic> getWithdrawals() async {
    return await getAllPaginatedResults("/api/v1/withdrawals");
  }

  Future<dynamic> getAllPaginatedResults(String endpoint) async {
    int pageSize = 500;
    List<dynamic> results = [];
    bool gotAllItems = false;
    int currentPage = 1;
    while (!gotAllItems) {
      dynamic response = await request(
          "GET", endpoint, "currentPage=${currentPage}&pageSize=${pageSize}");
      results = results + response["data"]["items"];
      gotAllItems = response["data"]["items"].length < pageSize;
    }
    return results;
  }

  Future<dynamic> innerTransfer(
      String currency, String fromId, String toId, double amount) async {
    return await request("POST", "/api/v2/accounts/inner-transfer", null, {
      "clientOid": "transfer-" +
          currency +
          "-" +
          DateTime.now().millisecondsSinceEpoch.toString(),
      "currency": currency,
      "from": fromId,
      "to": toId,
      "amount": amount
    });
  }

  Future<dynamic> createOrder(String symbol, String side, String type,
      double? quantity, double? quoteQuantity,
      [bool? test]) async {
    Map<String, dynamic> body = {
      "clientOid":
          "${symbol}-${side}-${type}-${DateTime.now().millisecondsSinceEpoch}",
      "side": side,
      "symbol": symbol,
      "type": type
    };

    if (quantity != null) {
      body["size"] = quantity;
    } else if (quoteQuantity != null) {
      body["funds"] = quoteQuantity;
    }
    return await request("POST", "/api/v1/orders", null, body);
  }

  Future<dynamic> symbols() async {
    return await request("GET", "/api/v1/symbols");
  }

  String _encryptedPassphrase(Account account) {
    var key = utf8.encode(account.encSecretKey);
    var bytes = utf8.encode(account.encPassphrase!);
    var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
    Digest digest = hmacSha256.convert(bytes);
    return base64.encode(digest.bytes);
  }

  String _signature(Account account, String method, String requestPath,
      String? queryString, Map<String, dynamic>? body, String timestamp) {
    String message = "";

    if (body != null) {
      message = timestamp + method + requestPath + jsonEncode(body);
    } else if (queryString != null) {
      message = timestamp + method + requestPath + "?" + queryString;
    } else {
      message = timestamp + method + requestPath;
    }
    var key = utf8.encode(account.encSecretKey);
    var bytes = utf8.encode(message);
    var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
    Digest digest = hmacSha256.convert(bytes);
    return base64.encode(digest.bytes);
  }

  static String _queryMapToString(Map<String, dynamic> queryMap) {
    return queryMap.keys.map((v) => "${v}=${queryMap[v].toString()}").join("&");
  }
}
