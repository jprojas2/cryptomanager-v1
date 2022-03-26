import 'package:crypto_manager/models/account.dart';
import 'package:crypto_manager/widgets/account_type_card.dart';

import '../../../app_theme.dart';
import 'package:flutter/material.dart';

class AccountTypeScreen extends StatefulWidget {
  AccountTypeScreen(
      {Key? key, required this.newAccount, required this.accountTypeSelected})
      : super(key: key);

  late Account newAccount;
  final accountTypeSelected;

  static const valueKey = ValueKey('NewAccountScreen');

  @override
  _AccountTypeScreenState createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late AnimationController animationController;
  Animation<double>? topBarAnimation;

  List<Widget> accountTypeListViews = <Widget>[];

  @override
  void initState() {
    // TODO: implement initState
    //_keyController.addListener(() {
    //  setState(() {});
    //});
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    initAccountTypeListView();
    accountTypeListViews.add(SizedBox());
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void setAccountType(accountType) {
    setState(() {
      print("SET ACCOUNT TYPE TO ${accountType}");
      widget.newAccount.type = accountType;
    });
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  void initAccountTypeListView() {
    accountTypeListViews.add(AccountTypeCard(
      icon: "binance-logo.png",
      name: "Binance",
      animationController: animationController,
      animation: topBarAnimation,
      accountType: 1,
      setAccountType: widget.accountTypeSelected,
    ));
    accountTypeListViews.add(AccountTypeCard(
      icon: "kucoin-logo.png",
      name: "Kucoin",
      animationController: animationController,
      animation: topBarAnimation,
      opacity: 0.75,
      setAccountType: widget.accountTypeSelected,
      accountType: 2,
    ));
    accountTypeListViews.add(AccountTypeCard(
      icon: "portfolio-icon.png",
      name: "Virtual",
      animationController: animationController,
      animation: topBarAnimation,
      opacity: 0.75,
      setAccountType: widget.accountTypeSelected,
      accountType: 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: AccountTypeView());
  }

  Widget AccountTypeView() {
    //return builder(context);
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 100,
          child: Text("Select account type",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 1.2,
                color: AppTheme.lightText,
              )),
        ),
        FutureBuilder<bool>(
            future: getData(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              } else {
                return OrientationBuilder(builder: (context, orientation) {
                  return Padding(
                      padding: EdgeInsets.only(
                          top: 0,
                          bottom: 62 + MediaQuery.of(context).padding.bottom,
                          left: 16,
                          right: 16),
                      child: GridView.builder(
                        controller: scrollController,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                (orientation == Orientation.portrait) ? 2 : 3,
                            childAspectRatio: 1,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12),
                        scrollDirection: Axis.vertical,
                        itemCount: accountTypeListViews.length,
                        itemBuilder: (BuildContext context, int index) {
                          animationController.forward();
                          return accountTypeListViews[index];
                        },
                      ));
                });
              }
            })
      ],
    );
  }
}
