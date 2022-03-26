import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto_manager/app_theme.dart';

class KucoinApiKeyScreen extends StatefulWidget {
  const KucoinApiKeyScreen({Key? key, required this.advanceStep})
      : super(key: key);

  final advanceStep;

  @override
  State<StatefulWidget> createState() => _KucoinApiKeyScreenState();
}

class _KucoinApiKeyScreenState extends State<KucoinApiKeyScreen>
    with TickerProviderStateMixin {
  final TextEditingController _secretController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _passphraseController = TextEditingController();
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
    _keyController.addListener(() {
      setState(() {});
    });
    _secretController.addListener(() {
      setState(() {});
    });
    _passphraseController.addListener(() {
      setState(() {});
    });
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
            elevation: 0,
            actions: [
              MaterialButton(
                onPressed: () {
                  widget.advanceStep(_keyController.text,
                      _secretController.text, _passphraseController.text);
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
              ClipboardData? cdata;
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
                              Container(
                                alignment: Alignment.center,
                                height: 120,
                                child: Column(
                                  children: [
                                    Text(
                                      "Add your Kucoin API and secret keys. These keys will be stored securely on your device.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        letterSpacing: 1.2,
                                        color: AppTheme.lightText,
                                      ),
                                    ),
                                    SizedBox(height: 25),
                                    RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          text: "How do I setup my API key?",
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              launch(
                                                  'https://support.kucoin.plus/hc/en-us/articles/360015102174-How-to-Create-an-API-');
                                            },
                                          style: TextStyle(
                                            fontFamily: AppTheme.fontName,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            letterSpacing: 1.2,
                                            color: AppTheme.nearlyDarkBlue,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              Text(
                                'API Key',
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
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: AppTheme.input,
                                ),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: TextField(
                                        controller: _keyController,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: BorderSide(
                                                  width: 0.0,
                                                  color: Colors.red),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: const BorderSide(
                                                  color: AppTheme.nearlyWhite,
                                                  width: 0.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: const BorderSide(
                                                  color: AppTheme.nearlyWhite,
                                                  width: 0.0),
                                            ),
                                            hintText: 'Enter a API Key',
                                            hintStyle: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontSize: 18,
                                              letterSpacing: 1.2,
                                              color: AppTheme.inputHint,
                                            ),
                                            suffixIcon: _keyController
                                                        .text.length >
                                                    0
                                                ? IconButton(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    splashColor:
                                                        Colors.transparent,
                                                    onPressed: () {
                                                      _keyController.clear();
                                                    },
                                                    icon: Icon(Icons.cancel,
                                                        color: Colors.grey))
                                                : null),
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(right: 20.0),
                                        child: InkWell(
                                            child: Text("Paste",
                                                style: TextStyle(
                                                  fontFamily: AppTheme.fontName,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  letterSpacing: 1.2,
                                                  color: AppTheme.lightText,
                                                )),
                                            onTap: () async {
                                              cdata = await Clipboard.getData(
                                                  Clipboard.kTextPlain);
                                              if (cdata != null &&
                                                  cdata!.text != null)
                                                _keyController.text =
                                                    cdata!.text!;
                                            }))
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              Text(
                                'Secret Key',
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
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: AppTheme.input,
                                ),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: TextField(
                                        controller: _secretController,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: BorderSide(
                                                  width: 0.0,
                                                  color: Colors.red),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: const BorderSide(
                                                  color: AppTheme.nearlyWhite,
                                                  width: 0.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: const BorderSide(
                                                  color: AppTheme.nearlyWhite,
                                                  width: 0.0),
                                            ),
                                            hintText: 'Enter a Secret Key',
                                            hintStyle: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontSize: 18,
                                              letterSpacing: 1.2,
                                              color: AppTheme.inputHint,
                                            ),
                                            suffixIcon: _secretController
                                                        .text.length >
                                                    0
                                                ? IconButton(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    splashColor:
                                                        Colors.transparent,
                                                    onPressed: () {
                                                      _secretController.clear();
                                                    },
                                                    icon: Icon(Icons.cancel,
                                                        color: Colors.grey))
                                                : null),
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(right: 20.0),
                                        child: InkWell(
                                            child: Text("Paste",
                                                style: TextStyle(
                                                  fontFamily: AppTheme.fontName,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  letterSpacing: 1.2,
                                                  color: AppTheme.lightText,
                                                )),
                                            onTap: () async {
                                              cdata = await Clipboard.getData(
                                                  Clipboard.kTextPlain);
                                              if (cdata != null &&
                                                  cdata!.text != null)
                                                _secretController.text =
                                                    cdata!.text!;
                                            }))
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              Text(
                                'Passphrase',
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
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: AppTheme.input,
                                ),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: TextField(
                                        controller: _passphraseController,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: BorderSide(
                                                  width: 0.0,
                                                  color: Colors.red),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: const BorderSide(
                                                  color: AppTheme.nearlyWhite,
                                                  width: 0.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: const BorderSide(
                                                  color: AppTheme.nearlyWhite,
                                                  width: 0.0),
                                            ),
                                            hintText: 'Enter passphrase',
                                            hintStyle: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontSize: 18,
                                              letterSpacing: 1.2,
                                              color: AppTheme.inputHint,
                                            ),
                                            suffixIcon: _passphraseController
                                                        .text.length >
                                                    0
                                                ? IconButton(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    splashColor:
                                                        Colors.transparent,
                                                    onPressed: () {
                                                      _passphraseController
                                                          .clear();
                                                    },
                                                    icon: Icon(Icons.cancel,
                                                        color: Colors.grey))
                                                : null),
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(right: 20.0),
                                        child: InkWell(
                                            child: Text("Paste",
                                                style: TextStyle(
                                                  fontFamily: AppTheme.fontName,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  letterSpacing: 1.2,
                                                  color: AppTheme.lightText,
                                                )),
                                            onTap: () async {
                                              cdata = await Clipboard.getData(
                                                  Clipboard.kTextPlain);
                                              if (cdata != null &&
                                                  cdata!.text != null)
                                                _passphraseController.text =
                                                    cdata!.text!;
                                            }))
                                  ],
                                ),
                              )
                            ]),
                      )));
            }));
  }
}
