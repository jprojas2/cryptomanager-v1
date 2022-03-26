import 'package:crypto_manager/models/template.dart';
import 'package:crypto_manager/models/template_item.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';

import 'package:crypto_manager/app_theme.dart';

class TemplateScreen extends StatelessWidget {
  late Template template;
  TemplateScreen({Key? key, required this.template}) : super(key: key);

  Future<bool> getData() async {
    List<TemplateItem> templateItems = await TemplateItem.all();
    //await template.getItems();
    await template.computeProfitabilities(["24h"]);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            template.name,
            style: const TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.w400,
                fontSize: 15 + 6,
                letterSpacing: 1.2,
                color: AppTheme.nearlyBlack),
          ),
          iconTheme: const IconThemeData(
            color: AppTheme.nearlyBlack,
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 30.0, left: 40, right: 40),
                    child: PieChart(
                        chartType: ChartType.ring,
                        ringStrokeWidth: 40,
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValues: true,
                          showChartValuesInPercentage: true,
                        ),
                        dataMap: template.dataForPieChart()),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 12),
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Text(
                                        '1W',
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontWeight: FontWeight.w100,
                                          fontSize: 8 + 6,
                                          letterSpacing: 1.2,
                                          color: AppTheme.darkerText,
                                        ),
                                      ),
                                      SizedBox(height: 3.0),
                                      Text(
                                        'N/A',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 8 + 6,
                                          letterSpacing: 1.2,
                                          color: AppTheme.grey,
                                        ),
                                      ),
                                    ]),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Text(
                                        '1D',
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontWeight: FontWeight.w100,
                                          fontSize: 8 + 6,
                                          letterSpacing: 1.2,
                                          color: AppTheme.darkerText,
                                        ),
                                      ),
                                      SizedBox(height: 3.0),
                                      Text(
                                        'N/A',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 8 + 6,
                                          letterSpacing: 1.2,
                                          color: AppTheme.grey,
                                        ),
                                      ),
                                    ]),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Text(
                                        '1H',
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontWeight: FontWeight.w100,
                                          fontSize: 8 + 6,
                                          letterSpacing: 1.2,
                                          color: AppTheme.darkerText,
                                        ),
                                      ),
                                      SizedBox(height: 3.0),
                                      Text(
                                        'N/A',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 8 + 6,
                                          letterSpacing: 1.2,
                                          color: AppTheme.grey,
                                        ),
                                      ),
                                    ]),
                              )
                            ]),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: DataTable2(
                        columnSpacing: 0,
                        columns: const [
                          DataColumn(
                              label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("COIN"))),
                          DataColumn(
                              label: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text("WEIGHT"))),
                          DataColumn(
                              label: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text("1W")))
                        ],
                        rows: template.items.map<DataRow>((v) {
                          return DataRow(cells: [
                            DataCell(Align(
                                alignment: Alignment.centerLeft,
                                child: Text(v.coin!))),
                            DataCell(Align(
                                alignment: Alignment.centerRight,
                                child: Text(NumberFormat("#,##0.0%", "en_US")
                                    .format(v.weight)))),
                            DataCell(Align(
                                alignment: Alignment.centerRight,
                                child: Text(v.profitability("1h") != null
                                    ? NumberFormat("#,##0.0%", "en_US")
                                        .format(v.profitability("24h")!)
                                    : "N/A")))
                          ]);
                        }).toList()),
                  ),
                ],
              );
            }
          },
        ));
  }
}
