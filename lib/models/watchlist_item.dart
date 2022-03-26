import 'package:crypto_manager/models/concerns/valorizable.dart';
import 'package:crypto_manager/services/price_finder.dart';
import "package:crypto_manager/services/database_helper.dart";

class WatchlistItem extends Valorizable {
  late int id;
  late PriceFinder _priceFinder;
  double? price;

  WatchlistItem(this.id, String coin, [PriceFinder? priceFinder])
      : super(coin) {
    if (priceFinder != null) {
      this.priceFinder = priceFinder;
    } else {
      this.priceFinder = PriceFinder.instances[0];
    }
  }

  Future<WatchlistItem> save() async {
    if (id < 0) {
      await WatchlistItem.create(toMap());
    }
    return this;
  }

  Future<WatchlistItem> delete() async {
    if (id > 0) {
      await DatabaseHelper.instance.delete("watchlist_items", id);
    }
    return this;
  }

  Future<void> getPrice() async {
    price = await priceFinder.currentPrice(coin);
  }

  static find(int id) async {
    var result = await DatabaseHelper.instance.query("watchlist_items", id);
    if (result != null) {
      return _build(result);
    } else {
      return null;
    }
  }

  static Future<List<WatchlistItem>> all() async {
    var collection = await DatabaseHelper.instance.queryAll("watchlist_items");
    List<WatchlistItem> list = [];
    for (Map<String, dynamic> watchlistItemMap in collection) {
      list.add(_build(watchlistItemMap));
    }
    return list;
  }

  static Future deleteAll() async {
    await DatabaseHelper.instance.deleteAll("watchlist_items");
  }

  static create(Map<String, dynamic> map) async {
    return await DatabaseHelper.instance.insert("watchlist_items", map);
  }

  static WatchlistItem _build(Map<String, dynamic> map) {
    WatchlistItem acc = WatchlistItem(map["_id"], map["coin"]);
    return acc;
  }

  Map<String, dynamic> toMap() {
    return {"coin": coin};
  }
}
