import 'package:crypto_manager/models/concerns/valorizable.dart';
import 'package:crypto_manager/models/account.dart';
import "package:crypto_manager/services/database_helper.dart";
import 'package:crypto_manager/services/price_finder.dart';

class SnapshotItem extends Valorizable {
  late int id;
  late Account? account;
  late int accountId;
  late double quantity;
  double amount = 0.0;
  double price = 0.0;

  SnapshotItem(this.id, this.accountId, String coin, [double? quantity])
      : super(coin) {
    priceFinder = PriceFinder.instances[0];
    this.quantity = quantity != null ? quantity : 0.0;
  }

  void setAccount(Account account) {
    this.account = account;
    if (account.id > 0) {
      accountId = account.id;
    }
  }

  Future<SnapshotItem> save() async {
    if (id < 0) {
      await SnapshotItem.create(toMap());
    }
    return this;
  }

  Future<SnapshotItem> delete() async {
    if (id > 0) {
      await DatabaseHelper.instance.delete("snapshot_items", id);
    }
    return this;
  }

  static find(int id) async {
    var result = await DatabaseHelper.instance.query("snapshot_items", id);
    if (result != null) {
      return _build(result);
    } else {
      return null;
    }
  }

  static Future<List<SnapshotItem>> where(
      Map<String, dynamic> whereArgs) async {
    var result =
        await DatabaseHelper.instance.queryWhere("snapshot_items", whereArgs);
    if (result != null) {
      return result.map((e) => _build(e!)).toList();
    } else {
      return [];
    }
  }

  static Future<List<SnapshotItem>> all() async {
    var collection = await DatabaseHelper.instance.queryAll("snapshot_items");
    List<SnapshotItem> list = [];
    for (Map<String, dynamic> snapshotItemMap in collection) {
      list.add(_build(snapshotItemMap));
    }
    return list;
  }

  static Future deleteAll() async {
    await DatabaseHelper.instance.deleteAll("snapshot_items");
  }

  static create(Map<String, dynamic> map) async {
    return await DatabaseHelper.instance.insert("snapshot_items", map);
  }

  static SnapshotItem _build(Map<String, dynamic> map) {
    SnapshotItem acc = SnapshotItem(
        map["_id"], map["account_id"], map["coin"], map["quantity"]);
    return acc;
  }

  Map<String, dynamic> toMap() {
    return {"coin": coin, "quantity": quantity, "account_id": accountId};
  }
}
