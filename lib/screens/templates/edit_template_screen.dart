import 'package:crypto_manager/models/template.dart';
import 'package:crypto_manager/models/template_item.dart';
import 'package:crypto_manager/services/binance.dart';
import 'package:crypto_manager/widgets/coin_selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:crypto_manager/app_theme.dart';

class EditTemplateScreen extends StatefulWidget {
  EditTemplateScreen(
      {Key? key, required this.template, required this.didSaveTemplate})
      : super(key: key);

  final didSaveTemplate;
  static const valueKey = ValueKey('EditTemplateScreen');

  late Template template;

  @override
  State<StatefulWidget> createState() => _EditTemplateScreenState();
}

class _EditTemplateScreenState extends State<EditTemplateScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late AnimationController animationController;
  Animation<double>? animation;
  //List<TemplateItem> templateItems = [TemplateItem(-1, "USDT", 1.0)];
  //List<TemplateItem> templateItems = [];
  List<String> coinsAvailable = [];

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
    _nameController.text = widget.template.name;
    super.initState();
  }

  Future<List<String>> buildAvailableCoins() async {
    if (coinsAvailable.isEmpty) {
      Map<String, dynamic> exchangeInfo = await Binance(null).exchangeInfo();
      List<dynamic> symbols = exchangeInfo["symbols"];
      Map<String, String> uniqueMap = {};
      symbols.forEach((v) => {
            if (!v.toString().contains("UP") && !v.toString().contains("DOWN"))
              {uniqueMap[v["baseAsset"].toString()] = v["baseAsset"].toString()}
          });
      coinsAvailable = uniqueMap.keys.toList();
      coinsAvailable.sort((a, b) => a.compareTo(b));
    }
    return coinsAvailable;
  }

  void addTemplateItem(TemplateItem templateItem) {
    setState(() {
      if (widget.template.items
          .where((e) => e.coin == templateItem.coin)
          .isEmpty) {
        widget.template.items.add(templateItem);
      }
    });
  }

  double calculateFreeWeight([double? weight]) {
    double accumWeight =
        widget.template.items.fold(0.00, (a, b) => (a as double) + b.weight);
    if (weight != null) {
      accumWeight -= weight;
    }
    return double.parse((1.00 - accumWeight).toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    widget.template.items.sort((a, b) => -a.weight.compareTo(b.weight));
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
                widget.template.name = _nameController.text;
                await widget.template.save();
                Navigator.pop(context);
                widget.didSaveTemplate();
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            SizedBox(
                                height: MediaQuery.of(context).padding.top),
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
                                  hintText: 'Enter a name for your template',
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
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Items',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    letterSpacing: 1.2,
                                    color: AppTheme.darkerText,
                                  ),
                                ),
                                Text(
                                  "Free: ${NumberFormat("#,##0.00%", "en_US").format(calculateFreeWeight())}",
                                  style: const TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.grey),
                                )
                              ],
                            ),
                            Expanded(
                              flex: 1,
                              child: widget.template.items.isEmpty
                                  ? Align(
                                      alignment: Alignment.center,
                                      child: Center(
                                        child: Container(
                                            child: const Text(
                                              "There are no coins added to your template.",
                                              textAlign: TextAlign.center,
                                            ),
                                            width: 200),
                                      ))
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: widget.template.items.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        TemplateItem templateItem =
                                            widget.template.items[index];
                                        return ListTile(
                                            onTap: () {
                                              openTemplateItemCreator(
                                                  context, templateItem);
                                            },
                                            trailing: Text(
                                              NumberFormat("#,##0.00%", "en_US")
                                                  .format(templateItem.weight),
                                              style: TextStyle(
                                                  fontFamily: AppTheme.fontName,
                                                  color: AppTheme.nearlyBlack,
                                                  fontSize: 15),
                                            ),
                                            title: Text(
                                              templateItem.coin!,
                                              style: TextStyle(
                                                  fontFamily: AppTheme.fontName,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.grey),
                                            ));
                                      }),
                            ),
                          ]),
                    )));
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: calculateFreeWeight() > 0.0
            ? () {
                openTemplateItemCreator(
                    context, TemplateItem(-1, widget.template.id, null));
              }
            : null,
        backgroundColor:
            calculateFreeWeight() > 0.0 ? AppTheme.nearlyBlue : Colors.grey,
      ),
    );
  }

  TemplateItem? findTemplateItem(String coin) {
    List<TemplateItem> filteredTemplateItems = widget.template.items
        .where((e) => e.coin != null && e.coin == coin)
        .toList();
    if (filteredTemplateItems.isNotEmpty) {
      return filteredTemplateItems.first;
    }
  }

  Future<dynamic> openTemplateItemCreator(
      BuildContext context, TemplateItem templateItem) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return templateItemCreator(
              templateItem: templateItem,
              coinsAvailable: coinsAvailable,
              buildAvailableCoins: buildAvailableCoins,
              addTemplateItem: addTemplateItem,
              findTemplateItem: findTemplateItem,
              calculateFreeWeight: calculateFreeWeight);
        });
  }
}

class templateItemCreator extends StatefulWidget {
  List<String> coinsAvailable = [];
  TemplateItem templateItem;
  final buildAvailableCoins;
  final addTemplateItem;
  final findTemplateItem;
  final calculateFreeWeight;

  templateItemCreator(
      {Key? key,
      required this.templateItem,
      required this.coinsAvailable,
      this.buildAvailableCoins,
      this.addTemplateItem,
      this.findTemplateItem,
      this.calculateFreeWeight})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _templateItemCreatorState();
}

class _templateItemCreatorState extends State<templateItemCreator> {
  List<String> filteredCoins = [];
  final TextEditingController _coinController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  bool submitDisabled = false;
  double freeWeight = 0.0;
  @override
  void initState() {
    _coinController.addListener(() {
      filterCoins();
      setState(() {});
    });
    _weightController.addListener(() {
      setState(() {});
    });
    freeWeight = widget.calculateFreeWeight(widget.templateItem.weight);
    if (widget.templateItem.coin != null) {
      _weightController.text = (widget.templateItem.weight * 100).toString();
    }
    super.initState();
  }

  void filterCoins() {
    filteredCoins = widget.coinsAvailable;
    filteredCoins = widget.coinsAvailable.where((v) {
      return v.toLowerCase().contains(_coinController.text.toLowerCase());
    }).toList();
  }

  double getCurrentWeight() {
    double currentWeight = 0.0;
    try {
      currentWeight = double.parse(_weightController.text) / 100.0;
    } catch (e) {}

    return currentWeight;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.templateItem.coin != null) {
      return weightSetter(context);
    } else {
      return AlertDialog(
          content: CoinSelector(
        availableCoins: widget.coinsAvailable,
        getAvailableCoins: widget.buildAvailableCoins,
        selectedCallback: (coin) {
          TemplateItem? _conflictingTemplateItem =
              widget.findTemplateItem(coin);
          if (_conflictingTemplateItem != null) {
            widget.templateItem = _conflictingTemplateItem;
          } else {
            widget.templateItem.coin = coin;
          }
          freeWeight = widget.calculateFreeWeight(widget.templateItem.weight);
          _weightController.text =
              (widget.templateItem.weight * 100.0).toString();
        },
      ));
    }
  }

  Widget weightSetter(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                      "Free: ${((freeWeight - getCurrentWeight()) * 100.0).toStringAsFixed(2)}%",
                      style: TextStyle(fontFamily: AppTheme.fontName))
                ],
              ),
              SizedBox(height: 30),
              Text(widget.templateItem.coin!,
                  style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontSize: 30,
                      fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    height: 50.0,
                    child: SizedBox.fromSize(
                      size: Size(50, 50), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Color.fromRGBO(0, 160, 227, 1), // button color
                          child: InkWell(
                            splashColor: Colors.transparent,
                            // splash color
                            onTap: () {
                              double weight =
                                  double.parse(_weightController.text) - 1.0;
                              if (weight < 0) weight = 0.0;
                              _weightController.text = weight.toString();
                              setState(() {
                                if (weight == 0.0) submitDisabled = true;
                              });
                            },
                            // button pressed
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                ), // text
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    alignment: Alignment.center,
                    height: 100,
                    child: TextField(
                        controller: _weightController,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 30),
                        keyboardType: TextInputType.number),
                  )),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.all(10),
                    height: 50.0,
                    child: SizedBox.fromSize(
                      size: Size(50, 50), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Color.fromRGBO(0, 160, 227, 1), // button color
                          child: InkWell(
                            splashColor: Colors.transparent,
                            // splash color
                            onTap: () {
                              double weight =
                                  double.parse(_weightController.text) + 1.0;
                              if (weight > freeWeight * 100)
                                weight = freeWeight * 100;
                              _weightController.text = weight.toString();
                              setState(() {
                                submitDisabled = false;
                              });
                            },
                            // button pressed
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ), // text
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Wrap(
                children: [
                  MaterialButton(
                    onPressed: (freeWeight >= 0.05)
                        ? () {
                            _weightController.text = "5.0";
                          }
                        : null,
                    child: Text("5%"),
                  ),
                  MaterialButton(
                    onPressed: (freeWeight >= 0.1)
                        ? () {
                            _weightController.text = "10.0";
                          }
                        : null,
                    child: Text("10%"),
                  ),
                  MaterialButton(
                    onPressed: (freeWeight >= 0.25)
                        ? () {
                            _weightController.text = "25.0";
                          }
                        : null,
                    child: Text("25%"),
                  ),
                  MaterialButton(
                    onPressed: (freeWeight >= 0.5)
                        ? () {
                            _weightController.text = "50.0";
                          }
                        : null,
                    child: Text("50%"),
                  ),
                  MaterialButton(
                    onPressed: (freeWeight >= 0.75)
                        ? () {
                            _weightController.text = "75.0";
                          }
                        : null,
                    child: Text("75%"),
                  ),
                  MaterialButton(
                    onPressed: (freeWeight >= 0.9)
                        ? () {
                            _weightController.text = "90.0";
                          }
                        : null,
                    child: Text("90%"),
                  ),
                  MaterialButton(
                    onPressed: (freeWeight >= 0.95)
                        ? () {
                            _weightController.text = "95.0";
                          }
                        : null,
                    child: Text("95%"),
                  ),
                  MaterialButton(
                    onPressed: (freeWeight == 1)
                        ? () {
                            _weightController.text = "100.0";
                          }
                        : null,
                    child: Text("100%"),
                  ),
                  MaterialButton(
                    onPressed: () {
                      _weightController.text = (freeWeight * 100.0).toString();
                    },
                    child: Text("Max"),
                  )
                ],
              ),
              ElevatedButton(
                onPressed: getCurrentWeight() > 0.0
                    ? () {
                        widget.templateItem.weight =
                            double.parse(_weightController.text) / 100.0;
                        Navigator.pop(context);
                        widget.addTemplateItem(widget.templateItem);
                      }
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('OK', style: TextStyle(fontSize: 15)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget coinSelector() {
    return AlertDialog(
      content: Stack(
        children: [
          FutureBuilder(
              future: widget.buildAvailableCoins(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.hasData) {
                  widget.coinsAvailable = snapshot.data!;
                  filterCoins();
                  return Column(
                    children: [
                      TextField(
                        controller: _coinController,
                      ),
                      Expanded(
                        child: Container(
                          width: double.maxFinite,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredCoins.length,
                              itemBuilder: (BuildContext context, int index) {
                                String coin = filteredCoins[index];
                                return ListTile(
                                    onTap: () {
                                      TemplateItem? _conflictingTemplateItem =
                                          widget.findTemplateItem(coin);
                                      if (_conflictingTemplateItem != null)
                                        widget.templateItem =
                                            _conflictingTemplateItem;
                                      else
                                        widget.templateItem.coin = coin;
                                      freeWeight = widget.calculateFreeWeight(
                                          widget.templateItem.weight);
                                      _weightController.text =
                                          (widget.templateItem.weight * 100.0)
                                              .toString();
                                    },
                                    leading:
                                        Icon(Icons.arrow_forward_ios_sharp),
                                    title: Text(
                                      coin,
                                      style: const TextStyle(
                                          color: Colors.green, fontSize: 15),
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
      ),
    );
  }
}
