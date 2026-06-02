import 'package:flutter/material.dart';

class CoverflowCarouselController {
  void Function()? _next;
  void Function()? _previous;
  void Function(int)? _animateTo;

  void next() => _next?.call();

  void previous() => _previous?.call();

  void animateTo(int index) => _animateTo?.call(index);

  void attach({
    required VoidCallback next,
    required VoidCallback previous,
    required ValueChanged<int> animateTo,
  }) {
    _next = next;
    _previous = previous;
    _animateTo = animateTo;
  }

  void detach() {
    _next = null;
    _previous = null;
    _animateTo = null;
  }
}
