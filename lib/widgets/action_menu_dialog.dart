import 'package:flutter/material.dart';

Widget ActionMenuDialog(context,
    {Function? deleteCallback,
    Function? toCashCallback,
    Function? editCallback}) {
  return AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Actions...",
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Divider(),
        if (editCallback != null)
          Ink(
            width: 300,
            child: InkWell(
              onTap: () async {
                Navigator.pop(context);
                await editCallback();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Edit"),
              ),
            ),
          ),
        if (deleteCallback != null)
          Ink(
            width: 300,
            child: InkWell(
              onTap: () async {
                Navigator.pop(context);
                await deleteCallback();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Delete"),
              ),
            ),
          ),
        if (toCashCallback != null)
          Ink(
            width: 300,
            child: InkWell(
              onTap: () async {
                Navigator.pop(context);
                await toCashCallback();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Convert to cash"),
              ),
            ),
          )
      ],
    ),
  );
}
