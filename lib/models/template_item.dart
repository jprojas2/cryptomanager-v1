import 'package:crypto_manager/models/concerns/valorizable.dart';
import 'package:crypto_manager/models/template.dart';
import "package:crypto_manager/services/database_helper.dart";
import 'package:crypto_manager/services/price_finder.dart';

class TemplateItem extends Valorizable {
  late int id;
  late Template? template;
  late int template_id;
  late double weight;

  TemplateItem(this.id, this.template_id, String? coin,
      [double? weight, PriceFinder? priceFinder])
      : super(coin) {
    if (priceFinder != null) {
      this.priceFinder = priceFinder;
    } else {
      this.priceFinder = PriceFinder.instances[0];
    }
    this.weight = weight != null ? weight : 0.0;
  }

  void setTemplate(Template template) {
    this.template = template;
    if (template.id > 0) {
      template_id = template.id;
    }
  }

  Future<TemplateItem> save() async {
    if (id < 0) {
      await TemplateItem.create(toMap());
    }
    return this;
  }

  Future<TemplateItem> delete() async {
    if (id > 0) {
      await DatabaseHelper.instance.delete("template_items", id);
    }
    return this;
  }

  static find(int id) async {
    var result = await DatabaseHelper.instance.query("template_items", id);
    if (result != null) {
      return _build(result);
    } else {
      return null;
    }
  }

  static Future<List<TemplateItem>> where(
      Map<String, dynamic> whereArgs) async {
    var result =
        await DatabaseHelper.instance.queryWhere("template_items", whereArgs);
    if (result != null) {
      return result.map((e) => _build(e!)).toList();
    } else {
      return [];
    }
  }

  static Future<List<TemplateItem>> all() async {
    var collection = await DatabaseHelper.instance.queryAll("template_items");
    List<TemplateItem> list = [];
    for (Map<String, dynamic> templateItemMap in collection) {
      list.add(_build(templateItemMap));
    }
    return list;
  }

  static Future deleteAll() async {
    await DatabaseHelper.instance.deleteAll("template_items");
  }

  static create(Map<String, dynamic> map) async {
    return await DatabaseHelper.instance.insert("template_items", map);
  }

  static TemplateItem _build(Map<String, dynamic> map) {
    TemplateItem acc = TemplateItem(
        map["_id"], map["template_id"], map["coin"], map["weight"]);
    return acc;
  }

  Map<String, dynamic> toMap() {
    return {"coin": coin, "weight": weight, "template_id": template_id};
  }
}
