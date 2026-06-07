import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'coverflow_carousel_controller.dart';
import 'coverflow_carousel_renderer.dart';

/// Defines the visual entry animations available for cards when the carousel
/// is first mounted/displayed on the screen.
enum CoverflowEntryAnimation {
  /// No entry animation. Cards appear in their standard layout immediately.
  none,

  /// Cards fade in globally.
  fadeIn,

  /// Cards scale up from 80% to 100% of their calculated sizes.
  scaleUp,

  /// Card spacing starts compacted and expands outwards to their configured spacing values.
  spacingExpand,

  /// Cards slide in from the edges: center card drops from above, left cards slide from the left,
  /// and right cards slide from the right.
  staggeredSlide,

  /// Cards fade in and scale up simultaneously.
  fadeScale,

  /// Cards are stacked sequentially from the center card outwards to the adjacent cards.
  /// Inside the sequence, each card animates in sequentially using a scale down from 1.8 to 1.0.
  stack,
}

/// A 3D Coverflow Carousel widget for Flutter.
///
/// Displays a scrollable list of cards in a 3D perspective layout where the
/// active center card is prominent, and adjacent cards are skewed, scaled down,
/// and layered beneath the center card.
///
/// Supports gesture control, mouse wheel dragging, infinite scrolling, programmatic
/// animations via controller, card-click auto-centering, and multiple staggered entry animations.
class CoverflowCarousel extends StatefulWidget {
  /// The total number of items in the carousel.
  final int itemCount;

  /// Builder callback that returns the widget representing the card at the given index.
  ///
  /// The [index] provided is mapped to a real index in `[0, itemCount - 1]`.
  final IndexedWidgetBuilder itemBuilder;

  /// The number of visible cards to render on each side of the active center card.
  ///
  /// Setting this higher renders more background cards. Defaults to `3`.
  final int visibleItems;

  /// The initial card index to focus/center.
  ///
  /// Must be in the range `[0, itemCount - 1]`. Defaults to `0`.
  final int initialPage;

  /// The width of the focused center card.
  final double itemWidth;

  /// The height of the focused center card.
  final double itemHeight;

  /// Intensity of the blur effect applied to off-center cards.
  ///
  /// Set to `0` to disable the blur. Higher values increase blur. Defaults to `0`.
  final double obscure;

  /// The rotation angle (in radians) applied to off-center cards along the Y-axis.
  ///
  /// Negative values tilt cards inwards, creating a coverflow folder look. Defaults to `-0.35`.
  final double skewAngle;

  /// Horizontal spacing between the center card and the immediately adjacent cards (distance = 1).
  ///
  /// Represents logical pixels. Defaults to `45`.
  final double nearCardSpacing;

  /// Horizontal spacing between adjacent background cards (distance >= 2).
  ///
  /// Represents logical pixels. Defaults to `50`.
  final double farCardSpacing;

  /// Perspective factor for 3D projection, modifying the matrix entry `(3, 2)`.
  ///
  /// Defaults to `0.0025` for a realistic depth effect.
  final double perspective;

  /// Duration for card transition animations (e.g., when tapping side cards or calling controller methods).
  ///
  /// Defaults to `350` milliseconds.
  final Duration animationDuration;

  /// Easing curve for card transition animations.
  ///
  /// Defaults to [Curves.easeOutCubic].
  final Curve animationCurve;

  /// Optional controller to programmatically drive next, previous, or jump/animateTo operations.
  final CoverflowCarouselController? controller;

  /// Callback triggered whenever the active centered card index changes.
  final ValueChanged<int>? onPageChanged;

  /// Fraction of the viewport occupied by each card scroll slot.
  ///
  /// Controls drag responsiveness and scrolling speed. Defaults to `0.25`.
  final double viewportFraction;

  /// Whether the carousel should wrap around infinitely at the ends.
  ///
  /// If `true`, the user can scroll infinitely in both directions. Defaults to `false`.
  final bool isInfinite;

  /// The entry animation to play when the carousel is first rendered.
  ///
  /// Defaults to [CoverflowEntryAnimation.none].
  final CoverflowEntryAnimation entryAnimation;

  /// The duration of the entry animation.
  ///
  /// Defaults to `1000` milliseconds.
  final Duration entryAnimationDuration;

  /// Easing curve applied to the entry animation.
  ///
  /// Defaults to [Curves.easeOutCubic].
  final Curve entryAnimationCurve;

  /// Optional builder that returns a widget to stack on top of the active centered card.
  ///
  /// Can be used to display play buttons, badges, controls, or overlays.
  /// Standard positioning widgets (like [Align], [Positioned], or [Center]) can be
  /// used within this builder to place the overlay anywhere on the card.
  final Widget Function(BuildContext context, int index)? centerOverlayBuilder;

  /// Creates a Coverflow Carousel with a builder pattern.
  const CoverflowCarousel.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemWidth,
    required this.itemHeight,
    this.visibleItems = 3,
    this.obscure = 0,
    this.skewAngle = -0.35,
    this.initialPage = 0,
    this.onPageChanged,
    this.nearCardSpacing = 45,
    this.farCardSpacing = 50,
    this.perspective = 0.0025,
    this.animationDuration = const Duration(milliseconds: 350),
    this.animationCurve = Curves.easeOutCubic,
    this.controller,
    this.viewportFraction = 0.25,
    this.isInfinite = false,
    this.entryAnimation = CoverflowEntryAnimation.none,
    this.entryAnimationDuration = const Duration(milliseconds: 1000),
    this.entryAnimationCurve = Curves.easeOutCubic,
    this.centerOverlayBuilder,
  });

  @override
  State<CoverflowCarousel> createState() => _CoverflowCarouselState();
}

class _CoverflowCarouselState extends State<CoverflowCarousel>
    with SingleTickerProviderStateMixin {
  late PageController _controller;
  late double currentPage;
  int _lastReportedPage = -1;
  late int _initialVirtualPage;
  AnimationController? _entryController;
  Animation<double>? _entryAnimation;

  @override
  void initState() {
    super.initState();
    _initialVirtualPage = widget.isInfinite
        ? (10000 * widget.itemCount) + widget.initialPage
        : widget.initialPage;
    currentPage = _initialVirtualPage.toDouble();
    _controller = PageController(
      viewportFraction: widget.viewportFraction,
      initialPage: _initialVirtualPage,
    );

    if (widget.entryAnimation != CoverflowEntryAnimation.none) {
      _entryController = AnimationController(
        vsync: this,
        duration: widget.entryAnimationDuration,
      );
      _entryAnimation = CurveTween(
        curve: widget.entryAnimationCurve,
      ).animate(_entryController!);
      _entryController!.forward();
    }

    _controller.addListener(_pageListener);
    _attachController();
  }

  void _pageListener() {
    final page = _controller.page ?? 0;
    setState(() {
      currentPage = page;
    });

    final rounded = page.round();
    final realIndex = widget.isInfinite && widget.itemCount > 0
        ? ((rounded % widget.itemCount) + widget.itemCount) % widget.itemCount
        : rounded;

    if (realIndex != _lastReportedPage) {
      _lastReportedPage = realIndex;
      widget.onPageChanged?.call(realIndex);
    }
  }

  @override
  void didUpdateWidget(covariant CoverflowCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      _attachController();
    }

    if (oldWidget.viewportFraction != widget.viewportFraction ||
        oldWidget.isInfinite != widget.isInfinite) {
      final double currentRawPage = _controller.positions.isNotEmpty
          ? _controller.page ?? widget.initialPage.toDouble()
          : widget.initialPage.toDouble();
      final int nextPageIndex;

      if (oldWidget.isInfinite != widget.isInfinite) {
        if (widget.isInfinite) {
          final int currentRealIndex = widget.itemCount > 0
              ? ((currentRawPage.round() % widget.itemCount) +
                        widget.itemCount) %
                    widget.itemCount
              : 0;
          nextPageIndex = (10000 * widget.itemCount) + currentRealIndex;
        } else {
          nextPageIndex = widget.itemCount > 0
              ? ((currentRawPage.round() % widget.itemCount) +
                        widget.itemCount) %
                    widget.itemCount
              : 0;
        }
      } else {
        nextPageIndex = currentRawPage.round();
      }

      _controller.removeListener(_pageListener);
      _controller.dispose();
      _controller = PageController(
        viewportFraction: widget.viewportFraction,
        initialPage: nextPageIndex,
      );
      currentPage = nextPageIndex.toDouble();
      _controller.addListener(_pageListener);
      _attachController();
    }
  }

  void _attachController() {
    widget.controller?.attach(
      next: () {
        _controller.nextPage(
          duration: widget.animationDuration,
          curve: widget.animationCurve,
        );
      },
      previous: () {
        _controller.previousPage(
          duration: widget.animationDuration,
          curve: widget.animationCurve,
        );
      },
      animateTo: (index) {
        final targetPage = widget.isInfinite
            ? _getNearestVirtualPage(index, currentPage, widget.itemCount)
            : index;
        _controller.animateToPage(
          targetPage,
          duration: widget.animationDuration,
          curve: widget.animationCurve,
        );
      },
    );
  }

  int _getNearestVirtualPage(
    int targetRealIndex,
    double currentVirtualPage,
    int itemCount,
  ) {
    if (itemCount <= 0) return 0;
    final int currentVirtualRound = currentVirtualPage.round();
    final int currentRealIndex =
        ((currentVirtualRound % itemCount) + itemCount) % itemCount;
    int diff = targetRealIndex - currentRealIndex;
    if (diff > itemCount / 2) {
      diff -= itemCount;
    } else if (diff < -itemCount / 2) {
      diff += itemCount;
    }
    return currentVirtualRound + diff;
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _controller.dispose();
    _entryController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.itemHeight + 80,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.isInfinite ? null : widget.itemCount,
            scrollBehavior: const _CoverflowScrollBehavior(),
            itemBuilder: (_, _) {
              return const SizedBox.shrink();
            },
          ),

          if (widget.entryAnimation == CoverflowEntryAnimation.none)
            _CoverflowGesturePassThrough(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return CoverflowCarouselRenderer(
                    controller: _controller,
                    centerIndex: currentPage,
                    maxWidth: constraints.maxWidth,
                    itemWidth: widget.itemWidth,
                    itemHeight: widget.itemHeight,
                    itemCount: widget.itemCount,
                    visibleItems: widget.visibleItems,
                    itemBuilder: widget.itemBuilder,
                    obscure: widget.obscure,
                    skewAngle: widget.skewAngle,
                    nearCardSpacing: widget.nearCardSpacing,
                    farCardSpacing: widget.farCardSpacing,
                    perspective: widget.perspective,
                    animationDuration: widget.animationDuration,
                    animationCurve: widget.animationCurve,
                    isInfinite: widget.isInfinite,
                    entryAnimation: CoverflowEntryAnimation.none,
                    entryProgress: 1.0,
                    initialPage: _initialVirtualPage,
                    centerOverlayBuilder: widget.centerOverlayBuilder,
                  );
                },
              ),
            )
          else
            AnimatedBuilder(
              animation: _entryAnimation!,
              builder: (context, child) {
                return _CoverflowGesturePassThrough(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return CoverflowCarouselRenderer(
                        controller: _controller,
                        centerIndex: currentPage,
                        maxWidth: constraints.maxWidth,
                        itemWidth: widget.itemWidth,
                        itemHeight: widget.itemHeight,
                        itemCount: widget.itemCount,
                        visibleItems: widget.visibleItems,
                        itemBuilder: widget.itemBuilder,
                        obscure: widget.obscure,
                        skewAngle: widget.skewAngle,
                        nearCardSpacing: widget.nearCardSpacing,
                        farCardSpacing: widget.farCardSpacing,
                        perspective: widget.perspective,
                        animationDuration: widget.animationDuration,
                        animationCurve: widget.animationCurve,
                        isInfinite: widget.isInfinite,
                        entryAnimation: widget.entryAnimation,
                        entryProgress: _entryAnimation!.value,
                        initialPage: _initialVirtualPage,
                        centerOverlayBuilder: widget.centerOverlayBuilder,
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CoverflowScrollBehavior extends ScrollBehavior {
  const _CoverflowScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

/// Custom render object widget that intercepts gestures but allows them to fall through
/// to stack layers underneath.
///
/// Hit-tests children and registers them in the gesture system (allowing buttons and
/// taps to work), but returns false on hit-testing so sibling overlay widgets (like
/// the underlying swiping PageView) can still receive drag events.
class _CoverflowGesturePassThrough extends SingleChildRenderObjectWidget {
  const _CoverflowGesturePassThrough({required Widget child})
    : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderCoverflowGesturePassThrough();
  }
}

class _RenderCoverflowGesturePassThrough extends RenderProxyBox {
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    hitTestChildren(result, position: position);
    return false;
  }
}
