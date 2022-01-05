import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({Key? key, this.content = "", this.yes, this.no}) : super(key: key);
  final String content;
  final Widget? yes;
  final Widget? no;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: MediaQuery.of(context).size.width*3/4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(content,
                  softWrap: true,
                  maxLines: 5,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const Divider(height: 1.0, indent: 10.0, endIndent: 10.0,),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      child: Container(
                        width: MediaQuery.of(context).size.width*3/4,
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: Center(
                          child: no ?? const Text("no"),
                        ),
                      ),
                      onTap: () => Navigator.pop(context, false),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        child: Center(
                          child: yes ?? const Text("yes"),
                        ),
                      ),
                      onTap: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        Navigator.pop(context, false);
        return true;
      },
    );
  }
}

class DialogButtonText extends StatelessWidget {
  const DialogButtonText(this.text, {Key? key, this.color = Colors.black}) : super(key: key);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 16, color: color), maxLines: 1);
  }
}

Future<bool> confirmDeleteProductDialog(context, {String content = ""}) async {
  final bool? isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yes: const DialogButtonText("yes", color: Colors.red),
      no: DialogButtonText("no",
          color: Theme.of(context).disabledColor),
    ),
  );

  return isConfirm ?? false;
}