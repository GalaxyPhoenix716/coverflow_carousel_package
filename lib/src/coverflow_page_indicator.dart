import 'package:flutter/material.dart';
import 'coverflow_carousel_controller.dart';

/// Shows the current page as a sliding pill over dots.
///
/// Listens to [controller]'s [ValueNotifier] and animates the active
/// indicator between pages as the carousel scrolls.
class CoverflowPageIndicator extends StatelessWidget {
  const CoverflowPageIndicator({
    super.key,
    required this.controller,
    required this.itemCount,
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.white38,
    this.dotSize = 8.0,
    this.dotSpacing = 12.0,
    this.onTap,
  });

  final CoverflowCarouselController controller;
  final int itemCount;
  final Color activeColor;
  final Color inactiveColor;
  final double dotSize;
  final double dotSpacing;
  final void Function(int index)? onTap;

  @override
  Widget build(BuildContext context) {
    final step = dotSize + dotSpacing;

    return ValueListenableBuilder<double>(
      valueListenable: controller.pageListenable,
      builder: (context, page, _) {
        if (itemCount <= 0) return const SizedBox.shrink();

        final count = itemCount;
        final clamped = ((page % count) + count) % count;
        final floor = clamped.floor();
        final t = clamped - floor;

        final activeLeft =
            floor * step + (t < 0.5 ? 0 : ((t - 0.5) / 0.5) * step);
        final activeWidth =
            dotSize +
            (t < 0.5 ? (t / 0.5) * step : (1.0 - (t - 0.5) / 0.5) * step);

        return SizedBox(
          width: count * dotSize + (count - 1) * dotSpacing,
          height: dotSize + 8,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ...List.generate(count, (i) {
                return Positioned(
                  left: i * step,
                  top: 4,
                  width: dotSize,
                  height: dotSize,
                  child: GestureDetector(
                    onTap: onTap != null ? () => onTap!(i) : null,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: inactiveColor,
                      ),
                    ),
                  ),
                );
              }),
              Positioned(
                left: activeLeft,
                top: 4,
                width: activeWidth,
                height: dotSize,
                child: Container(
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(dotSize / 2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
