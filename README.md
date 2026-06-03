# Coverflow Carousel

A beautiful, highly customizable 3D coverflow-style carousel for Flutter.

Create immersive experiences with smooth perspective effects, overlapping cards, dynamic scaling, and effortless programmatic navigation.

Perfect for music apps, movie browsers, ecommerce showcases, galleries, portfolios, and modern mobile interfaces.

---

## ✨ Features

- 🎨 Smooth 3D coverflow-style design
- 📱 Responsive across different screen sizes
- 🔄 Swipe-based navigation
- 🏗️ Builder-based API for optimal performance
- 📏 Fully customizable card dimensions
- 📐 Adjustable overlap and spacing
- 🌊 Smooth animations and transitions
- 🧊 Optional blur effects for side cards
- 🎯 Configurable visible card count
- 🔀 Adjustable perspective and rotation
- 🎮 External controller support
- ⚡ Optimized rendering for large datasets
- ♻️ Reusable and production-ready

## 📸 Preview

![Coverflow Carousel Demo](assets/coverflow_carousel_demo.gif)

---

## 🚀 Installation

Add the package to your `pubspec.yaml`.

```yaml
dependencies:
  coverflow_carousel: ^1.0.0
```

OR

Run the command in the terminal in your project root

```
flutter pub add coverflow_carousel
```

Then run:

```
flutter pub get
```

## Basic Usage

```dart
CoverflowCarousel.builder(
    itemCount: 10, itemWidth: 250,
    itemHeight: 320,
    itemBuilder: (context, index) {
        return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.blue,
            ),
        );
    },
)
```

## Controller Support

Control the carousel from anywhere in your application.

```dart
final controller = CoverflowCarouselController();
```

```dart
CoverflowCarousel.builder(
  controller: controller,
  itemCount: items.length,
  itemWidth: 250,
  itemHeight: 320,
  itemBuilder: (context, index) {
    return MyCard(index: index);
  },
)
```

Navigate Programatically

```dart
controller.next();

controller.previous();

controller.animateTo(5);
```

## 🎬 Entry Animations

Make the carousel feel organic and alive when it first appears on the screen. Select from staggered fades, zoom scaling, spacing expansions, or horizontal slides.

```dart
CoverflowCarousel.builder(
  itemCount: items.length,
  itemWidth: 250,
  itemHeight: 320,
  entryAnimation: CoverflowEntryAnimation.stack, // Physical stacking effect fanning center-out!
  entryAnimationDuration: const Duration(milliseconds: 1000),
  entryAnimationCurve: Curves.easeOutCubic,
  itemBuilder: (context, index) {
    return MyCard(index: index);
  },
)
```

### Available Animation Types:

- `CoverflowEntryAnimation.none` (Default): Instantly mounts without animation.
- `CoverflowEntryAnimation.fadeIn`: Staggered opacity fade-in from the center outward.
- `CoverflowEntryAnimation.scaleUp`: Staggered zoom scale-up from the center outward.
- `CoverflowEntryAnimation.spacingExpand`: Cards fan out horizontally from a center stack.
- `CoverflowEntryAnimation.staggeredSlide`: Staggered slides in from left/right/top.
- `CoverflowEntryAnimation.fadeScale`: Smooth staggered zoom and fade combined.
- `CoverflowEntryAnimation.stack`: Physical stacking effect where cards scale down from the front fanning center-to-outside.

---

## ⚙️ Parameters

| Parameter              | Type                         | Description                                                         |
| :--------------------- | :--------------------------- | :------------------------------------------------------------------ |
| itemCount              | int                          | Number of carousel items                                            |
| itemBuilder            | IndexedWidgetBuilder         | Builds each carousel item                                           |
| itemWidth              | double                       | Width of the focused card                                           |
| itemHeight             | double                       | Height of the focused card                                          |
| visibleItems           | int                          | Number of visible cards on each side of focused item (default: `3`) |
| initialPage            | int                          | Initial focused page index (default: `0`)                           |
| nearCardSpacing        | double                       | Spacing for adjacent cards (default: `45`)                          |
| farCardSpacing         | double                       | Spacing for distant cards (default: `50`)                           |
| skewAngle              | double                       | Card rotation angle (default: `-0.35`)                              |
| perspective            | double                       | 3D perspective intensity (default: `0.0025`)                        |
| obscure                | double                       | Blur intensity for side cards (default: `0`)                        |
| controller             | CoverflowCarouselController? | External carousel controller                                        |
| animationDuration      | Duration                     | Navigation animation duration (default: `350ms`)                    |
| animationCurve         | Curve                        | Navigation animation curve (default: `Curves.easeOutCubic`)         |
| viewportFraction       | double                       | PageView swipe sensitivity and width ratio (default: `0.25`)        |
| isInfinite             | bool                         | Enable circular scrolling loop (default: `false`)                   |
| entryAnimation         | CoverflowEntryAnimation      | Entrance animation type (default: `.none`)                          |
| entryAnimationDuration | Duration                     | Entrance animation duration (default: `600ms`)                      |
| entryAnimationCurve    | Curve                        | Entrance animation curve (default: `Curves.easeOutCubic`)           |

---

## 💡 Perfect For

- 🎵 Music Applications
- 🎬 Movie & Streaming Platforms
- 🛍️ Ecommerce Product Showcases
- 🖼️ Galleries & Portfolios
- ✈️ Travel Applications
- 📚 Educational Apps
- 🎮 Gaming Interfaces
- 📱 Modern Mobile Experiences

---

## 🏆 Why Coverflow Carousel?

Unlike traditional carousels, Coverflow Carousel creates depth and focus through:

- 3D perspective transformations
- Dynamic card scaling
- Adjustable overlap layouts
- Smooth animations
- Responsive sizing
- Programmatic navigation

The result is a premium browsing experience that feels modern, immersive, and intuitive.

---

## Additional Information

Coverflow Carousel is designed to provide a beautiful and highly customizable 3D coverflow-style carousel experience for Flutter applications.

### ❗ Issues & Bug Reports

If you encounter a bug or unexpected behavior, please open an issue with:

- Flutter version
- Package version
- Steps to reproduce
- Expected behavior
- Screenshots or recordings (if applicable)

### 📥 Feature Requests

Suggestions and feature requests are always welcome. If you have an idea that could improve the package, feel free to create an issue describing the use case and proposed solution.

### 🤝 Contributing

Contributions are welcome. Whether it's fixing bugs, improving documentation, optimizing performance, or adding new features, pull requests are appreciated.

Before submitting a pull request:

1. Ensure the code follows Dart and Flutter best practices.
2. Test your changes thoroughly.
3. Update documentation when necessary.
4. Add examples for new features.

### ❓ Support

For questions, issues, or suggestions, please use the project's GitHub Issues page.

### 🛠️ Future Development

Planned improvements include:

- Infinite scrolling
- Entry animations
- Additional customization options
- More visual effects
- Performance optimizations

Thank you for using Coverflow Carousel!
