import 'package:crypto_manager/screens/accounts/new_account_screens/account_type_screen.dart';
import 'package:crypto_manager/screens/accounts/new_account_screens/binance/account_qr_code_screen.dart';
import 'package:crypto_manager/screens/accounts/new_account_screens/binance/binance_api_key_screen.dart';
import 'package:crypto_manager/screens/accounts/new_account_screens/account_details_screen.dart';
import 'package:crypto_manager/models/account.dart';
import 'package:crypto_manager/app_theme.dart';

import 'package:flutter/material.dart';

import 'new_account_screens/kucoin_api_key_screen.dart';

class NewAccountNavigator extends StatefulWidget {
  NewAccountNavigator({Key? key, required this.didSaveNewAccount})
      : super(key: key);

  final didSaveNewAccount;
  static const valueKey = ValueKey('NewAccountNavigator');

  @override
  State<StatefulWidget> createState() => NewAccountNavigatorState();
}

class NewAccountNavigatorState extends State<NewAccountNavigator> {
  Account _newAccount = new Account(-1, "", -1, "", "");
  int _newAccountStep = 0;

  @override
  Widget build(BuildContext context) {
    final childBackButtonDispatcher =
        ChildBackButtonDispatcher(Router.of(context).backButtonDispatcher!);
    childBackButtonDispatcher.takePriority();
    return Router(
      routerDelegate: NewAccountRouterDelegate(
          _newAccount,
          _newAccountStep,
          (step) => setState(() {
                if (step >= 0)
                  _newAccountStep = step;
                else
                  Navigator.pop(context);
              }),
          widget.didSaveNewAccount),
      backButtonDispatcher: childBackButtonDispatcher,
    );
  }
}

final GlobalKey<NavigatorState> _nestedNavigatorKey =
    GlobalKey<NavigatorState>();

class NewAccountRouterDelegate extends RouterDelegate with ChangeNotifier {
  final updateState;
  final didSaveNewAccount;
  Account account;
  int newAccountStep;
  bool qrCodeScreen = false;

  NewAccountRouterDelegate(this.account, this.newAccountStep, this.updateState,
      this.didSaveNewAccount)
      : super();

  @override
  Future<bool> popRoute() async {
    print('popRoute NestedRouterDelegate');
    newAccountStep -= 1;
    updateState(newAccountStep);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: newAccountStep == 0
          ? AppBar(
              iconTheme: IconThemeData(
                color: AppTheme.nearlyBlack,
              ),
              backgroundColor: AppTheme.nearlyWhite,
              elevation: 0,
            )
          : null,
      body: Navigator(
        key: _nestedNavigatorKey,
        observers: [HeroController()],
        pages: [
          MaterialPage(
              child: AccountTypeScreen(
                  newAccount: account,
                  accountTypeSelected: (accountType) {
                    account.type = accountType;
                    updateState(1);
                    //notifyListeners();
                  })),
          if (newAccountStep == 1 && account.type == 1 && !qrCodeScreen)
            MaterialPage(
                child: BinanceApiKeyScreen(advanceStep: (api_key, secret_key) {
              updateState(2);
              account.encApiKey = api_key;
              account.encSecretKey = secret_key;
            }, openQRCodeScreen: () {
              qrCodeScreen = true;
              notifyListeners();
            }))
          else if (newAccountStep == 1 && account.type == 2 && !qrCodeScreen)
            MaterialPage(child: KucoinApiKeyScreen(
                advanceStep: (api_key, secret_key, passphrase) {
              updateState(2);
              account.encApiKey = api_key;
              account.encSecretKey = secret_key;
              account.encPassphrase = passphrase;
            }))
          else if (newAccountStep == 1 && account.type == 1)
            MaterialPage(child:
                AccountQrCodeScreen(advanceStep: (api_key, secret_key, name) {
              updateState(2);
              account.encApiKey = api_key;
              account.encSecretKey = secret_key;
              account.name = name;
            }))
          else if ((newAccountStep == 2 &&
                  (account.type == 1 || account.type == 2)) ||
              (newAccountStep == 1 && account.type != 1))
            MaterialPage(
                child: AccountDetailsScreen(
                    account: account,
                    advanceStep: (name) async {
                      account.name = name;
                      await account.save();
                      didSaveNewAccount();
                    }))
        ],
        onPopPage: (route, result) {
          newAccountStep -= 1;
          updateState(newAccountStep);
          return false;
        },
      ),
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) async => null;
}
