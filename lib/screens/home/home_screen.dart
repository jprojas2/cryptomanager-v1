import 'package:crypto_manager/screens/templates/templates_screen.dart';
import 'package:crypto_manager/screens/watchlist_items/watchlist_items_screen.dart';
import 'package:crypto_manager/screens/accounts/accounts_screen.dart';
import 'package:crypto_manager/models/account.dart';
import 'package:crypto_manager/models/template.dart';
import 'package:crypto_manager/models/watchlist_item.dart';
import 'package:crypto_manager/services/price_finder.dart';
import 'package:crypto_manager/app_theme.dart';

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final didOpenNewAccountScreen;
  final didOpenNewWatchlistItemScreen;
  final didOpenNewTemplateScreen;
  final didOpenAccountScreen;
  final didOpenTemplateScreen;
  final didChangeBottomNavigation;

  int selectedIndex;
  HomeScreen(
      {Key? key,
      required this.selectedIndex,
      this.didOpenNewAccountScreen,
      this.didOpenAccountScreen,
      this.didOpenNewWatchlistItemScreen,
      this.didOpenNewTemplateScreen,
      this.didOpenTemplateScreen,
      this.didChangeBottomNavigation})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool updatedAccountsData = false;
  bool updatedWatchlistData = false;
  bool updatedTemplatesData = false;
  List<Account> accounts = [];
  List<WatchlistItem> watchlistItems = [];
  List<Template> templates = [];
  List<String> availableCoins = [];

  Future<List<Account>> getAccountsData() async {
    if (updatedAccountsData) {
      return accounts;
    }
    print("GETTING ACCOUNTS DATA!!");
    accounts = await Account.all();
    await Future.wait(accounts.map((v) {
      return v.getLineItems();
    }));
    await Future.wait(accounts.map((v) {
      return v.valorizeAccount();
    }));
    await Future.wait(accounts.map((v) {
      return v.checkTradeability();
    }));

    //await Future.wait(accounts.map((v) {
    //  return v.computeProfitabilities(["1h", "24h", "1w"]);
    //}));

    await Future<dynamic>.delayed(const Duration(milliseconds: 500));
    //animationController.forward();
    updatedAccountsData = true;
    return accounts;
  }

  Future<List<WatchlistItem>> getWatchlistData() async {
    if (updatedWatchlistData) {
      return watchlistItems;
    }
    print("GETTING WATCHLIST DATA!!");
    watchlistItems = await WatchlistItem.all();
    //watchlistItems = ["BTC", "ETH", "ADA", "SOL", "LUNA", "MATIC", "FTM"]
    //    .map((v) => WatchlistItem(-1, v))
    //    .toList();
    await Future.wait(watchlistItems.map((v) => v.getPrice()));
    await Future.wait(
        watchlistItems.map((v) => v.computeProfitabilities(["1h", "24h"])));
    updatedWatchlistData = true;
    return watchlistItems;
  }

  Future<List<Template>> getTemplatesData() async {
    if (updatedTemplatesData) {
      return templates;
    }
    print("GETTING TEMPLATES DATA!!");
    templates = await Template.allWithItems();
    await Future.wait(
        templates.map((v) => v.computeProfitabilities(["1h", "24h"])));
    updatedTemplatesData = true;
    return templates;
  }

  @override
  Widget buildNew(BuildContext context) {
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent = SizedBox();

    if (widget.selectedIndex == 1) {
      bodyContent = WatchlistItemsScreen(
        watchlistItems: watchlistItems,
        getData: getWatchlistData,
        updatedData: updatedWatchlistData,
        didOpenNewWatchlistItemScreen: widget.didOpenNewWatchlistItemScreen,
        didDeleteWatchlistItem: () {
          setState(() {
            updatedWatchlistData = false;
          });
        },
      );
    } else if (widget.selectedIndex == 2) {
      bodyContent = TemplatesScreen(
          templates: templates,
          getData: getTemplatesData,
          updatedData: updatedTemplatesData,
          didOpenTemplateScreen: widget.didOpenTemplateScreen,
          refreshHomeScreen: () {
            setState(() {
              updatedTemplatesData = false;
            });
          });
    } else {
      bodyContent = AccountsScreen(
          accounts: accounts,
          getData: getAccountsData,
          updatedData: updatedAccountsData,
          refreshHomeScreen: () {
            setState(() {
              updatedAccountsData = false;
            });
          },
          didOpenAccountScreen: widget.didOpenAccountScreen);
    }
    return RefreshIndicator(
      onRefresh: () async {
        PriceFinder.resetAll();
        if (widget.selectedIndex == 1) {
          updatedWatchlistData = false;
          await getWatchlistData();
        } else if (widget.selectedIndex == 2) {
          updatedTemplatesData = false;
          await getTemplatesData();
        } else {
          updatedAccountsData = false;
          await getAccountsData();
        }
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          child: Scaffold(
              backgroundColor: AppTheme.background,
              body: bodyContent,
              bottomNavigationBar: bottomNavigation()),
          height: MediaQuery.of(context).size.height,
        ),
      ),
    );
  }

  Widget bottomNavigation() {
    return BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Accounts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.toc_outlined), label: 'Watchlist'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline), label: 'Templates'),
        ],
        currentIndex: widget.selectedIndex,
        onTap: (int index) {
          setState(() {
            widget.didChangeBottomNavigation(index);
            widget.selectedIndex = index;
          });
        });
  }
}
