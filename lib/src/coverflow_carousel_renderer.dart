import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'card_model.dart';
import 'coverflow_carousel.dart';

/// The core layout rendering engine for [CoverflowCarousel].
///
/// Responsible for building the stacked card widget hierarchy, calculating horizontal
/// offsets with spacing fanning, computing 3D transformation matrices (skew angle and perspective),
/// sorting cards by depth (z-index), and applying entry animation timelines.
class CoverflowCarouselRenderer extends StatelessWidget {
  /// The total number of items in the carousel.
  final int itemCount;

  /// Builder callback that returns the child widget representing the card at the given index.
  final IndexedWidgetBuilder itemBuilder;

  /// The active scroll position as a fractional page index (e.g. `2.5` represents halfway between index 2 and index 3).
  final double centerIndex;

  /// The maximum available width from the parent layout constraints.
  final double maxWidth;

  /// The width of the focused center card.
  final double itemWidth;

  /// The height of the focused center card.
  final double itemHeight;

  /// The number of visible cards to render on each side of the active center card.
  final int visibleItems;

  /// Intensity of the blur effect applied to off-center cards.
  final double obscure;

  /// The rotation angle (in radians) applied to off-center cards along the Y-axis.
  final double skewAngle;

  /// Horizontal spacing between the center card and the immediately adjacent cards.
  final double nearCardSpacing;

  /// Horizontal spacing between adjacent background cards.
  final double farCardSpacing;

  /// Perspective factor for 3D projection, modifying the matrix entry `(3, 2)`.
  final double perspective;

  /// The underlying page controller used to synchronize programmatically triggered scroll animations.
  final PageController controller;

  /// Duration for card transition animations.
  final Duration animationDuration;

  /// Easing curve for card transition animations.
  final Curve animationCurve;

  /// Whether the carousel wraps around infinitely.
  final bool isInfinite;

  /// The active entry animation type.
  final CoverflowEntryAnimation entryAnimation;

  /// The current progression of the entry animation, from `0.0` (start) to `1.0` (complete).
  final double entryProgress;

  /// The initial virtual page index.
  final int initialPage;

  /// Optional builder that returns a widget to stack on top of the active centered card.
  final Widget Function(BuildContext context, int index)? centerOverlayBuilder;

  /// Whether to enable 3D hover/tilt effects on cards.
  final bool enableHoverTilt;

  /// The maximum tilt angle (in radians) applied during the 3D hover effect.
  final double maxHoverTiltAngle;

  /// Creates a [CoverflowCarouselRenderer] to lay out and paint the carousel cards.
  const CoverflowCarouselRenderer({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.centerIndex,
    required this.maxWidth,
    required this.itemWidth,
    required this.itemHeight,
    required this.obscure,
    required this.skewAngle,
    required this.nearCardSpacing,
    required this.farCardSpacing,
    required this.controller,
    required this.animationDuration,
    required this.animationCurve,
    required this.visibleItems,
    required this.perspective,
    required this.isInfinite,
    required this.entryAnimation,
    required this.entryProgress,
    required this.initialPage,
    required this.enableHoverTilt,
    required this.maxHoverTiltAngle,
    this.centerOverlayBuilder,
  });

  /// Calculates the horizontal center position (logical pixels) for a card at [index].
  ///
  /// The center card sits exactly at the middle of the available viewport width.
  /// Adjacent cards are distributed outwards using [nearCardSpacing] for the first step,
  /// and [farCardSpacing] for subsequent steps, modified by the entry animation progress if active.
  double getCardPosition(int index) {
    final center = maxWidth / 2;
    final distance = index - centerIndex;

    final spacingFactor =
        entryAnimation == CoverflowEntryAnimation.spacingExpand
        ? entryProgress
        : 1.0;
    final nearSpacing = nearCardSpacing * spacingFactor;
    final farSpacing = farCardSpacing * spacingFactor;

    if (distance.abs() <= 1) {
      return center + distance * nearSpacing;
    }

    return center +
        distance.sign * nearSpacing +
        distance.sign * (distance.abs() - 1) * farSpacing;
  }

  /// Calculates the scaled width of a card at [index].
  ///
  /// Cards shrink as they move away from the active center card.
  /// The focused card has [itemWidth]. Immediately adjacent cards (distance = 1) shrink to 88%.
  /// Further adjacent cards (distance >= 2) shrink to 72%. Transitions between these distances are linear.
  double getCardWidth(int index) {
    final distance = (centerIndex - index).abs();
    final centerWidth = itemWidth;
    final nearWidth = itemWidth * 0.88;
    final farWidth = itemWidth * 0.72;

    if (distance < 1) {
      return centerWidth -
          (centerWidth - nearWidth) * (distance - distance.floor());
    }

    if (distance < 2) {
      return nearWidth - (nearWidth - farWidth) * (distance - distance.floor());
    }

    return farWidth;
  }

  /// Computes the 3D perspective matrix for a card at [index].
  ///
  /// Applies a perspective entry `(3, 2) = perspective` and rotates the card along the
  /// Y-axis by `skewAngle * distance` (where `distance` is the layout difference `centerIndex - index`).
  Matrix4 getTransform(int index) {
    final distance = centerIndex - index;
    final transform = Matrix4.identity()
      ..setEntry(3, 2, perspective)
      ..rotateY(skewAngle * distance);

    return transform;
  }

  /// Computes the blur filter applied to a card at [index] when [obscure] is enabled.
  ImageFilter getFilter(int index) {
    final distance = (centerIndex - index).abs();

    return ImageFilter.blur(
      sigmaX: 5 * obscure * distance,
      sigmaY: 5 * obscure * distance,
    );
  }

  /// Builds a single styled card widget with transformations, gesture handling, and animations.
  ///
  /// Handles transition gestures, entry animation timelines (scaling, slide translations, stacking fades),
  /// 3D transformations, vertical scaling padding, and backdrop blur filters.
  Widget buildCard(BuildContext context, int index, Widget child) {
    final distance = (centerIndex - index).abs();
    final width = getCardWidth(index);
    final height = (itemHeight * (1 - distance * 0.08)).clamp(
      itemHeight * 0.75,
      itemHeight,
    );
    final position = getCardPosition(index);
    final verticalPadding = width * 0.05 * distance;
    final bool isCentered = index == centerIndex.round();

    final double cardProgress;
    if (entryAnimation == CoverflowEntryAnimation.none) {
      cardProgress = 1.0;
    } else if (entryAnimation == CoverflowEntryAnimation.stack) {
      final double maxDistance = visibleItems.toDouble();
      final double intervals = maxDistance > 0 ? maxDistance + 1 : 1.0;
      final double intervalWidth = 1.0 / intervals;
      final double distance = (initialPage - index).abs().toDouble().clamp(0.0, maxDistance);
      final double start = distance * intervalWidth;
      final double end = start + intervalWidth;

      if (entryProgress <= start) {
        cardProgress = 0.0;
      } else if (entryProgress >= end) {
        cardProgress = 1.0;
      } else {
        cardProgress = (entryProgress - start) / intervalWidth;
      }
    } else {
      final double staggerDistance = (initialPage - index).abs().toDouble();
      final double start = (staggerDistance * 0.15).clamp(0.0, 0.75);
      const double end = 1.0;
      if (entryProgress <= start) {
        cardProgress = 0.0;
      } else if (entryProgress >= end) {
        cardProgress = 1.0;
      } else {
        cardProgress = (entryProgress - start) / (end - start);
      }
    }

    double opacity = 1.0;
    double scale = 1.0;
    double translateX = 0.0;
    double translateY = 0.0;

    if (entryAnimation != CoverflowEntryAnimation.none) {
      if (entryAnimation == CoverflowEntryAnimation.fadeIn ||
          entryAnimation == CoverflowEntryAnimation.fadeScale) {
        opacity = cardProgress;
      }
      if (entryAnimation == CoverflowEntryAnimation.scaleUp ||
          entryAnimation == CoverflowEntryAnimation.fadeScale) {
        scale = 0.8 + (0.2 * cardProgress);
      }
      if (entryAnimation == CoverflowEntryAnimation.staggeredSlide) {
        opacity = cardProgress;
        if (index == initialPage) {
          translateY = -50.0 * (1.0 - cardProgress);
        } else if (index < initialPage) {
          translateX = -150.0 * (1.0 - cardProgress);
        } else {
          translateX = 150.0 * (1.0 - cardProgress);
        }
      }
      if (entryAnimation == CoverflowEntryAnimation.stack) {
        scale = 1.8 - (0.8 * cardProgress);
        opacity = (cardProgress * 2.0).clamp(0.0, 1.0);
        translateX = 0.0;
        translateY = 0.0;
      }
    }

    final double overlayOpacity = (1.0 - distance).clamp(0.0, 1.0);
    final Widget cardChild = obscure > 0 && distance > 0
        ? ImageFiltered(
            imageFilter: getFilter(index),
            child: child,
          )
        : child;

    Widget cardWidget = Container(
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: AbsorbPointer(
        absorbing: !isCentered,
        child: _CoverflowHoverTilt(
          enabled: enableHoverTilt && isCentered,
          maxTiltAngle: maxHoverTiltAngle,
          perspective: perspective,
          child: cardChild,
        ),
      ),
    );

    final realIndex = isInfinite && itemCount > 0
        ? ((index % itemCount) + itemCount) % itemCount
        : index;

    if (centerOverlayBuilder != null && overlayOpacity > 0.0) {
      final overlayWidget = centerOverlayBuilder!(context, realIndex);
      if (overlayWidget is Positioned) {
        cardWidget = Stack(
          clipBehavior: Clip.none,
          children: [
            cardWidget,
            Positioned(
              left: overlayWidget.left,
              top: overlayWidget.top,
              right: overlayWidget.right,
              bottom: overlayWidget.bottom,
              width: overlayWidget.width,
              height: overlayWidget.height,
              child: IgnorePointer(
                ignoring: !isCentered,
                child: Opacity(
                  opacity: overlayOpacity,
                  child: overlayWidget.child,
                ),
              ),
            ),
          ],
        );
      } else if (overlayWidget is PositionedDirectional) {
        cardWidget = Stack(
          clipBehavior: Clip.none,
          children: [
            cardWidget,
            PositionedDirectional(
              start: overlayWidget.start,
              top: overlayWidget.top,
              end: overlayWidget.end,
              bottom: overlayWidget.bottom,
              width: overlayWidget.width,
              height: overlayWidget.height,
              child: IgnorePointer(
                ignoring: !isCentered,
                child: Opacity(
                  opacity: overlayOpacity,
                  child: overlayWidget.child,
                ),
              ),
            ),
          ],
        );
      } else {
        cardWidget = Stack(
          clipBehavior: Clip.none,
          children: [
            cardWidget,
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !isCentered,
                child: Opacity(
                  opacity: overlayOpacity,
                  child: overlayWidget,
                ),
              ),
            ),
          ],
        );
      }
    }

    return Positioned(
      left: position - width / 2,
      child: GestureDetector(
        onTap: !isCentered
            ? () {
                controller.animateToPage(
                  index,
                  duration: animationDuration,
                  curve: animationCurve,
                );
              }
            : null,
        child: Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(translateX, translateY),
            child: Transform.scale(
              scale: scale,
              child: Transform(
                alignment: Alignment.center,
                transform: getTransform(index),
                child: cardWidget,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Evaluates which cards should be rendered and calculates their stacking order.
  ///
  /// Filters cards based on whether they fall within the [visibleItems] threshold.
  /// Computes a [zIndex] for each card using:
  /// `card.zIndex = -(centerIndex - card.id).abs()` (and `999` for the active center card).
  /// Sorts cards ascending by [zIndex] so that background cards paint first and the center
  /// card paints on top.
  List<Widget> buildCards(BuildContext context) {
    final centerRound = centerIndex.round();
    final cards = <CardModel>[];
    final buffer = visibleItems + 1;

    for (int i = centerRound - buffer; i <= centerRound + buffer; i++) {
      if (!isInfinite && (i < 0 || i >= itemCount)) {
        continue;
      }
      if (itemCount <= 0) continue;

      if ((centerIndex - i).abs() > visibleItems + 0.5) {
        continue;
      }

      final realIndex = ((i % itemCount) + itemCount) % itemCount;
      cards.add(CardModel(id: i, child: itemBuilder(context, realIndex)));
    }

    for (final card in cards) {
      if (card.id == centerRound) {
        card.zIndex = 999;
      } else {
        card.zIndex = -(centerIndex - card.id).abs();
      }
    }

    cards.sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return cards
        .map((card) => buildCard(context, card.id, card.child))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: buildCards(context),
    );
  }
}

/// A highly optimized helper widget that applies a 3D hover tilt effect to its child.
///
/// Tracks mouse entry and pointer movements to calculate normalized offsets and apply
/// perspective skew rotation around the horizontal and vertical axes.
class _CoverflowHoverTilt extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double maxTiltAngle;
  final double perspective;

  const _CoverflowHoverTilt({
    required this.child,
    required this.enabled,
    required this.maxTiltAngle,
    required this.perspective,
  });

  @override
  State<_CoverflowHoverTilt> createState() => _CoverflowHoverTiltState();
}

class _CoverflowHoverTiltState extends State<_CoverflowHoverTilt>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  double _baseTiltX = 0.0;
  double _baseTiltY = 0.0;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _controller.addListener(() {
      if (!_hovering) {
        setState(() {
          _tiltX = lerpDouble(_baseTiltX, 0.0, _controller.value) ?? 0.0;
          _tiltY = lerpDouble(_baseTiltY, 0.0, _controller.value) ?? 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(PointerEnterEvent event) {
    if (!widget.enabled) return;
    _hovering = true;
    _controller.stop();
  }

  void _onHover(PointerHoverEvent event) {
    if (!widget.enabled) return;
    final size = context.size;
    if (size == null) return;

    final double x = event.localPosition.dx;
    final double y = event.localPosition.dy;

    final double nx = (x / size.width) - 0.5;
    final double ny = (y / size.height) - 0.5;

    setState(() {
      _tiltX = -ny * widget.maxTiltAngle;
      _tiltY = nx * widget.maxTiltAngle;
    });
  }

  void _onExit(PointerExitEvent event) {
    if (!widget.enabled) return;
    _hovering = false;
    _baseTiltX = _tiltX;
    _baseTiltY = _tiltY;
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final transform = Matrix4.identity()
      ..setEntry(3, 2, widget.perspective)
      ..rotateX(_tiltX)
      ..rotateY(_tiltY);

    return MouseRegion(
      onEnter: _onEnter,
      onHover: _onHover,
      onExit: _onExit,
      child: Transform(
        alignment: Alignment.center,
        transform: transform,
        child: RepaintBoundary(
          child: widget.child,
        ),
      ),
    );
  }
}

