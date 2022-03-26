import 'package:crypto_manager/models/account.dart';
import 'package:crypto_manager/app_theme.dart';
import 'package:crypto_manager/models/template.dart';
import 'package:crypto_manager/screens/accounts/transform_account_screens/template_review_screen.dart';
import 'package:crypto_manager/screens/accounts/transform_account_screens/template_select_screen.dart';

import 'package:flutter/material.dart';

import 'account_screen.dart';

class TransformAccountNavigator extends StatelessWidget {
  Account account;
  final accountTransformationConfirmed;
  TransformAccountNavigator(
      {Key? key, required this.account, this.accountTransformationConfirmed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final childBackButtonDispatcher =
        ChildBackButtonDispatcher(Router.of(context).backButtonDispatcher!);
    childBackButtonDispatcher.takePriority();
    return Router(
      routerDelegate: TransformAccountRouterDelegate(
          account, context, accountTransformationConfirmed),
      backButtonDispatcher: childBackButtonDispatcher,
    );
  }
}

final GlobalKey<NavigatorState> _nestedNavigatorKey =
    GlobalKey<NavigatorState>();

class TransformAccountRouterDelegate extends RouterDelegate
    with ChangeNotifier {
  Account account;
  final ctx;
  Template? template;
  final accountTransformationConfirmed;
  TransformAccountRouterDelegate(
      this.account, this.ctx, this.accountTransformationConfirmed)
      : super();

  @override
  Future<bool> popRoute() async {
    print('popRoute NestedRouterDelegate');
    Navigator.pop(ctx);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: template == null
          ? AppBar(
              iconTheme: IconThemeData(
                color: AppTheme.nearlyBlack,
              ),
              titleTextStyle: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.w700,
                fontSize: 15 + 6,
                letterSpacing: 1.2,
                color: AppTheme.darkerText,
              ),
              title: Text("Select template..."),
              backgroundColor: AppTheme.nearlyWhite,
              elevation: 0,
            )
          : null,
      body: Navigator(
        key: _nestedNavigatorKey,
        observers: [HeroController()],
        pages: [
          MaterialPage(
              child: TemplateSelectScreen(
            account: account,
            transformConfirmCallback: (account, template) {
              Navigator.pop(context);
              accountTransformationConfirmed(account, template);
            },
            ctx: ctx,
          )),
          if (template != null)
            MaterialPage(
                child: TemplateReviewScreen(
              template: template!,
            ))
        ],
        onPopPage: (route, result) {
          return false;
        },
      ),
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) async => null;
}
