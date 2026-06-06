## 1.0.0

1. Smooth 3D coverflow-style carousel

2. Customizable card dimensions

3. Adjustable overlap and spacing

4. Perspective and rotation effects

5. Smooth swipe navigation

6. Controller support

7. Programmatic navigation

8. Blur effects for non-focused cards

9. Responsive layout

10. Optimized rendering for large datasets

11. Builder-based API

# 1.0.1

1. Fixed README demo GIF link

# 1.1.0

1. **Infinite Scroll**: Added `isInfinite` support for seamless circular scrolling and shortest-path programmatic animations.
2. **Entry Animations**: Added `entryAnimation` parameter supporting staggered fades, zooms, spacing expansions, slides, and front-stacking (`fadeIn`, `scaleUp`, `spacingExpand`, `staggeredSlide`, `fadeScale`, and `stack`).
3. **Card Interactivity**: Side-cards now support click-to-focus, and centered cards are fully interactive (clicks pass to inner buttons without interference).
4. **Web & Desktop Dragging**: Enabled mouse click-and-drag swiping on Web and Desktop.
5. **Scrollbar Suppression**: Disabled the native scrollbar from drawing behind cards.
6. **Custom Viewport Fraction**: Added `viewportFraction` property supporting dynamic hot updates.
7. **Optimized BackdropFilter**: Blur filters are only drawn when active, improving GPU rendering.
8. **Testing**: Built a full suite of 10 widget tests verifying layouts, gestures, entry transitions, and controllers.
9. **Code Documentation**: Added 100% pub.dev public API coverage with detailed Dart doc comments (`///`) on all classes, properties, constructors, methods, and enums.
10. **Architecture & Mathematics Reference**: Added `package_documentation.md` containing detailed 3D transform projection matrices, spacing equations, gesture layers, and timeline stagger formulas.
11. **Lint Fixes**: Resolved unnecessary library name lint warnings in export declarations.

# 1.1.1

1. **Example Application**: Added a complete, interactive, and beautifully styled example application under `example/` demonstrating infinite scroll, entry animations, blur obscuring, and programmatic controllers.

# 1.1.2

1. Fixed swiping on mobile applications

