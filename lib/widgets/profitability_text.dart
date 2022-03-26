import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';

Widget ProfitabilityText(double? profitability, [double? fontSize]) {
  Widget? icon = null;
  Color? color = null;
  double defaultFontSize = 15.0;
  if (profitability == null)
    return Text("N/A",
        style: TextStyle(
            color: AppTheme.grey,
            fontSize: fontSize != null ? fontSize : defaultFontSize));
  if (profitability > 0.0) {
    color = Colors.lightGreen;
    icon = Icon(
      Icons.arrow_upward,
      color: color,
      size: fontSize != null ? fontSize - 1 : defaultFontSize - 1,
    );
  } else if (profitability < 0.0) {
    color = Colors.red;
    icon = Icon(
      Icons.arrow_downward,
      color: color,
      size: fontSize != null ? fontSize - 1 : defaultFontSize - 1,
    );
  } else {
    color = AppTheme.grey;
    icon = SizedBox();
    Text("—",
        style: TextStyle(
            color: color,
            fontSize: fontSize != null ? fontSize : defaultFontSize));
  }
  return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    icon,
    Text(NumberFormat("#,##0.0%", "en_US").format(profitability),
        textAlign: TextAlign.right,
        style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontSize: fontSize != null ? fontSize : defaultFontSize))
  ]);
}
