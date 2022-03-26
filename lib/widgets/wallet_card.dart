import 'package:crypto_manager/models/account.dart';
import 'package:crypto_manager/widgets/action_menu_dialog.dart';
import 'package:crypto_manager/widgets/profitability_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import '../app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class WalletCard extends StatefulWidget {
  final Account account;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final openAccount;
  final deleteAccount;
  final ctx;

  const WalletCard(
      {Key? key,
      required this.account,
      this.animationController,
      this.animation,
      this.openAccount,
      this.deleteAccount,
      this.ctx})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WalletCardState();
  }
}

class _WalletCardState extends State<WalletCard> {
  @override
  Widget build(BuildContext context) {
    String type = "";
    String logo = "";
    switch (widget.account.type) {
      case 0:
        type = "Virtual";
        logo = "assets/images/portfolio-icon.png";
        break;
      case 1:
        type = "Binance";
        logo = "assets/images/binance-logo.png";
        break;
      case 2:
        type = "Kucoin";
        logo = "assets/images/kucoin-logo.png";
        break;
    }
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
              transform: Matrix4.translationValues(
                  0.0, 30 * (1.0 - widget.animation!.value), 0.0),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 0, right: 0, top: 16, bottom: 4),
                child: Material(
                  child: Ink(
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: AppTheme.grey.withOpacity(0.2),
                            offset: Offset(1.1, 1.1),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      onTap: () {
                        widget.openAccount(widget.account);
                      },
                      onLongPress: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return ActionMenuDialog(context,
                                  deleteCallback: () async {
                                await widget.deleteAccount(widget.account);
                              });
                            });
                      },
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16, left: 16, right: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 4, bottom: 8, top: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.account.name != null
                                            ? widget.account.name
                                            : "No name",
                                        style: const TextStyle(
                                            fontFamily: AppTheme.fontName,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            letterSpacing: -0.1,
                                            color: AppTheme.darkText),
                                      ),
                                      Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              type,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontFamily: AppTheme.fontName,
                                                  fontSize: 13,
                                                  letterSpacing: -0.1,
                                                  color: AppTheme.darkText),
                                            ),
                                            SizedBox(width: 7),
                                            Image.asset(logo, width: 20),
                                          ]),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 4, bottom: 3),
                                          child: Text(
                                            NumberFormat("\$#,##0.00", "en_US")
                                                .format(widget.account
                                                    .valorizedTotal()),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 27,
                                              color: AppTheme.nearlyDarkBlue,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 5, bottom: 8),
                                          child: Text(
                                            'USDT',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                              letterSpacing: -0.2,
                                              color: AppTheme.nearlyDarkBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                '1w',
                                                style: TextStyle(
                                                  fontFamily: AppTheme.fontName,
                                                  fontWeight: FontWeight.w100,
                                                  fontSize: 14,
                                                  letterSpacing: 1.2,
                                                  color: AppTheme.darkerText,
                                                ),
                                              ),
                                              SizedBox(height: 3.0),
                                              ProfitabilityText(widget.account
                                                  .profitability("1w")),
                                            ]),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                '24h',
                                                style: TextStyle(
                                                  fontFamily: AppTheme.fontName,
                                                  fontWeight: FontWeight.w100,
                                                  fontSize: 14,
                                                  letterSpacing: 1.2,
                                                  color: AppTheme.darkerText,
                                                ),
                                              ),
                                              SizedBox(height: 3.0),
                                              ProfitabilityText(widget.account
                                                  .profitability("24h")),
                                            ]),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                '1h',
                                                style: TextStyle(
                                                  fontFamily: AppTheme.fontName,
                                                  fontWeight: FontWeight.w100,
                                                  fontSize: 14,
                                                  letterSpacing: 1.2,
                                                  color: AppTheme.darkerText,
                                                ),
                                              ),
                                              SizedBox(height: 3.0),
                                              ProfitabilityText(widget.account
                                                  .profitability("1h")),
                                            ]),
                                      )
                                    ])
                                  ],
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 24, right: 24, top: 8, bottom: 8),
                            child: Container(
                              height: 2,
                              decoration: const BoxDecoration(
                                color: AppTheme.background,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 24, right: 24, top: 8, bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(
                                  height: 40,
                                  width: 130,
                                  child: Material(
                                      child: Ink(
                                          decoration: BoxDecoration(
                                              color: AppTheme.nearlyBlue,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4.0)),
                                              boxShadow: <BoxShadow>[
                                                BoxShadow(
                                                    color: AppTheme.grey
                                                        .withOpacity(0.2),
                                                    offset: Offset(1.1, 1.1),
                                                    blurRadius: 10.0)
                                              ]),
                                          child: InkWell(
                                            onTap: () {
                                              widget.deleteAccount(
                                                  widget.account);
                                            },
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text("Manage",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppTheme.fontName,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 14,
                                                        letterSpacing: 1.2,
                                                        color: AppTheme
                                                            .nearlyWhite,
                                                      ))
                                                ]),
                                          ))),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        );
      },
    );
  }
}
