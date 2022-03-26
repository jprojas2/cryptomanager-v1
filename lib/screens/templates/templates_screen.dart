import 'package:crypto_manager/models/template.dart';
import 'package:crypto_manager/screens/templates/edit_template_screen.dart';
import 'package:crypto_manager/services/price_finder.dart';
import 'package:crypto_manager/widgets/action_menu_dialog.dart';
import 'package:crypto_manager/widgets/profitability_text.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:crypto_manager/app_theme.dart';

class TemplatesScreen extends StatefulWidget {
  final didOpenTemplateScreen;
  final getData;
  final refreshHomeScreen;
  bool updatedData = false;
  List<Template> templates = [];

  TemplatesScreen(
      {Key? key,
      required this.templates,
      this.getData,
      required this.updatedData,
      this.didOpenTemplateScreen,
      this.refreshHomeScreen})
      : super(key: key);

  @override
  _TemplatesScreenState createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  Widget TemplateList() {
    TextStyle cellStyle = TextStyle(fontFamily: AppTheme.fontName);
    Widget bodyContent = SizedBox();
    if (widget.templates.isEmpty) {
      bodyContent = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          DataTable(columnSpacing: 0, columns: TableHeader(), rows: []),
          Expanded(
            child: Align(
                alignment: Alignment.center,
                child: Center(
                  child: Container(
                      child: const Text(
                        "There are no templates available. Add one using the floating button below.",
                        textAlign: TextAlign.center,
                      ),
                      width: 200),
                )),
          )
        ],
      );
    } else {
      bodyContent = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          DataTable(
              columnSpacing: 0,
              showCheckboxColumn: false,
              columns: TableHeader(),
              rows: widget.templates.map<DataRow>((v) {
                return DataRow(
                    onSelectChanged: (bool? selected) {
                      if (selected != null && selected) {
                        widget.didOpenTemplateScreen(v);
                      }
                    },
                    onLongPress: () {
                      var ctx = context;
                      showDialog(
                          context: context,
                          builder: (context) {
                            return ActionMenuDialog(context, editCallback: () {
                              Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                      builder: (context) => EditTemplateScreen(
                                          template: v,
                                          didSaveTemplate: () {
                                            Navigator.pop(ctx);
                                            widget.refreshHomeScreen();
                                          })));
                            }, deleteCallback: () async {
                              await v.delete();
                              widget.refreshHomeScreen();
                            });
                          });
                    },
                    cells: [
                      DataCell(Align(
                          alignment: Alignment.centerLeft,
                          child: Text(v.name, style: cellStyle))),
                      DataCell(Align(
                          alignment: Alignment.centerRight,
                          child: ProfitabilityText(v.profitability("1h")))),
                      DataCell(Align(
                          alignment: Alignment.centerRight,
                          child: ProfitabilityText(v.profitability("24h"))))
                    ]);
              }).toList()),
          if (widget.templates.isEmpty)
            Expanded(
              flex: 1,
              child: Align(
                  alignment: Alignment.center,
                  child: Center(
                    child: Container(
                        child: const Text(
                          "There are no templates available. Add one using the floating button below.",
                          textAlign: TextAlign.center,
                        ),
                        width: 200),
                  )),
            )
        ],
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: bodyContent,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditTemplateScreen(
                        template: Template(-1, ""),
                        didSaveTemplate: () {
                          Navigator.pop(context);
                          widget.refreshHomeScreen();
                        },
                      )));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.updatedData) {
      return TemplateList();
    }
    return FutureBuilder<List<Template>>(
        future: widget.getData(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Template>> snapshot) {
          if (snapshot.hasData) {
            widget.templates = snapshot.data!;
            return TemplateList();
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                DataTable(columnSpacing: 0, columns: TableHeader(), rows: []),
                Expanded(child: Center(child: CircularProgressIndicator()))
              ],
            );
          }
        });
  }

  List<DataColumn> TableHeader() {
    var spacing = 2.0;
    return [
      DataColumn(
          label: Expanded(
              child: Text("NAME",
                  style: TextStyle(
                      fontFamily: AppTheme.fontName, letterSpacing: spacing)))),
      DataColumn(
          label: Expanded(
              child: Text("1h",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontFamily: AppTheme.fontName, letterSpacing: spacing)))),
      DataColumn(
          label: Expanded(
              child: Text("24h",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontFamily: AppTheme.fontName, letterSpacing: spacing))))
    ];
  }
}
