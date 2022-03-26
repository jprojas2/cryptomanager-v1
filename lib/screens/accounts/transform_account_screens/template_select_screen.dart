import 'package:crypto_manager/app_theme.dart';
import 'package:crypto_manager/models/account.dart';
import 'package:crypto_manager/models/template.dart';
import 'package:crypto_manager/models/template_item.dart';
import 'package:crypto_manager/services/transformer.dart';
import 'package:crypto_manager/widgets/transform_confirm_dialog.dart';
import 'package:flutter/material.dart';

class TemplateSelectScreen extends StatelessWidget {
  final transformConfirmCallback;
  Account account;
  final ctx;
  TemplateSelectScreen(
      {Key? key,
      required this.account,
      this.transformConfirmCallback,
      this.ctx})
      : super(key: key);

  List<Template> templates = [];

  get cashTemplate => null;

  Future<bool> getTemplates() async {
    templates = await Template.allWithItems();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: getTemplates(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              } else if (templates.isEmpty) {
                return Align(
                    alignment: Alignment.center,
                    child: Center(
                      child: Container(
                          child: const Text(
                            "There are no templates created. Go to the \"Templates\" tab in the home screen to add one.",
                            textAlign: TextAlign.center,
                          ),
                          width: 200),
                    ));
              } else {
                return ListView.separated(
                    shrinkWrap: true,
                    itemCount: templates.length,
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemBuilder: (BuildContext context, int index) {
                      Template template = templates[index];
                      return ListTile(
                          onTap: () {
                            portfolioToTemplateConfirm(
                                context, account, template);
                          },
                          trailing: Icon(Icons.arrow_forward_ios_sharp,
                              color: AppTheme.nearlyBlue),
                          title: Text(
                            template.name,
                            style: const TextStyle(
                                color: AppTheme.nearlyBlack, fontSize: 15),
                          ));
                    });
              }
            }));
  }

  Future<dynamic> portfolioToTemplateConfirm(
      BuildContext context, Account account, Template template) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return TransformConfirmDialog(
            getFees: () async {
              await account.transform(template, true);
              return account.transformationFees();
            },
            confirmCallback: () async {
              Navigator.pop(context);
              await transformConfirmCallback(account, template);
            },
          );
        });
  }
}
