import '../app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountTypeCard extends StatefulWidget {
  final String icon;
  final String name;
  final double opacity;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final accountType;
  final setAccountType;

  const AccountTypeCard(
      {Key? key,
        required this.icon,
        required this.name,
        this.animationController,
        this.animation,
        this.opacity = 1.0,
        this.accountType = -1,
        this.setAccountType
      })
      : super(key: key);

  @override
  State<StatefulWidget> createState(){
    return _AccountTypeCardState();
  }
}

class _AccountTypeCardState extends State<AccountTypeCard>{
  @override
  Widget build(BuildContext context) {
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
                      boxShadow: [BoxShadow(color: Colors.grey)]
                    ),
                    child: InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      onTap: () {
                        widget.setAccountType(widget.accountType);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 10),
                          Opacity(opacity: widget.opacity,
                              child: Image.asset("assets/images/${widget.icon}", width: 50)
                          ),
                          SizedBox(height: 10),
                          Text(
                            widget.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                letterSpacing: -0.1,
                                color: AppTheme.darkText),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
          ),
        );
      },
    );
  }
}
