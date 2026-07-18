import 'package:flutter/material.dart';
import 'coverflow_carousel_controller.dart';

const double _tapTargetSize = 40.0;

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
        final clamped = page.clamp(0.0, count.toDouble() - 1e-9).toDouble();
        final floor = clamped.floor();
        final t = clamped - floor;
        final indexB = (floor + 1) % count;
        final isWrapping = count > 1 && indexB == 0 && floor == count - 1;

        return SizedBox(
          width: count * dotSize + (count - 1) * dotSpacing,
          height: dotSize + 8,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final i in List.generate(count, (i) => i))
                Positioned(
                  left: i * step - (_tapTargetSize - dotSize) / 2,
                  top: 4 - (_tapTargetSize - dotSize) / 2,
                  width: _tapTargetSize,
                  height: _tapTargetSize,
                  child: GestureDetector(
                    onTap: onTap != null ? () => onTap!(i) : null,
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: inactiveColor,
                        ),
                      ),
                    ),
                  ),
                ),
              if (isWrapping && t > 0.5) ...[
                _buildActivePill(left: 0, width: dotSize * ((t - 0.5) / 0.5)),
                _buildActivePill(
                  left: floor * step,
                  width: dotSize * (1.0 - (t - 0.5) / 0.5),
                ),
              ] else
                _buildActivePill(
                  left: floor * step + (t < 0.5 ? 0 : ((t - 0.5) / 0.5) * step),
                  width:
                      dotSize +
                      (t < 0.5
                          ? (t / 0.5) * step
                          : (1.0 - (t - 0.5) / 0.5) * step),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivePill({required double left, required double width}) {
    return Positioned(
      left: left,
      top: 4,
      width: width,
      height: dotSize,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: activeColor,
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        ),
      ),
    );
  }
}
