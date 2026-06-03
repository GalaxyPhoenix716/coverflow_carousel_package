library coverflow_carousel;

import 'package:coverflow_carousel/coverflow_carousel_controller.dart';
import 'package:coverflow_carousel/coverflow_carousel_renderer.dart';
import 'package:flutter/material.dart';

class CoverflowCarousel extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double itemWidth;
  final double itemHeight;
  final int visibleItems;
  final double obscure;
  final double skewAngle;
  final int initialPage;
  final ValueChanged<int>? onPageChanged;
  final CoverflowCarouselController? controller;
  final double nearCardSpacing;
  final double farCardSpacing;
  final Duration animationDuration;
  final Curve animationCurve;

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
    this.animationDuration = const Duration(milliseconds: 350),
    this.animationCurve = Curves.easeOutCubic,
    this.controller,
  });

  @override
  State<CoverflowCarousel> createState() => _CoverflowCarouselState();
}

class _CoverflowCarouselState extends State<CoverflowCarousel> {
  late final PageController _controller;
  late double currentPage;
  int _lastReportedPage = -1;

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage.toDouble();
    _controller = PageController(
      viewportFraction: 0.25,
      initialPage: widget.initialPage,
    );

    _controller.addListener(() {
      final page = _controller.page ?? 0;
      setState(() {
        currentPage = page;
      });

      final rounded = page.round();

      if (rounded != _lastReportedPage) {
        _lastReportedPage = rounded;
        widget.onPageChanged?.call(rounded);
      }
    });

    _attachController();
  }

  @override
  void didUpdateWidget(covariant CoverflowCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();

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
        _controller.animateToPage(
          index,
          duration: widget.animationDuration,
          curve: widget.animationCurve,
        );
      },
    );
  }

  @override
  void dispose() {
    widget.controller?.detach();

    _controller.dispose();

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
            itemCount: widget.itemCount,
            itemBuilder: (_, _) {
              return const SizedBox.shrink();
            },
          ),

          IgnorePointer(
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
                  animationDuration: widget.animationDuration,
                  animationCurve: widget.animationCurve,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
