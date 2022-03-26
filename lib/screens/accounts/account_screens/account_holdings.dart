import 'package:crypto_manager/models/account.dart';
import 'package:crypto_manager/widgets/action_menu_dialog.dart';
import 'package:crypto_manager/widgets/profitability_text.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';

import 'package:crypto_manager/app_theme.dart';

class AccountHoldings extends StatelessWidget {
  late Account account;
  var updatedData = false;
  var getData;
  var liquidateCoin;
  AccountHoldings(
      {Key? key,
      required this.account,
      required this.updatedData,
      required this.getData,
      this.liquidateCoin})
      : super(key: key);

  Widget holdings(context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30.0, left: 40, right: 40),
          child: PieChart(
              chartType: ChartType.ring,
              ringStrokeWidth: 40,
              chartValuesOptions: const ChartValuesOptions(
                showChartValues: true,
                showChartValuesInPercentage: true,
              ),
              dataMap: account.dataForPieChart()),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 8.0, top: 8.0),
                          child: Text(
                            'Total',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontWeight: FontWeight.w700,
                              fontSize: 15 + 6,
                              letterSpacing: 1.2,
                              color: AppTheme.darkerText,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            NumberFormat("\$#,##0.00", "en_US")
                                .format(account.valorizedTotal()),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontWeight: FontWeight.w700,
                              fontSize: 25 + 6,
                              letterSpacing: 1.2,
                              color: AppTheme.darkerText,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '1w',
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontWeight: FontWeight.w100,
                                fontSize: 8 + 6,
                                letterSpacing: 1.2,
                                color: AppTheme.darkerText,
                              ),
                            ),
                            SizedBox(height: 3.0),
                            ProfitabilityText(account.profitability("1w"), 14),
                          ]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '24h',
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontWeight: FontWeight.w100,
                                fontSize: 8 + 6,
                                letterSpacing: 1.2,
                                color: AppTheme.darkerText,
                              ),
                            ),
                            SizedBox(height: 3.0),
                            ProfitabilityText(account.profitability("24h"), 14),
                          ]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '1h',
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontWeight: FontWeight.w100,
                                fontSize: 8 + 6,
                                letterSpacing: 1.2,
                                color: AppTheme.darkerText,
                              ),
                            ),
                            SizedBox(height: 3.0),
                            ProfitabilityText(account.profitability("1h"), 14),
                          ]),
                    )
                  ])
                ],
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: DataTable(
              columnSpacing: 0,
              columns: const [
                DataColumn(label: Expanded(child: Text("COIN"))),
                DataColumn(
                    label: Expanded(
                        child: Text("QUANTITY", textAlign: TextAlign.right))),
                DataColumn(
                    label: Expanded(
                        child: Text("AMOUNT", textAlign: TextAlign.right))),
                DataColumn(
                    label:
                        Expanded(child: Text("1w", textAlign: TextAlign.right)))
              ],
              rows: account.lineItems.map<DataRow>((v) {
                return DataRow(
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return ActionMenuDialog(context,
                                toCashCallback: () async {
                              liquidateCoin(account, v.coin!);
                            });
                          });
                    },
                    cells: [
                      DataCell(Align(
                          alignment: Alignment.centerLeft,
                          child: Text(v.coin!))),
                      DataCell(Align(
                          alignment: Alignment.centerRight,
                          child: Text(NumberFormat("#,##0.0000", "en_US")
                              .format(v.quantity)))),
                      DataCell(Align(
                          alignment: Alignment.centerRight,
                          child: Text(NumberFormat("\$#,##0.00", "en_US")
                              .format(v.amount)))),
                      DataCell(Align(
                          alignment: Alignment.centerRight,
                          child: Text(v.profitability("1w") != null
                              ? NumberFormat("#,##0.0%", "en_US")
                                  .format(v.profitability("1w")!)
                              : "N/A")))
                    ]);
              }).toList()),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return updatedData
        ? holdings(context)
        : FutureBuilder<bool>(
            future: getData(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (!snapshot.hasData || !snapshot.data!) {
                return Center(child: CircularProgressIndicator());
              } else {
                return holdings(context);
              }
            },
          );
  }
}
