import 'package:flutter/material.dart';

import '../app_theme.dart';

class CoinSelector extends StatefulWidget {
  List<String> availableCoins = [];
  final getAvailableCoins;
  final selectedCallback;

  CoinSelector(
      {Key? key,
      required this.availableCoins,
      this.getAvailableCoins,
      this.selectedCallback})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _coinSelectorState();
}

class _coinSelectorState extends State<CoinSelector> {
  List<String> filteredCoins = [];
  final TextEditingController _coinController = TextEditingController();

  @override
  void initState() {
    _coinController.addListener(() {
      filterCoins();
      setState(() {});
    });
    super.initState();
  }

  void filterCoins() {
    filteredCoins = widget.availableCoins;
    filteredCoins = widget.availableCoins.where((v) {
      return v.toLowerCase().contains(_coinController.text.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return coinSelector();
  }

  Widget coinSelector() {
    return Stack(
      children: [
        FutureBuilder(
            future: widget.getAvailableCoins(),
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.hasData) {
                widget.availableCoins = snapshot.data!;
                filterCoins();
                return Column(
                  children: [
                    TextField(
                      controller: _coinController,
                      decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: 18,
                            letterSpacing: 1.2,
                            color: AppTheme.inputHint,
                          )),
                    ),
                    Expanded(
                      child: Container(
                        width: double.maxFinite,
                        child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: filteredCoins.length,
                            separatorBuilder: (context, index) {
                              return Divider();
                            },
                            itemBuilder: (BuildContext context, int index) {
                              String coin = filteredCoins[index];
                              return ListTile(
                                  onTap: () {
                                    widget.selectedCallback(coin);
                                  },
                                  trailing: Icon(Icons.arrow_forward_ios_sharp,
                                      color: AppTheme.nearlyBlue),
                                  title: Text(
                                    coin,
                                    style: const TextStyle(
                                        color: AppTheme.nearlyBlack,
                                        fontSize: 15),
                                  ));
                            }),
                      ),
                    ),
                  ],
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            })
      ],
    );
  }
}
