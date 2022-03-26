import 'package:crypto_manager/screens/accounts/account_screen.dart';
import 'package:crypto_manager/services/binance.dart';
import 'package:crypto_manager/screens/templates/template_screen.dart';
import 'package:crypto_manager/screens/watchlist_items/new_watchlist_item_screen.dart';
import 'package:crypto_manager/models/account.dart';
import 'package:crypto_manager/models/template.dart';
import 'package:move_to_background/move_to_background.dart';

import 'package:flutter/material.dart';

import 'home_screen.dart';

class HomeNavigator extends StatefulWidget {
  HomeNavigator({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int selectedIndex = 0;

  Widget build(BuildContext context) {
    return Router(
      routerDelegate: HomeRouterDelegate(this),
      backButtonDispatcher: RootBackButtonDispatcher(),
    );
  }
}

class HomeRouterDelegate extends RouterDelegate with ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey;
  bool _newAccountScreen = false;
  bool _newWatchlistItemScreen = false;
  bool _newTemplateScreen = false;
  List<String> availableCoins = [];
  _HomeNavigatorState ctx;
  Account? account;
  Template? template;

  HomeRouterDelegate(this.ctx) : navigatorKey = GlobalKey<NavigatorState>();

  @override
  Future<bool> popRoute() async {
    if (_newAccountScreen ||
        account != null ||
        _newWatchlistItemScreen ||
        template != null) {
      account = null;
      template = null;
      _newAccountScreen = false;
      _newWatchlistItemScreen = false;
      _newTemplateScreen = false;
      //updateState();
    } else {
      MoveToBackground.moveTaskToBack();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      observers: [HeroController()],
      pages: [
        MaterialPage(
          key: ValueKey('HomeScreen'),
          child: HomeScreen(
            selectedIndex: ctx.selectedIndex,
            didOpenNewAccountScreen: () {
              _newAccountScreen = true;
              notifyListeners();
            },
            didOpenAccountScreen: (account) {
              this.account = account;
              notifyListeners();
            },
            didOpenNewWatchlistItemScreen: () {
              _newWatchlistItemScreen = true;
              notifyListeners();
            },
            didOpenNewTemplateScreen: () {
              _newTemplateScreen = true;
              notifyListeners();
            },
            didOpenTemplateScreen: (template) {
              this.template = template;
              notifyListeners();
            },
            didChangeBottomNavigation: (_index) {
              ctx.selectedIndex = _index;
            },
          ),
        ),
        if (_newWatchlistItemScreen)
          MaterialPage(
              key: NewWatchlistItemScreen.valueKey,
              child: NewWatchlistItemScreen(
                  availableCoins: availableCoins,
                  didSaveWatchlistItem: () {
                    ctx.selectedIndex = 1;
                    ctx.setState(() {});
                  },
                  getAvailableCoins: getAvailableCoins)),
        if (account != null)
          MaterialPage(child: AccountScreen(account: account!)),
        if (template != null)
          MaterialPage(child: TemplateScreen(template: template!)),
      ],
      onPopPage: (route, result) {
        //if (!route.didPop(result)) return false;
        _newAccountScreen = false;
        _newWatchlistItemScreen = false;
        _newTemplateScreen = false;
        account = null;
        template = null;
        notifyListeners();
        return false;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) async => null;

  Future<List<String>> getAvailableCoins() async {
    if (availableCoins.isEmpty) {
      Map<String, dynamic> exchangeInfo = await Binance(null).exchangeInfo();
      List<dynamic> symbols = exchangeInfo["symbols"];
      Map<String, String> uniqueMap = {};
      symbols.forEach((v) => {
            if (!v.toString().contains("UP") &&
                !v.toString().contains("DOWN") &&
                v["quoteAsset"] == "USDT")
              {uniqueMap[v["baseAsset"].toString()] = v["baseAsset"].toString()}
          });
      availableCoins = uniqueMap.keys.toList();
      availableCoins.sort((a, b) => a.compareTo(b));
    }
    return availableCoins;
  }
}
