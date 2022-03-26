import 'dart:convert';

import 'package:crypto_manager/widgets/binance_qr_view.dart';
import 'package:flutter/material.dart';

class AccountQrCodeScreen extends StatefulWidget {
  const AccountQrCodeScreen({Key? key, required this.advanceStep})
      : super(key: key);

  final advanceStep;

  @override
  State<StatefulWidget> createState() => _AccountQrCodeScreenState();
}

class _AccountQrCodeScreenState extends State<AccountQrCodeScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BinanceQRView(scanCallback: (scanResult) {
      var decodedResult = jsonDecode(scanResult.code);
      widget.advanceStep(decodedResult["apiKey"], decodedResult["secretKey"],
          decodedResult["comment"]);
    });
  }
}
