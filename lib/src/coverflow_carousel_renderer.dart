import 'package:flutter/material.dart';
import 'dart:ui';
import 'card_model.dart';
import 'coverflow_carousel.dart';

class CoverflowCarouselRenderer extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double centerIndex;
  final double maxWidth;
  final double itemWidth;
  final double itemHeight;
  final int visibleItems;
  final double obscure;
  final double skewAngle;
  final double nearCardSpacing;
  final double farCardSpacing;
  final double perspective;
  final PageController controller;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool isInfinite;
  final CoverflowEntryAnimation entryAnimation;
  final double entryProgress;
  final int initialPage;

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
  });

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

  Matrix4 getTransform(int index) {
    final distance = centerIndex - index;
    final transform = Matrix4.identity()
      ..setEntry(3, 2, perspective)
      ..rotateY(skewAngle * distance);

    return transform;
  }

  ImageFilter getFilter(int index) {
    final distance = (centerIndex - index).abs();

    return ImageFilter.blur(
      sigmaX: 5 * obscure * distance,
      sigmaY: 5 * obscure * distance,
    );
  }

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
                child: Stack(
                  children: [
                    Container(
                      width: width,
                      height: height,
                      padding: EdgeInsets.symmetric(vertical: verticalPadding),
                      child: AbsorbPointer(
                        absorbing: !isCentered,
                        child: child,
                      ),
                    ),

                    if (obscure > 0 && distance > 0)
                      Container(
                        width: width,
                        height: height,
                        padding: EdgeInsets.symmetric(
                          vertical: verticalPadding,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: getFilter(index),
                            child: Container(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
