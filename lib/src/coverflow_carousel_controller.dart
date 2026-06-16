import 'package:flutter/material.dart';
import 'dart:async';

/// A controller used to programmatically control a [CoverflowCarousel].
///
/// Pass an instance of [CoverflowCarouselController] to [CoverflowCarousel.builder]
/// to trigger scroll animations programmatically (e.g., jumping/animating to a page,
/// transitioning to the next or previous card) and listen to real-time scroll progress.
///
/// Remember to call [dispose] when discarding the controller to clean up stream subscriptions.
class CoverflowCarouselController {
  void Function()? _next;
  void Function()? _previous;
  void Function(int)? _animateTo;

  final ValueNotifier<double> _pageNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> _rawPageNotifier = ValueNotifier<double>(0.0);

  final StreamController<double> _pageStreamController =
      StreamController<double>.broadcast();
  final StreamController<double> _rawPageStreamController =
      StreamController<double>.broadcast();

  /// A [ValueNotifier] that emits the current normalized fractional page index.
  ///
  /// If the carousel is infinite, this value is normalized to the range `[0, itemCount)`
  /// and wraps around smoothly.
  ValueNotifier<double> get pageListenable => _pageNotifier;

  /// A [ValueNotifier] that emits the raw fractional page index from the underlying scroll controller.
  ValueNotifier<double> get rawPageListenable => _rawPageNotifier;

  /// The current normalized fractional page index.
  double get page => _pageNotifier.value;

  /// The current raw fractional page index.
  double get rawPage => _rawPageNotifier.value;

  /// A broadcast stream emitting the current normalized fractional page index on every scroll update.
  Stream<double> get pageStream => _pageStreamController.stream;

  /// A broadcast stream emitting the current raw fractional page index on every scroll update.
  Stream<double> get rawPageStream => _rawPageStreamController.stream;

  /// Programmatically transitions the carousel to the next card.
  ///
  /// Uses the default animation duration and curve specified on the carousel.
  void next() => _next?.call();

  /// Programmatically transitions the carousel to the previous card.
  ///
  /// Uses the default animation duration and curve specified on the carousel.
  void previous() => _previous?.call();

  /// Programmatically animates the carousel to the card at the specified index.
  ///
  /// On infinite carousels, this automatically finds the shortest distance
  /// (shortest-path animation) to transition to the target [index].
  void animateTo(int index) => _animateTo?.call(index);

  /// Attaches the controller to a [CoverflowCarousel] state.
  ///
  /// Called internally by the carousel state; do not call this method directly.
  void attach({
    required VoidCallback next,
    required VoidCallback previous,
    required ValueChanged<int> animateTo,
  }) {
    _next = next;
    _previous = previous;
    _animateTo = animateTo;
  }

  /// Detaches the controller from the carousel.
  ///
  /// Called internally when the carousel is disposed or updated; do not call this
  /// method directly.
  void detach() {
    _next = null;
    _previous = null;
    _animateTo = null;
  }

  /// Updates the internal metrics of the controller.
  ///
  /// Called internally by the carousel state; do not call this method directly.
  void updateMetrics({
    required double rawPage,
    required double normalizedPage,
  }) {
    if (_rawPageNotifier.value != rawPage) {
      _rawPageNotifier.value = rawPage;
      if (!_rawPageStreamController.isClosed) {
        _rawPageStreamController.add(rawPage);
      }
    }
    if (_pageNotifier.value != normalizedPage) {
      _pageNotifier.value = normalizedPage;
      if (!_pageStreamController.isClosed) {
        _pageStreamController.add(normalizedPage);
      }
    }
  }

  /// Disposes the controller, closing all broadcast streams and page value notifiers.
  ///
  /// Developers must call this method when the controller is no longer needed to prevent memory leaks.
  void dispose() {
    _pageStreamController.close();
    _rawPageStreamController.close();
    _pageNotifier.dispose();
    _rawPageNotifier.dispose();
  }
}
