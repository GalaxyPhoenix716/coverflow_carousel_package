import 'package:flutter/material.dart';

/// A controller used to programmatically control a [CoverflowCarousel].
///
/// Pass an instance of [CoverflowCarouselController] to [CoverflowCarousel.builder]
/// to trigger scroll animations programmatically (e.g., jumping/animating to a page,
/// transitioning to the next or previous card).
class CoverflowCarouselController {
  void Function()? _next;
  void Function()? _previous;
  void Function(int)? _animateTo;

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
}
