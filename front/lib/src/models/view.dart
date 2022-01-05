import 'package:flutter/cupertino.dart';

class View {
  String title;
  Icon icon;
  Widget view;
  bool appbar;

  View(this.title, this.icon, this.view, {this.appbar = true});
}
