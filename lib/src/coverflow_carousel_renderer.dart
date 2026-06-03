import 'package:flutter/material.dart';
import 'dart:ui';
import 'card_model.dart';

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
  });

  double getCardPosition(int index) {
    final center = maxWidth / 2;

    final distance = index - centerIndex;

    if (distance.abs() <= 1) {
      return center + distance * nearCardSpacing;
    }

    return center +
        distance.sign * nearCardSpacing +
        distance.sign * (distance.abs() - 1) * farCardSpacing;
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

  Widget buildCard(BuildContext context, int index) {
    final distance = (centerIndex - index).abs();
    final width = getCardWidth(index);
    final height = (itemHeight * (1 - distance * 0.08)).clamp(
      itemHeight * 0.75,
      itemHeight,
    );
    final position = getCardPosition(index);
    final verticalPadding = width * 0.05 * distance;
    final bool isCentered = index == centerIndex.round();

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
        child: Transform(
          alignment: Alignment.center,
          transform: getTransform(index),
          child: Stack(
            children: [
              Container(
                width: width,
                height: height,
                padding: EdgeInsets.symmetric(vertical: verticalPadding),
                child: itemBuilder(context, index),
              ),

              if (obscure > 0 && distance > 0)
                Container(
                  width: width,
                  height: height,
                  padding: EdgeInsets.symmetric(vertical: verticalPadding),
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
    );
  }

  List<Widget> buildCards(BuildContext context) {
    final cards = List.generate(
      itemCount,
      (index) => CardModel(id: index, child: itemBuilder(context, index)),
    );

    for (final card in cards) {
      if (card.id == centerIndex.round()) {
        card.zIndex = 999;
      } else if (card.id < centerIndex) {
        card.zIndex = card.id.toDouble();
      } else {
        card.zIndex = itemCount - card.id.toDouble();
      }
    }

    cards.sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return cards
        .where((card) => (centerIndex - card.id).abs() <= visibleItems + 0.5)
        .map((card) => buildCard(context, card.id))
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
