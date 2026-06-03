import 'package:flutter/material.dart';
import 'dart:ui';
import 'coverflow_carousel_controller.dart';
import 'coverflow_carousel_renderer.dart';

class CoverflowCarousel extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int visibleItems;
  final int initialPage;
  final double itemWidth;
  final double itemHeight;
  final double obscure;
  final double skewAngle;
  final double nearCardSpacing;
  final double farCardSpacing;
  final double perspective;
  final Duration animationDuration;
  final Curve animationCurve;
  final CoverflowCarouselController? controller;
  final ValueChanged<int>? onPageChanged;
  final double viewportFraction;

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
  });

  @override
  State<CoverflowCarousel> createState() => _CoverflowCarouselState();
}

class _CoverflowCarouselState extends State<CoverflowCarousel> {
  late PageController _controller;
  late double currentPage;
  int _lastReportedPage = -1;

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage.toDouble();
    _controller = PageController(
      viewportFraction: widget.viewportFraction,
      initialPage: widget.initialPage,
    );

    _controller.addListener(_pageListener);
    _attachController();
  }

  void _pageListener() {
    final page = _controller.page ?? 0;
    setState(() {
      currentPage = page;
    });

    final rounded = page.round();

    if (rounded != _lastReportedPage) {
      _lastReportedPage = rounded;
      widget.onPageChanged?.call(rounded);
    }
  }

  @override
  void didUpdateWidget(covariant CoverflowCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      _attachController();
    }

    if (oldWidget.viewportFraction != widget.viewportFraction) {
      final currentPageIndex = _controller.positions.isNotEmpty
          ? _controller.page?.round() ?? widget.initialPage
          : widget.initialPage;
      _controller.removeListener(_pageListener);
      _controller.dispose();
      _controller = PageController(
        viewportFraction: widget.viewportFraction,
        initialPage: currentPageIndex,
      );
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
            scrollBehavior: const ScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            itemBuilder: (_, _) {
              return const SizedBox.shrink();
            },
          ),

          LayoutBuilder(
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
              );
            },
          ),
        ],
      ),
    );
  }
}
