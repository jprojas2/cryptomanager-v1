import 'package:crypto_manager/models/account.dart';
import 'package:flutter/material.dart';

import '../../../app_theme.dart';

class AccountDetailsScreen extends StatefulWidget {
  AccountDetailsScreen(
      {Key? key, required this.account, required this.advanceStep})
      : super(key: key);

  final advanceStep;
  final Account account;

  @override
  State<StatefulWidget> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late AnimationController animationController;
  Animation<double>? animation;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController,
        curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    animationController.forward();
    _nameController.addListener(() {
      setState(() {});
    });
    _nameController.text = widget.account.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(
              color: AppTheme.nearlyBlack,
            ),
            backgroundColor: AppTheme.nearlyWhite,
            titleTextStyle: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.w700,
              fontSize: 15 + 6,
              letterSpacing: 1.2,
              color: AppTheme.darkerText,
            ),
            elevation: 0,
            actions: [
              MaterialButton(
                onPressed: () async {
                  await widget.advanceStep(_nameController.text);
                },
                child: const Text('OK',
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontWeight: FontWeight.w700,
                      fontSize: 15 + 6,
                      letterSpacing: 1.2,
                      color: AppTheme.nearlyDarkBlue,
                    )),
              )
            ]),
        body: AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget? child) {
              return FadeTransition(
                  opacity: animation!,
                  child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 30 * (1.0 - animation!.value), 0.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                  height: MediaQuery.of(context).padding.top),
                              Text(
                                'Name',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontName,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  letterSpacing: 1.2,
                                  color: AppTheme.darkerText,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                decoration: new BoxDecoration(
                                    color: AppTheme.input,
                                    borderRadius: BorderRadius.circular(10)),
                                child: TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                          width: 0.0, color: Colors.red),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                          color: AppTheme.nearlyWhite,
                                          width: 0.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                          color: AppTheme.nearlyWhite,
                                          width: 0.0),
                                    ),
                                    hintText: 'Enter a name for your account',
                                    hintStyle: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontSize: 18,
                                      letterSpacing: 1.2,
                                      color: AppTheme.inputHint,
                                    ),
                                    fillColor: AppTheme.input,
                                    suffixIcon: _nameController.text.length > 0
                                        ? IconButton(
                                            padding: const EdgeInsets.all(0.0),
                                            splashColor: Colors.transparent,
                                            onPressed: () {
                                              _nameController.clear();
                                            },
                                            icon: Icon(Icons.cancel,
                                                color: Colors.grey))
                                        : null,
                                  ),
                                ),
                              ),
                            ]),
                      )));
            }));
  }
}
