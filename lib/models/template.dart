import 'package:crypto_manager/models/template_item.dart';
import 'package:crypto_manager/services/price_finder.dart';
import 'package:crypto_manager/extensions.dart';
import "package:crypto_manager/services/database_helper.dart";

class Template {
  late int id;
  late String name;
  List<TemplateItem> items = [];
  PriceFinder priceFinder = PriceFinder.instances[0];

  Template(this.id, this.name);

  Future<List<TemplateItem>> getItems() async {
    items = await TemplateItem.where({"template_id": id});
    return items;
  }

  Future<Template> save() async {
    if (id < 0) {
      int result = await Template.create(toMap());
      id = result;
      if (items.isNotEmpty) {
        await Future.wait(items.map((item) {
          item.template_id = id;
          return item.save();
        }));
      }
    } else {
      await DatabaseHelper.instance.update("templates", toMap(id));
      List<TemplateItem> toBeSaved = items;
      await getItems();
      await Future.wait(items.map((v) => v.delete()));
      if (toBeSaved.isNotEmpty) {
        await Future.wait(toBeSaved.map((item) {
          item.id = -1;
          item.template_id = id;
          return item.save();
        }));
      }
    }
    return this;
  }

  Future<Template> delete() async {
    await getItems();
    await Future.wait(items.map((v) => v.delete()));
    if (id > 0) {
      await DatabaseHelper.instance.delete("templates", id);
    }
    return this;
  }

  Map<String, double> dataForPieChart() {
    List<TemplateItem> _keptLineItems = items;
    int limit = 6;
    if (_keptLineItems.length > limit) {
      var _auxLineItems = _keptLineItems.sublist(0, limit);
      List<TemplateItem> _otherLineItems =
          _keptLineItems.sublist(limit, _keptLineItems.length - 1);
      var otherItem =
          _otherLineItems.fold(TemplateItem(-1, -1, "Other"), (prev, elem) {
        (prev as TemplateItem).weight += elem.weight;
        return prev;
      });
      _auxLineItems.add(otherItem);
      _keptLineItems = _auxLineItems;
    }
    return Map.fromIterable(_keptLineItems,
        key: (v) => v.coin, value: (v) => v.weight);
  }

  double? profitability(String period) {
    return items.fold(0.0, (prev, element) {
      if (element.profitability(period) != null && prev != null) {
        return (prev as double) +
            element.profitability(period)! * element.weight;
      } else {
        return null;
      }
    });
  }

  Future<void> computeProfitabilities(List<String> periods,
      [PriceFinder? priceFinder]) async {
    await Future.wait(
        items.map((v) => v.computeProfitabilities(periods, priceFinder)));
  }

  Future<void> computeProfitability(String period,
      [PriceFinder? priceFinder]) async {
    await Future.wait(items.map((v) => v.computeProfitability(period)));
  }

  static find(int id) async {
    var result = await DatabaseHelper.instance.query("templates", id);
    if (result != null) {
      return _build(result);
    } else {
      return null;
    }
  }

  static Future<List<Template>> all() async {
    var collection = await DatabaseHelper.instance.queryAll("templates");
    List<Template> list = [];
    for (Map<String, dynamic> templateMap in collection) {
      list.add(_build(templateMap));
    }
    return list;
  }

  static Future<List<Template>> allWithItems() async {
    var collection = await DatabaseHelper.instance.queryAll("templates");
    List<Template> list = [];
    List<int> template_ids = [];
    for (Map<String, dynamic> templateMap in collection) {
      list.add(_build(templateMap));
      template_ids.add(list.last.id);
    }
    List<TemplateItem> items =
        await TemplateItem.where({"template_id": template_ids});
    Map<int, List<TemplateItem>> groupedItems =
        items.groupBy((element) => element.template_id);
    list.forEach((element) {
      if (groupedItems[element.id] != null) {
        element.items = groupedItems[element.id]!;
      }
    });
    return list;
  }

  static Future deleteAll() async {
    await DatabaseHelper.instance.deleteAll("templates");
  }

  static create(Map<String, dynamic> map) async {
    return await DatabaseHelper.instance.insert("templates", map);
  }

  static Template _build(Map<String, dynamic> map) {
    Template acc = Template(map["_id"], map["name"]);
    return acc;
  }

  Map<String, dynamic> toMap([int? id]) {
    if (id != null) {
      return {"_id": id, "name": name};
    } else {
      return {"name": name};
    }
  }
}
