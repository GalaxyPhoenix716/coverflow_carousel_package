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

<p align="center">
  <img src="assets/coverflow_carousel_demo.gif" width="350" alt="Coverflow Carousel Demo">
</p>

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

## ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| itemCount | int | Number of carousel items |
| itemBuilder | IndexedWidgetBuilder | Builds each carousel item |
| itemWidth | double | Width of the focused card |
| itemHeight | double | Height of the focused card |
| visibleDistance | double | Number of visible cards around the focused item |
| nearCardSpacing | double | Spacing for adjacent cards |
| farCardSpacing | double | Spacing for distant cards |
| skewAngle | double | Card rotation angle |
| perspective | double | 3D perspective intensity |
| obscure | double | Blur intensity for side cards |
| controller | CoverflowCarouselController? | External carousel controller |
| animationDuration | Duration | Navigation animation duration |
| animationCurve | Curve | Navigation animation curve |

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
