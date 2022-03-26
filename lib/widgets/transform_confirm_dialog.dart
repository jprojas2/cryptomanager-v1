import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';

class TransformConfirmDialog extends StatelessWidget {
  final getFees;
  final confirmCallback;

  TransformConfirmDialog(
      {Key? key, required this.getFees, required this.confirmCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Padding(
      padding: const EdgeInsets.all(10.0),
      child: FutureBuilder(
          future: getFees(),
          builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
            if (!snapshot.hasData)
              return Column(
                  children: [CircularProgressIndicator()],
                  mainAxisSize: MainAxisSize.min);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "The operation will cost approximately",
                  style: TextStyle(color: AppTheme.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "\$",
                      style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppTheme.fontName),
                    ),
                    Text(
                      NumberFormat("#,##0.00", "en_US").format(snapshot.data),
                      style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppTheme.fontName),
                    ),
                    SizedBox(width: 20)
                  ],
                ),
                SizedBox(height: 10),
                Text("in Binance fees", style: TextStyle(color: AppTheme.grey)),
                SizedBox(
                  height: 25,
                ),
                Material(
                    child: Ink(
                        decoration: BoxDecoration(
                            color: AppTheme.nearlyBlue,
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: AppTheme.grey.withOpacity(0.2),
                                  offset: Offset(1.1, 1.1),
                                  blurRadius: 10.0)
                            ]),
                        child: InkWell(
                          onTap: confirmCallback,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text("Confirm",
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 20,
                                        letterSpacing: 1.2,
                                        color: AppTheme.nearlyWhite,
                                      ))
                                ]),
                          ),
                        ))),
                SizedBox(
                  height: 10,
                ),
                Material(
                    child: Ink(
                        decoration: BoxDecoration(
                            color: AppTheme.nearlyWhite,
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: AppTheme.grey.withOpacity(0.2),
                                  offset: Offset(1.1, 1.1),
                                  blurRadius: 10.0)
                            ]),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text("Cancel",
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 20,
                                        letterSpacing: 1.2,
                                        color: AppTheme.nearlyBlack,
                                      ))
                                ]),
                          ),
                        )))
              ],
            );
          }),
    ));
  }
}
