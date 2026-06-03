import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    await tester.tap(find.byKey(const Key('card-1')));
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
}
