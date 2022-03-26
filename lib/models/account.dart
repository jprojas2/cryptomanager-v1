import 'package:crypto_manager/models/line_item.dart';
import 'package:crypto_manager/models/snapshot_item.dart';
import 'package:crypto_manager/models/template.dart';
import 'package:crypto_manager/models/template_item.dart';
import 'package:crypto_manager/services/binance.dart';
import 'package:crypto_manager/services/kucoin.dart';
import 'package:crypto_manager/services/price_finder.dart';
import "package:crypto_manager/services/database_helper.dart";
import 'package:crypto_manager/services/transformer.dart';
import 'package:crypto_manager/services/transformer/binance_transformer.dart';
import 'package:crypto_manager/services/transformer/kucoin_transformer.dart';

class Account {
  late int id;
  late String name;
  late int type; // 0: Virtual, 1: Binance, 2: Kucoin
  late String encApiKey;
  late String encSecretKey;
  late String? encPassphrase;
  List<LineItem> lineItems = [];
  List<SnapshotItem> snapshotItems = [];
  late PriceFinder _priceFinder;
  bool transformable = false;
  late Transformer _transformer;

  Account(this.id, this.name, this.type, this.encApiKey, this.encSecretKey,
      [this.encPassphrase]) {
    if (type == 0) {
      _transformer = Transformer(this);
    } else if (type == 1) {
      _transformer = BinanceTransformer(this);
    } else if (type == 2) {
      _transformer = KucoinTransformer(this);
    }
    if (type > 0) _priceFinder = PriceFinder.instances[type];
  }

  Future<List<LineItem>> getLineItems() async {
    List<LineItem> _lineItems = [];
    try {
      if (type == 1) {
        var response = await Binance(this).getAccount();
        response["balances"].forEach((v) {
          LineItem _lineItem = LineItem(v["asset"], this, 0.0, _priceFinder);
          _lineItem.quantity =
              double.parse(v["free"]) + double.parse(v["locked"]);
          _lineItem.amount = 0.0;
          _lineItems.add(_lineItem);
        });
      } else if (type == 2) {
        dynamic accountsResponse = await Kucoin(this).getAccounts();
        List<dynamic> data = accountsResponse["data"];
        data.forEach((v) {
          _lineItems.add(LineItem(
              v["currency"], this, double.parse(v["balance"]), _priceFinder));
        });
      }
      lineItems = _lineItems;
    } catch (e) {
      throw (e);
    }

    return _lineItems;
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    List<Map<String, dynamic>> transactions = [];

    List<dynamic> deposits = await Kucoin(this).getDeposits();
    List<dynamic> withdrawals = await Kucoin(this).getWithdrawals();
    List<dynamic> fills = await Kucoin(this).getFills();

    deposits.forEach((value) {
      if (value["status"] == "SUCCESS") {
        transactions.add({
          "at": value["createdAt"],
          "type": "deposit",
          "baseCurrency": value["currency"],
          "quantity":
              double.parse(value["amount"]) - double.parse(value["fee"]),
        });
      }
    });

    withdrawals.forEach((value) {
      if (value["status"] == "SUCCESS") {
        transactions.add({
          "at": value["createdAt"],
          "type": "withdrawal",
          "baseCurrency": value["currency"],
          "quantity": double.parse(value["amount"]) + double.parse(value["fee"])
        });
      }
    });

    fills.forEach((value) {
      //TODO: Fees
      if (value["status"] == "SUCCESS") {
        transactions.add({
          "at": value["createdAt"],
          "type": value["side"],
          "baseCurrency": value["symbol"].split("-")[0],
          "quoteCurrency": value["symbol"].split("-")[0],
          "quantity": double.parse(value["size"]),
          "quoteQuantity": double.parse(value["funds"])
        });
      }
    });

    return transactions;
  }

  Future<List<SnapshotItem>> getSnapshotItems() async {
    snapshotItems = await SnapshotItem.where({"account_id": id});
    return snapshotItems;
  }

  Future<void> valorizeAccount() async {
    await _priceFinder.getAllPrices();
    await Future.wait(lineItems.map((v) {
      return valorizeItem(v);
    }));
    lineItems = lineItems.where((v) => v.amount > 2.0).toList();
    lineItems.sort((a, b) => b.amount.compareTo(a.amount));
  }

  Future<void> valorizeSnapshot() async {
    await _priceFinder.getAllPrices();
    await Future.wait(snapshotItems.map((v) {
      return valorizeItem(v);
    }));
    //snapshotItems = snapshotItems.where((v) => v.amount > 2.0).toList();
    //snapshotItems.sort((a, b) => b.amount.compareTo(a.amount));
  }

  Future valorizeItem(dynamic item) async {
    //print("VALORIZING LINE ITEM: " + lineItem.coin);
    double price = await _priceFinder.currentPrice(item.coin);

    item.price = price;
    item.amount = item.price * item.quantity;
  }

  double? profitability(String period) {
    return lineItems.fold(0.0, (prev, element) {
      if (element.profitability(period) != null && prev != null) {
        return prev +
            element.profitability(period)! * element.amount / valorizedTotal();
      } else {
        return null;
      }
    });
  }

  Future<void> computeProfitabilities(List<String> periods,
      [PriceFinder? priceFinder]) async {
    await Future.wait(
        lineItems.map((v) => v.computeProfitabilities(periods, priceFinder)));
  }

  Future<void> computeProfitability(String period,
      [PriceFinder? priceFinder]) async {
    await Future.wait(lineItems.map((v) => v.computeProfitability(period)));
  }

  Future<void> checkTradeability() async {
    if (type == 1) {
      transformable = await Binance.testTrade(this);
    } else {
      transformable = true;
    }
  }

  Future<void> transform(Template template, [bool dryRun = false]) async {
    _transformer.reset();
    await _transformer.transform(template);
    if (!dryRun) {
      await createSnapshot();
      await _transformer.execute();
    }
  }

  Future<void> liquidate(
      [String? coin, bool dryRun = false, bool snapshot = true]) async {
    _transformer.reset();
    if (coin != null) {
      await _transformer.liquidateCoin(coin);
    } else {
      Template cashTemplate = Template(-1, "Cash");
      cashTemplate.items = [TemplateItem(-1, -1, "USDT", 1.0)];
      await _transformer.transform(cashTemplate);
    }
    if (!dryRun && snapshot) await createSnapshot();
    if (!dryRun) await _transformer.execute();
  }

  Future<double> transformationFees() async {
    return _transformer.getTotalFees();
  }

  Map<String, double> dataForPieChart() {
    var _keptLineItems = lineItems;
    int limit = 6;
    if (_keptLineItems.length > limit) {
      var _auxLineItems = _keptLineItems.sublist(0, limit);
      List<LineItem> _otherLineItems =
          _keptLineItems.sublist(limit, _keptLineItems.length - 1);
      var otherItem =
          _otherLineItems.fold(LineItem("Other", this), (prev, elem) {
        (prev as LineItem).amount += elem.amount;
        return prev;
      });
      _auxLineItems.add(otherItem);
      _keptLineItems = _auxLineItems;
    }
    return Map.fromIterable(_keptLineItems,
        key: (v) => v.coin, value: (v) => v.amount);
  }

  double valorizedTotal() {
    return lineItems.fold(0.0, (prev, current) => prev + current.amount);
  }

  double valorizedSnapshot() {
    return snapshotItems.fold(0.0, (prev, current) => prev + current.amount);
  }

  Future<Account> save() async {
    if (id < 0) {
      await Account.create(toMap());
    }
    return this;
  }

  Future<Account> delete() async {
    getSnapshotItems();
    await Future.wait(snapshotItems.map((v) => v.delete()));
    if (id > 0) {
      await DatabaseHelper.instance.delete("accounts", id);
    }
    return this;
  }

  Future<List<SnapshotItem>> createSnapshot() async {
    if (id <= 0) return [];
    await getSnapshotItems();
    await Future.wait(
        snapshotItems.map((snapshotItem) => snapshotItem.delete()));
    snapshotItems = [];
    lineItems.forEach((lineItem) async {
      SnapshotItem snapshotItem = SnapshotItem(-1, id, lineItem.coin!);
      snapshotItem.quantity = lineItem.quantity;
      await snapshotItem.save();
      snapshotItems.add(snapshotItem);
    });
    return snapshotItems;
  }

  static find(int id) async {
    var result = await DatabaseHelper.instance.query("accounts", id);
    if (result != null) {
      return _build(result);
    } else {
      return null;
    }
  }

  static Future<List<Account>> all() async {
    var collection = await DatabaseHelper.instance.queryAll("accounts");
    List<Account> list = [];
    for (Map<String, dynamic> accountMap in collection) {
      list.add(_build(accountMap));
    }
    return list;
  }

  static Future deleteAll() async {
    await DatabaseHelper.instance.deleteAll("accounts");
    //Todo: Delete dependents
  }

  static create(Map<String, dynamic> map) async {
    return await DatabaseHelper.instance.insert("accounts", map);
  }

  static Account _build(Map<String, dynamic> map) {
    Account acc = Account(map["_id"], map["name"], map["type"],
        map["enc_api_key"], map["enc_secret_key"], map["enc_passphrase"]);
    return acc;
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "type": type,
      "enc_api_key": encApiKey,
      "enc_secret_key": encSecretKey,
      "enc_passphrase": encPassphrase
    };
  }
}
