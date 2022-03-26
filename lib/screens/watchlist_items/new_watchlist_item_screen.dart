import 'package:crypto_manager/models/watchlist_item.dart';
import 'package:crypto_manager/widgets/coin_selector.dart';
import 'package:flutter/material.dart';

import 'package:crypto_manager/app_theme.dart';

class NewWatchlistItemScreen extends StatelessWidget {
  NewWatchlistItemScreen(
      {Key? key,
      required this.availableCoins,
      required this.getAvailableCoins,
      required this.didSaveWatchlistItem})
      : super(key: key);

  final didSaveWatchlistItem;
  final getAvailableCoins;
  List<String> availableCoins = [];
  static const valueKey = ValueKey('NewWatchlistItemScreen');

  WatchlistItem newWatchlistItem = WatchlistItem(-1, "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: AppTheme.nearlyBlack,
          ),
          title: Text("Select a coin"),
          backgroundColor: AppTheme.nearlyWhite,
          titleTextStyle: TextStyle(
            fontFamily: AppTheme.fontName,
            fontWeight: FontWeight.w700,
            fontSize: 15 + 6,
            letterSpacing: 1.2,
            color: AppTheme.darkerText,
          ),
          elevation: 0,
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: CoinSelector(
              availableCoins: availableCoins,
              getAvailableCoins: getAvailableCoins,
              selectedCallback: (coin) async {
                newWatchlistItem.coin = coin;
                await newWatchlistItem.save();
                didSaveWatchlistItem();
              },
            )));
  }
}
