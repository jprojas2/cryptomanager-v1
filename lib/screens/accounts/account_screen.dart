import 'package:crypto_manager/screens/accounts/account_screens/account_holdings.dart';
import 'package:crypto_manager/screens/accounts/account_screens/account_versus.dart';
import 'package:crypto_manager/models/account.dart';
import 'package:crypto_manager/models/template.dart';
import 'package:crypto_manager/models/template_item.dart';
import 'package:crypto_manager/screens/accounts/transform_account_navigator.dart';
import 'package:crypto_manager/services/price_finder.dart';
import 'package:crypto_manager/services/transformer.dart';
import 'package:crypto_manager/widgets/transform_confirm_dialog.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:crypto_manager/app_theme.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  final Account account;
  const AccountScreen({Key? key, required this.account}) : super(key: key);
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  var updatedHoldingsData = false;
  var updatedVersusData = false;
  var forceLoading = false;
  int selectedIndex = 0;
  List<Template> templates = [];

  Future<bool> getHoldingsData() async {
    if (forceLoading) return false;
    print("GET HOLDINGS DATA!!");
    await widget.account.getLineItems();
    await widget.account.valorizeAccount();
    await widget.account.computeProfitabilities(["1h", "24h"]);
    updatedHoldingsData = true;
    return true;
  }

  Future<List<Template>> getVersusData() async {
    print("GET VERSUS DATA!!");
    templates = await Template.allWithItems();
    await widget.account.getSnapshotItems();
    await widget.account.valorizeSnapshot();
    await Future.wait(templates.map((v) => v.computeProfitability("1h")));
    updatedVersusData = true;
    return templates;
  }

  @override
  void initState() {
    PriceFinder.resetAll();
    super.initState();
  }

  Future<void> accountTransformationConfirmed(account, template) async {
    setState(() {
      forceLoading = true;
    });
    //await Transformer.executeOffline(account, template);
    await account.transform(template);
    await account.getLineItems();
    await account.valorizeAccount();
    setState(() {
      forceLoading = false;
    });
  }

  Future<void> coinLiquidationConfirmed(account, coin) async {
    setState(() {
      forceLoading = true;
    });
    await account.liquidate(coin, false, false);
    await account.getLineItems();
    await account.valorizeAccount();
    setState(() {
      forceLoading = false;
    });
  }

  Future<dynamic> portfolioToCashConfirm(
      BuildContext context, Account account) {
    Template cashTemplate = Template(-1, "Cash");
    cashTemplate.items = [TemplateItem(-1, -1, "USDT", 1.0)];
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return TransformConfirmDialog(
            getFees: () async {
              await account.transform(cashTemplate, true);
              return account.transformationFees();
            },
            confirmCallback: () async {
              Navigator.pop(context);
              await accountTransformationConfirmed(account, cashTemplate);
            },
          );
        });
  }

  Future<dynamic> coinToCashConfirm(
      BuildContext context, Account account, String coin) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return TransformConfirmDialog(
            getFees: () async {
              await account.liquidate(coin, true);
              return account.transformationFees();
            },
            confirmCallback: () async {
              Navigator.pop(context);
              await coinLiquidationConfirmed(account, coin);
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        PriceFinder.resetAll();
        updatedVersusData = updatedHoldingsData = false;
        if (selectedIndex == 1) {
          await getVersusData();
        } else
          await getHoldingsData();
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          child: Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.account.name,
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
              body: selectedIndex == 1
                  ? AccountVersus(
                      account: widget.account,
                      templates: templates,
                      updatedData: updatedVersusData,
                      getData: getVersusData)
                  : AccountHoldings(
                      account: widget.account,
                      updatedData: updatedHoldingsData && !forceLoading,
                      getData: getHoldingsData,
                      liquidateCoin: (account, coin) {
                        coinToCashConfirm(context, account, coin);
                      }),
              bottomNavigationBar: BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.cases_outlined),
                      label: 'Holdings',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.compare),
                      label: 'Versus',
                    ),
                  ],
                  currentIndex: selectedIndex,
                  selectedItemColor: Colors.amber[800],
                  onTap: (int index) {
                    selectedIndex = index;
                    setState(() {});
                  }),
              floatingActionButton: (selectedIndex == 1 ||
                      !widget.account.transformable)
                  ? SizedBox()
                  : SpeedDial(
                      icon: Icons.transform,
                      activeIcon: Icons.close,
                      spacing: 3,
                      childPadding: const EdgeInsets.all(5),
                      spaceBetweenChildren: 4,
                      label: const Text("Transform"),
                      direction: SpeedDialDirection.down,
                      onOpen: () => debugPrint('OPENING DIAL'),
                      onClose: () => debugPrint('DIAL CLOSED'),
                      tooltip: 'Open Speed Dial',
                      heroTag: 'speed-dial-hero-tag',
                      children: [
                        SpeedDialChild(
                          child: const Icon(Icons.pie_chart_outline),
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.nearlyBlue,
                          label: 'To template',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TransformAccountNavigator(
                                        account: widget.account,
                                        accountTransformationConfirmed:
                                            accountTransformationConfirmed,
                                      )),
                            );
                          },
                        ),
                        SpeedDialChild(
                          child: const Icon(Icons.attach_money),
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.nearlyBlue,
                          label: 'To cash',
                          onTap: () =>
                              portfolioToCashConfirm(context, widget.account),
                        ),
                      ],
                    ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endTop),
          height: MediaQuery.of(context).size.height,
        ),
      ),
    );
  }
}
