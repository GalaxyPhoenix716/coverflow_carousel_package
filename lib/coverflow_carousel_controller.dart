import 'package:flutter/material.dart';

class CoverflowCarouselController {
  VoidCallback? _next;
  VoidCallback? _previous;
  ValueChanged<int>? _animateTo;

  void next() {
    _next?.call();
  }

  void previous() {
    _previous?.call();
  }

  void animateTo(int index) {
    _animateTo?.call(index);
  }
}
