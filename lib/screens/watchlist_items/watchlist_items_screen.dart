import 'package:crypto_manager/models/watchlist_item.dart';
import 'package:crypto_manager/services/price_finder.dart';
import 'package:crypto_manager/widgets/action_menu_dialog.dart';
import 'package:crypto_manager/widgets/profitability_text.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:crypto_manager/app_theme.dart';

class WatchlistItemsScreen extends StatefulWidget {
  final didOpenNewWatchlistItemScreen;
  final didDeleteWatchlistItem;
  final getData;
  bool updatedData = false;
  List<WatchlistItem> watchlistItems = [];

  WatchlistItemsScreen(
      {Key? key,
      required this.watchlistItems,
      this.getData,
      required this.updatedData,
      this.didOpenNewWatchlistItemScreen,
      this.didDeleteWatchlistItem})
      : super(key: key);

  @override
  _WatchlistItemsScreenState createState() => _WatchlistItemsScreenState();
}

class _WatchlistItemsScreenState extends State<WatchlistItemsScreen> {
  Widget Watchlist() {
    TextStyle cellStyle = TextStyle(fontFamily: AppTheme.fontName);
    Widget bodyContent = SizedBox();
    if (widget.watchlistItems.isEmpty) {
      bodyContent = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          DataTable(columnSpacing: 0, columns: TableHeader(), rows: []),
          Expanded(
            child: Align(
                alignment: Alignment.center,
                child: Center(
                  child: Container(
                      child: const Text(
                        "There are no coins added to your watchlist. Add one using the floating button below.",
                        textAlign: TextAlign.center,
                      ),
                      width: 200),
                )),
          )
        ],
      );
    } else {
      bodyContent = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          DataTable(
              columnSpacing: 0,
              columns: TableHeader(),
              rows: widget.watchlistItems.map<DataRow>((v) {
                return DataRow(
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return ActionMenuDialog(context,
                                deleteCallback: () async {
                              await v.delete();
                              widget.didDeleteWatchlistItem();
                            });
                          });
                    },
                    cells: [
                      DataCell(Align(
                          alignment: Alignment.centerLeft,
                          child: Text(v.coin!, style: cellStyle))),
                      DataCell(Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              NumberFormat("\$#,##0.00", "en_US")
                                  .format(v.price),
                              style: cellStyle))),
                      DataCell(Align(
                          alignment: Alignment.centerRight,
                          child: ProfitabilityText(v.profitability("1h")))),
                      DataCell(Align(
                          alignment: Alignment.centerRight,
                          child: ProfitabilityText(v.profitability("24h"))))
                    ]);
              }).toList())
        ],
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: bodyContent,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          widget.didOpenNewWatchlistItemScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.updatedData) {
      return Watchlist();
    }
    return FutureBuilder<List<WatchlistItem>>(
        future: widget.getData(),
        builder: (BuildContext context,
            AsyncSnapshot<List<WatchlistItem>> snapshot) {
          if (snapshot.hasData) {
            widget.watchlistItems = snapshot.data!;
            return Watchlist();
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                DataTable(columnSpacing: 0, columns: TableHeader(), rows: []),
                Expanded(child: Center(child: CircularProgressIndicator()))
              ],
            );
          }
        });
  }

  List<DataColumn> TableHeader() {
    var spacing = 2.0;
    return [
      DataColumn(
          label: Expanded(
              child: Text("COIN",
                  style: TextStyle(
                      fontFamily: AppTheme.fontName, letterSpacing: spacing)))),
      DataColumn(
          label: Expanded(
              child: Text("PRICE",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontFamily: AppTheme.fontName, letterSpacing: spacing)))),
      DataColumn(
          label: Expanded(
              child: Text("1h",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontFamily: AppTheme.fontName, letterSpacing: spacing)))),
      DataColumn(
          label: Expanded(
              child: Text("24h",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontFamily: AppTheme.fontName, letterSpacing: spacing))))
    ];
  }
}
