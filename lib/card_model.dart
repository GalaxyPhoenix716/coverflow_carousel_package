import 'package:flutter/material.dart';

class CardModel {
  final int id;
  double zIndex;
  final Widget child;

  CardModel({required this.id, required this.child, this.zIndex = 0});
}
