import "package:crypto_manager/services/database_helper.dart";

class UserConfiguration {
  late int id;
  late bool calculateProfitability;

  UserConfiguration._privateConstructor(this.id, this.calculateProfitability);

  static Future<UserConfiguration> getConfiguration() async {
    var result = await DatabaseHelper.instance.queryAll("user_configuration");
    if (result.isNotEmpty) {
      return _build(result[0]);
    } else {
      return UserConfiguration._privateConstructor(-1, true);
    }
  }

  static UserConfiguration _build(Map<String, dynamic> map) {
    UserConfiguration config = UserConfiguration._privateConstructor(
        map["_id"], map["calculate_profitability"] == 1);
    return config;
  }

  Future<UserConfiguration> save() async {
    if (id < 0) {
      id = await UserConfiguration.create(toMap());
      "hola";
    } else {
      await DatabaseHelper.instance.update("user_configuration", toMap(id));
    }
    return this;
  }

  static create(Map<String, dynamic> map) async {
    return await DatabaseHelper.instance.insert("user_configuration", map);
  }

  Map<String, dynamic> toMap([int? id]) {
    if (id != null) {
      return {
        "_id": id,
        "calculate_profitability": calculateProfitability ? 1 : 0,
      };
    } else {
      return {
        "calculate_profitability": calculateProfitability ? 1 : 0,
      };
    }
  }

  static Future deleteAll() async {
    await DatabaseHelper.instance.deleteAll("user_configuration");
    //Todo: Delete dependents
  }
}
