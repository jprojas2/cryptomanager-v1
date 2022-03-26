import 'package:crypto_manager/models/account.dart';
import 'package:crypto_manager/models/template.dart';
import 'package:crypto_manager/widgets/profitability_text.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:crypto_manager/app_theme.dart';

class AccountVersus extends StatelessWidget {
  late Account account;
  late List<Template> templates;
  var updatedData = false;
  var getData;

  AccountVersus(
      {Key? key,
      required this.account,
      required this.templates,
      required this.updatedData,
      required this.getData})
      : super(key: key);

  Widget versusList(context) {
    TextStyle cellStyle = TextStyle(fontFamily: AppTheme.fontName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (account.snapshotItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
                right: 23.0, left: 23.0, bottom: 15, top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Last portfolio"),
                Text(NumberFormat("\$#,##0.00", "en_US")
                    .format(account.valorizedSnapshot()))
              ],
            ),
          ),
        SizedBox(height: MediaQuery.of(context).padding.top),
        DataTable(
            columnSpacing: 0,
            columns: TableHeader(),
            rows: templates.map<DataRow>((v) {
              return DataRow(cells: [
                DataCell(Align(
                    alignment: Alignment.centerLeft,
                    child: Text(v.name, style: cellStyle))),
                DataCell(Align(
                    alignment: Alignment.centerRight,
                    child: ProfitabilityText(v.profitability("1h")))),
                DataCell(Align(
                    alignment: Alignment.centerRight,
                    child: (v.profitability("1h") != null &&
                            account.profitability("1h") != null)
                        ? ProfitabilityText(account.profitability("1h")! -
                            v.profitability("1h")!)
                        : ProfitabilityText(null)))
              ]);
            }).toList()),
        if (templates.isEmpty)
          Expanded(
            flex: 1,
            child: Align(
                alignment: Alignment.center,
                child: Center(
                  child: Container(
                      child: const Text(
                        "There are no templates created. Go to the \"Templates\" tab in the home screen to add one.",
                        textAlign: TextAlign.center,
                      ),
                      width: 200),
                )),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return updatedData
        ? versusList(context)
        : FutureBuilder<List<Template>>(
            future: getData(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Template>> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                templates = snapshot.data!;
                return versusList(context);
              }
            });
  }

  List<DataColumn> TableHeader() {
    var spacing = 2.0;
    return [
      DataColumn(
          label: Align(
              alignment: Alignment.centerLeft,
              child: Text("NAME",
                  style: TextStyle(
                      fontFamily: AppTheme.fontName, letterSpacing: spacing)))),
      DataColumn(
          label: Align(
              alignment: Alignment.centerRight,
              child: Text("1h",
                  style: TextStyle(
                      fontFamily: AppTheme.fontName, letterSpacing: spacing)))),
      DataColumn(
          label: Align(
              alignment: Alignment.centerRight,
              child: Text("+/-",
                  style: TextStyle(
                      fontFamily: AppTheme.fontName, letterSpacing: spacing))))
    ];
  }
}
