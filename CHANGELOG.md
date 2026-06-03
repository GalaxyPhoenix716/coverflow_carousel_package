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

1. **Infinite Scroll (Looping)**: Added `isInfinite` support for seamless circular scrolling and shortest-path programmatic animations.
2. **Card Interactivity**: Side-cards now support click-to-focus, and centered cards are fully interactive (clicks pass to inner buttons without interference).
3. **Web & Desktop Dragging**: Enabled mouse click-and-drag swiping on Web and Desktop.
4. **Scrollbar Suppression**: Disabled the native scrollbar from drawing behind cards.
5. **Custom Viewport Fraction**: Added `viewportFraction` property supporting dynamic hot updates.
6. **Optimized BackdropFilter**: Blur filters are only drawn when active, improving GPU rendering.
7. **Testing**: Built a full suite of 9 widget tests verifying all layouts, gestures, and controllers.