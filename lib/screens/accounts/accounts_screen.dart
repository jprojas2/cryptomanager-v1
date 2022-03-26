import 'package:crypto_manager/models/account.dart';
import 'package:crypto_manager/models/user_configuration.dart';
import 'package:crypto_manager/screens/accounts/new_account_navigator.dart';
import 'package:crypto_manager/widgets/wallet_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:crypto_manager/app_theme.dart';

class AccountsScreen extends StatefulWidget {
  final didOpenAccountScreen;
  final refreshHomeScreen;
  var getData;
  List<Account> accounts = [];
  bool updatedData = false;

  AccountsScreen(
      {Key? key,
      required this.accounts,
      this.getData,
      required this.updatedData,
      this.refreshHomeScreen,
      this.didOpenAccountScreen})
      : super(key: key);

  @override
  _AccountsScreenState createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  double topBarOpacity = 0.0;
  late AnimationController animationController;

  int selectedItem = 0;
  bool updatedData = false;
  UserConfiguration? userConfiguration;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget accountsContainer() {
    return Container(
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: <Widget>[
            if (widget.accounts.isNotEmpty) getAppBarUI(),
            if (widget.accounts.isEmpty) SizedBox(height: 80),
            getMainListViewUI(context)
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        NewAccountNavigator(didSaveNewAccount: () {
                          Navigator.pop(context);
                          widget.refreshHomeScreen();
                        })),
              );
            },
            tooltip: "New account",
            child: const Icon(Icons.add)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.updatedData
        ? accountsContainer()
        : FutureBuilder<List<Account>>(
            future: widget.getData(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Account>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else {
                widget.accounts = snapshot.data!;
                return accountsContainer();
              }
            });
  }

  Widget getMainListViewUI(BuildContext context) {
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    const double itemHeight = 245;
    final double itemWidth = size.width;

    if (widget.accounts.isNotEmpty) {
      return Expanded(
        flex: 1,
        child: OrientationBuilder(builder: (context, orientation) {
          return Padding(
              padding: EdgeInsets.only(top: 0, bottom: 0, left: 16, right: 16),
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        (orientation == Orientation.portrait) ? 1 : 2,
                    childAspectRatio: (orientation == Orientation.portrait
                        ? (itemWidth / itemHeight)
                        : ((itemWidth + 35) / (itemHeight * 2))),
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 12),
                scrollDirection: Axis.vertical,
                itemCount: widget.accounts.length,
                itemBuilder: (BuildContext context, int index) {
                  return WalletCard(
                    account: widget.accounts[index],
                    animationController: animationController,
                    animation: topBarAnimation,
                    openAccount: widget.didOpenAccountScreen,
                    deleteAccount: (account) async {
                      await account.delete();
                      widget.refreshHomeScreen();
                    },
                    ctx: context,
                  );
                },
              ));
        }),
      );
    } else {
      return Expanded(
        flex: 1,
        child: Align(
          alignment: Alignment
              .center, // Align however you like (i.e .centerRight, centerLeft)
          child: Container(
              child: const Text(
                "There are no accounts added. Add one of your accounts using the floating button below.",
                textAlign: TextAlign.center,
              ),
              width: 200),
        ),
      );
    }
  }

  Widget getAppBarUI() {
    double totalHoldings =
        widget.accounts.fold(0.0, (prev, elem) => prev + elem.valorizedTotal());
    return Column(
      children: <Widget>[
        FadeTransition(
          opacity: topBarAnimation!,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(topBarOpacity),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32.0),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: AppTheme.grey.withOpacity(0.4 * topBarOpacity),
                    offset: const Offset(1.1, 1.1),
                    blurRadius: 10.0),
              ],
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).padding.top),
                Padding(
                  padding: EdgeInsets.only(
                      left: 16, right: 16, top: 16 - 8.0, bottom: 12 - 8.0),
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
                                  padding: const EdgeInsets.only(
                                      left: 8.0, top: 8.0),
                                  child: Text(
                                    'Total Holdings',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15 + 6 - 6 * topBarOpacity,
                                      letterSpacing: 1.2,
                                      color: AppTheme.darkerText,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    NumberFormat("\$#,##0.00", "en_US")
                                        .format(totalHoldings),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 25 + 6 - 6 * topBarOpacity,
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
                                  children: <Widget>[
                                    Text(
                                      '1h',
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.w100,
                                        fontSize: 8 + 6 - 6 * topBarOpacity,
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
                                        fontSize: 8 + 6 - 6 * topBarOpacity,
                                        letterSpacing: 1.2,
                                        color: AppTheme.grey,
                                      ),
                                    ),
                                  ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '24h',
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.w100,
                                        fontSize: 8 + 6 - 6 * topBarOpacity,
                                        letterSpacing: 1.2,
                                        color: AppTheme.grey,
                                      ),
                                    ),
                                    SizedBox(height: 3.0),
                                    Text(
                                      'N/A',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 8 + 6 - 6 * topBarOpacity,
                                        letterSpacing: 1.2,
                                        color: AppTheme.grey,
                                      ),
                                    ),
                                  ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '1w',
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.w100,
                                        fontSize: 8 + 6 - 6 * topBarOpacity,
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
                                        fontSize: 8 + 6 - 6 * topBarOpacity,
                                        letterSpacing: 1.2,
                                        color: AppTheme.grey,
                                      ),
                                    ),
                                  ]),
                            ),
                            InkWell(
                              onTap: () async {
                                userConfiguration =
                                    await UserConfiguration.getConfiguration();
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Text("Actions...",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            Divider(),
                                            Ink(
                                              width: 300,
                                              child: InkWell(
                                                onTap: () async {
                                                  Navigator.pop(context);
                                                  userConfiguration!
                                                          .calculateProfitability =
                                                      !userConfiguration!
                                                          .calculateProfitability;
                                                  await userConfiguration!
                                                      .save();
                                                  widget.refreshHomeScreen();
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: userConfiguration!
                                                          .calculateProfitability
                                                      ? Text(
                                                          "Turn OFF profitability")
                                                      : Text(
                                                          "Turn ON profitability"),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 3.0),
                                child: Icon(Icons.more_vert),
                              ),
                            )
                          ])
                        ],
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            InkWell(
                              highlightColor: Colors.transparent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      "More details",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                        color: AppTheme.nearlyDarkBlue,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 38,
                                      width: 24,
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: AppTheme.darkText,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ])
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
