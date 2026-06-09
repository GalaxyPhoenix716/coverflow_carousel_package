import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/gestures.dart';
import 'package:coverflow_carousel/coverflow_carousel.dart';

void main() {
  testWidgets('CoverflowCarousel renders correctly with basic parameters',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoverflowCarousel.builder(
            itemCount: 5,
            itemWidth: 200,
            itemHeight: 300,
            itemBuilder: (context, index) {
              return Text('Item $index');
            },
          ),
        ),
      ),
    );

    // Verify initial state (visible cards should show up, default visibleItems is 3)
    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    // Item 4 should not be visible (too far away)
    expect(find.text('Item 4'), findsNothing);
  });

  testWidgets('CoverflowCarousel custom viewportFraction is passed to PageController',
      (WidgetTester tester) async {
    const customViewportFraction = 0.4;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoverflowCarousel.builder(
            itemCount: 5,
            itemWidth: 200,
            itemHeight: 300,
            viewportFraction: customViewportFraction,
            itemBuilder: (context, index) {
              return Text('Item $index');
            },
          ),
        ),
      ),
    );

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.controller!.viewportFraction, customViewportFraction);
  });

  testWidgets('Tapping on a side card animates to it',
      (WidgetTester tester) async {
    int pageChangedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoverflowCarousel.builder(
            itemCount: 5,
            itemWidth: 200,
            itemHeight: 300,
            nearCardSpacing: 250,
            farCardSpacing: 250,
            initialPage: 0,
            onPageChanged: (index) {
              pageChangedIndex = index;
            },
            itemBuilder: (context, index) {
              return KeyedSubtree(
                key: Key('card-$index'),
                child: Text('Item $index'),
              );
            },
          ),
        ),
      ),
    );

    // Tap on Item 1 (side card)
    await tester.tap(find.byKey(const Key('card-1')), warnIfMissed: false);
    await tester.pumpAndSettle();

    // The page should have changed to 1
    expect(pageChangedIndex, 1);
  });

  testWidgets('Tapping on focused card child elements works',
      (WidgetTester tester) async {
    bool buttonPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoverflowCarousel.builder(
            itemCount: 3,
            itemWidth: 200,
            itemHeight: 300,
            initialPage: 0,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ElevatedButton(
                  key: const Key('btn-0'),
                  onPressed: () {
                    buttonPressed = true;
                  },
                  child: const Text('Button'),
                );
              }
              return Text('Item $index');
            },
          ),
        ),
      ),
    );

    // Tap the button inside the focused card (Item 0)
    await tester.tap(find.byKey(const Key('btn-0')));
    await tester.pump();

    expect(buttonPressed, isTrue);
  });

  testWidgets('CoverflowCarouselController next/previous/animateTo works',
      (WidgetTester tester) async {
    final controller = CoverflowCarouselController();
    int pageChangedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoverflowCarousel.builder(
            controller: controller,
            itemCount: 5,
            itemWidth: 200,
            itemHeight: 300,
            initialPage: 0,
            onPageChanged: (index) {
              pageChangedIndex = index;
            },
            itemBuilder: (context, index) {
              return Text('Item $index');
            },
          ),
        ),
      ),
    );

    // Go to next page
    controller.next();
    await tester.pumpAndSettle();
    expect(pageChangedIndex, 1);

    // Go to next page again
    controller.next();
    await tester.pumpAndSettle();
    expect(pageChangedIndex, 2);

    // Go back to previous page
    controller.previous();
    await tester.pumpAndSettle();
    expect(pageChangedIndex, 1);

    // Animate to page 3
    controller.animateTo(3);
    await tester.pumpAndSettle();
    expect(pageChangedIndex, 3);
  });

  testWidgets('Tapping on a side card with internal gestures animates it to center instead of triggering inner gesture',
      (WidgetTester tester) async {
    int pageChangedIndex = -1;
    bool innerTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoverflowCarousel.builder(
            itemCount: 5,
            itemWidth: 200,
            itemHeight: 300,
            nearCardSpacing: 250,
            farCardSpacing: 250,
            initialPage: 0,
            onPageChanged: (index) {
              pageChangedIndex = index;
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                key: Key('card-$index'),
                onTap: () {
                  innerTapped = true;
                },
                child: Text('Item $index'),
              );
            },
          ),
        ),
      ),
    );

    // Tap on Item 1 (side card) which has an internal onTap handler
    await tester.tap(find.byKey(const Key('card-1')), warnIfMissed: false);
    await tester.pumpAndSettle();

    // The page should have changed to 1, but the inner tap handler should NOT have fired
    expect(pageChangedIndex, 1);
    expect(innerTapped, isFalse);

    // Now that Item 1 is centered, tap it again
    await tester.tap(find.byKey(const Key('card-1')));
    await tester.pump();

    // Now the inner tap handler should have fired!
    expect(innerTapped, isTrue);
  });

  testWidgets('CoverflowCarousel infinite scroll starts at high page and maps indices',
      (WidgetTester tester) async {
    int pageChangedIndex = -1;
    final controller = CoverflowCarouselController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoverflowCarousel.builder(
            controller: controller,
            itemCount: 5,
            itemWidth: 200,
            itemHeight: 300,
            isInfinite: true,
            initialPage: 0,
            onPageChanged: (index) {
              pageChangedIndex = index;
            },
            itemBuilder: (context, index) {
              return Text('Item $index');
            },
          ),
        ),
      ),
    );

    // PageView controller should be initialized at a high page number (10000 * 5 = 50000)
    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.controller!.initialPage, 50000);

    // Let's call controller.next() to verify it goes to 1
    controller.next();
    await tester.pumpAndSettle();
    expect(pageChangedIndex, 1);

    // Let's call controller.previous() twice to go to index 4
    controller.previous();
    await tester.pumpAndSettle();
    controller.previous();
    await tester.pumpAndSettle();
    expect(pageChangedIndex, 4);
    expect(pageView.controller!.page, 49999.0);
  });

  testWidgets('CoverflowCarouselController animateTo selects shortest path on infinite scroll',
      (WidgetTester tester) async {
    final controller = CoverflowCarouselController();
    int pageChangedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoverflowCarousel.builder(
            controller: controller,
            itemCount: 5,
            itemWidth: 200,
            itemHeight: 300,
            isInfinite: true,
            initialPage: 0,
            onPageChanged: (index) {
              pageChangedIndex = index;
            },
            itemBuilder: (context, index) {
              return Text('Item $index');
            },
          ),
        ),
      ),
    );

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.controller!.page, 50000.0);

    // Animate to index 4. The nearest virtual page is 49999 (1 page back) instead of 50004 (4 pages forward).
    controller.animateTo(4);
    await tester.pumpAndSettle();

    expect(pageView.controller!.page, 49999.0);
    expect(pageChangedIndex, 4);

    // Animate to index 1. Nearest virtual page from 49999 is 50001 (2 pages forward) instead of 49996 (3 pages back).
    controller.animateTo(1);
    await tester.pumpAndSettle();

    expect(pageView.controller!.page, 50001.0);
    expect(pageChangedIndex, 1);
  });

  testWidgets('CoverflowCarousel infinite scroll does not throw RangeError when accessing lists in itemBuilder',
      (WidgetTester tester) async {
    final list = ['A', 'B', 'C', 'D', 'E']; // Length 5

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoverflowCarousel.builder(
            itemCount: list.length,
            itemWidth: 200,
            itemHeight: 300,
            isInfinite: true,
            initialPage: 0,
            itemBuilder: (context, index) {
              // This would throw RangeError if index was virtual (e.g. 5000) instead of mapped (0-4)
              return Text(list[index]);
            },
          ),
        ),
      ),
    );

    // Verify it renders successfully and we can see items
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('CoverflowCarousel entry animations build successfully and progress',
      (WidgetTester tester) async {
    for (final animation in CoverflowEntryAnimation.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoverflowCarousel.builder(
              key: UniqueKey(),
              itemCount: 5,
              itemWidth: 200,
              itemHeight: 300,
              entryAnimation: animation,
              entryAnimationDuration: const Duration(milliseconds: 100),
              itemBuilder: (context, index) {
                return Text('Item $index');
              },
            ),
          ),
        ),
      );

      // Verify the widget tree builds correctly for this animation
      expect(find.text('Item 0'), findsOneWidget);

      // Let the entry animation complete
      await tester.pumpAndSettle();
    }
  });

  testWidgets('CoverflowCarousel renders custom centerOverlayBuilder and handles clicks',
      (WidgetTester tester) async {
    int overlayTappedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoverflowCarousel.builder(
            itemCount: 3,
            itemWidth: 200,
            itemHeight: 300,
            initialPage: 0,
            centerOverlayBuilder: (context, index) {
              return ElevatedButton(
                key: Key('overlay-$index'),
                onPressed: () {
                  overlayTappedIndex = index;
                },
                child: Text('Play $index'),
              );
            },
            itemBuilder: (context, index) {
              return Text('Item $index');
            },
          ),
        ),
      ),
    );

    // Centered card (index 0) overlay should exist and be clickable
    expect(find.byKey(const Key('overlay-0')), findsOneWidget);
    await tester.tap(find.byKey(const Key('overlay-0')));
    await tester.pump();
    expect(overlayTappedIndex, 0);

    // Background card (index 1) overlay should not be built since overlayOpacity is 0.0
    expect(find.byKey(const Key('overlay-1')), findsNothing);
  });

  testWidgets('CoverflowCarousel supports direct Positioned return in centerOverlayBuilder',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoverflowCarousel.builder(
            itemCount: 3,
            itemWidth: 200,
            itemHeight: 300,
            initialPage: 0,
            centerOverlayBuilder: (context, index) {
              return Positioned(
                top: 25,
                left: 35,
                width: 50,
                height: 50,
                child: Container(
                  key: const Key('positioned-overlay'),
                  color: Colors.red,
                ),
              );
            },
            itemBuilder: (context, index) {
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );

    // Positioned child should exist
    final containerFinder = find.byKey(const Key('positioned-overlay'));
    expect(containerFinder, findsOneWidget);

    // Verify its size is exactly 50x50 (it does not expand to the full 200x300 card)
    final size = tester.getSize(containerFinder);
    expect(size.width, 50.0);
    expect(size.height, 50.0);
  });

  testWidgets('CoverflowCarousel handles mouse scroll wheel correctly',
      (WidgetTester tester) async {
    int pageChangedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoverflowCarousel.builder(
            itemCount: 5,
            itemWidth: 200,
            itemHeight: 300,
            initialPage: 0,
            onPageChanged: (index) {
              pageChangedIndex = index;
            },
            itemBuilder: (context, index) {
              return Text('Item $index');
            },
          ),
        ),
      ),
    );

    // Initial index is 0
    expect(find.text('Item 0'), findsOneWidget);

    final carouselCenter = tester.getCenter(find.byType(CoverflowCarousel));
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    pointer.hover(carouselCenter);

    // Send PointerScrollEvent for scrolling forward (dy > 0)
    await tester.sendEventToBinding(
      pointer.scroll(const Offset(0, 100)),
    );
    await tester.pumpAndSettle();

    // Verify it changed to page 1
    expect(pageChangedIndex, 1);

    // Wait for cooldown throttle (350ms - 50ms = 300ms)
    await tester.pump(const Duration(milliseconds: 310));

    // Send PointerScrollEvent for scrolling backward (dy < 0)
    await tester.sendEventToBinding(
      pointer.scroll(const Offset(0, -100), timeStamp: const Duration(milliseconds: 500)),
    );
    await tester.pumpAndSettle();

    // Verify it changed back to 0
    expect(pageChangedIndex, 0);
  });

  testWidgets('CoverflowCarousel supports 3D Hover Tilt',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoverflowCarousel.builder(
            itemCount: 3,
            itemWidth: 200,
            itemHeight: 300,
            initialPage: 0,
            enableHoverTilt: true,
            maxHoverTiltAngle: 0.2,
            itemBuilder: (context, index) {
              return Text('Item $index');
            },
          ),
        ),
      ),
    );

    final itemCenter = tester.getCenter(find.text('Item 0'));
    final pointer = TestPointer(1, PointerDeviceKind.mouse);

    // Enter and hover offset on active item
    await tester.sendEventToBinding(
      pointer.hover(itemCenter + const Offset(50, -50)),
    );
    await tester.pump();

    // Exit hover
    await tester.sendEventToBinding(
      pointer.hover(const Offset(0, 0)),
    );
    await tester.pumpAndSettle();
  });
}

