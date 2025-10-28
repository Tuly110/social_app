import 'package:flutter/widgets.dart';

class CellEntity {
  final TextEditingController controller;
  String output;

  CellEntity({required this.controller, this.output = ''});
}