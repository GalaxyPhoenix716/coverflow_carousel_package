import 'package:flutter/material.dart';
import 'package:coverflow_carousel/coverflow_carousel.dart';

void main() {
  runApp(const CoverflowCarouselExampleApp());
}

class CoverflowCarouselExampleApp extends StatelessWidget {
  const CoverflowCarouselExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coverflow Carousel Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.pinkAccent,
        ),
      ),
      home: const CoverflowDemoScreen(),
    );
  }
}

class CoverflowDemoScreen extends StatefulWidget {
  const CoverflowDemoScreen({super.key});

  @override
  State<CoverflowDemoScreen> createState() => _CoverflowDemoScreenState();
}

class _CoverflowDemoScreenState extends State<CoverflowDemoScreen> {
  final CoverflowCarouselController _controller = CoverflowCarouselController();

  // Carousel Configurations
  bool _isInfinite = true;
  double _obscure = 0.4;
  double _viewportFraction = 0.28;
  CoverflowEntryAnimation _entryAnimation = CoverflowEntryAnimation.stack;
  int _activePage = 0;

  // Re-keying widget to easily trigger entry animation reload
  Key _carouselKey = UniqueKey();

  // Demo card colors & content
  final List<Map<String, dynamic>> _demoCards = [
    {
      'title': 'Nebula Voyage',
      'subtitle': 'Explore cosmic horizons',
      'colors': [Colors.deepPurple, Colors.pink],
      'icon': Icons.rocket_launch,
    },
    {
      'title': 'Oceanic Abyss',
      'subtitle': 'Deep sea discoveries',
      'colors': [Colors.blue, Colors.cyan],
      'icon': Icons.sailing,
    },
    {
      'title': 'Sunset Dunes',
      'subtitle': 'Warm desert winds',
      'colors': [Colors.orange, Colors.red],
      'icon': Icons.wb_sunny,
    },
    {
      'title': 'Forest Oasis',
      'subtitle': 'Ancient whispering woods',
      'colors': [Colors.teal, Colors.green],
      'icon': Icons.forest,
    },
    {
      'title': 'Aurora Sky',
      'subtitle': 'Northern lights dance',
      'colors': [Colors.purple, Colors.indigo],
      'icon': Icons.ac_unit,
    },
  ];

  void _reloadCarousel() {
    setState(() {
      _carouselKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coverflow Carousel Demo'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. The Coverflow Carousel Container
              SizedBox(
                height: 380,
                child: Center(
                  child: CoverflowCarousel.builder(
                    key: _carouselKey,
                    controller: _controller,
                    itemCount: _demoCards.length,
                    itemWidth: 260,
                    itemHeight: 280,
                    visibleItems: 3,
                    isInfinite: _isInfinite,
                    obscure: _obscure,
                    viewportFraction: _viewportFraction,
                    entryAnimation: _entryAnimation,
                    entryAnimationDuration: const Duration(milliseconds: 1000),
                    entryAnimationCurve: Curves.easeOutBack,
                    onPageChanged: (index) {
                      setState(() {
                        _activePage = index;
                      });
                    },
                    centerOverlayBuilder: (context, index) {
                      return Positioned(
                        right: 130 - 28 - 8,
                        bottom: -30,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Material(
                            color: Colors.pinkAccent,
                            shape: const CircleBorder(),
                            elevation: 8,
                            child: IconButton(
                              icon: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Playing: ${_demoCards[index]['title']}',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    itemBuilder: (context, index) {
                      final card = _demoCards[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: card['colors'] as List<Color>,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (card['colors'] as List<Color>).first
                                  .withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              // Glassmorphic top glow overlay
                              Positioned(
                                top: -50,
                                left: -50,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.bottomLeft,
                                  child: SizedBox(
                                    width:
                                        228, // itemWidth 260 minus horizontal padding 32
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          card['icon'],
                                          size: 44,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          card['title'] as String,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          card['subtitle'],
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Active Page Indicator
              Text(
                'Focused Index: $_activePage',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              const SizedBox(height: 16),

              // 2. Programmatic Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[850],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => _controller.previous(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Prev'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[850],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => _controller.next(),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 3. Configurations Card Panel
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF161522),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Interactive Configurations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24, color: Colors.grey),

                    // Infinite Scroll Toggle
                    SwitchListTile(
                      title: const Text('Infinite Scroll'),
                      subtitle: const Text('Enable wrap-around page looping'),
                      value: _isInfinite,
                      activeThumbColor: Colors.deepPurpleAccent,
                      onChanged: (val) {
                        setState(() {
                          _isInfinite = val;
                        });
                      },
                    ),

                    // Obscure Blur Slider
                    ListTile(
                      title: const Text('Obscure Blur Intensity'),
                      subtitle: Slider(
                        value: _obscure,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        activeColor: Colors.deepPurpleAccent,
                        label: _obscure.toStringAsFixed(1),
                        onChanged: (val) {
                          setState(() {
                            _obscure = val;
                          });
                        },
                      ),
                    ),

                    // Viewport Fraction Slider
                    ListTile(
                      title: const Text('Viewport Fraction (Drag Area)'),
                      subtitle: Slider(
                        value: _viewportFraction,
                        min: 0.15,
                        max: 0.45,
                        activeColor: Colors.deepPurpleAccent,
                        label: _viewportFraction.toStringAsFixed(2),
                        onChanged: (val) {
                          setState(() {
                            _viewportFraction = val;
                          });
                        },
                      ),
                    ),

                    // Entry Animation Selection Dropdown
                    ListTile(
                      title: const Text('Entry Animation'),
                      trailing: SizedBox(
                        width: 140,
                        child: DropdownButton<CoverflowEntryAnimation>(
                          isExpanded: true,
                          value: _entryAnimation,
                          underline: const SizedBox(),
                          onChanged: (CoverflowEntryAnimation? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _entryAnimation = newValue;
                              });
                              _reloadCarousel();
                            }
                          },
                          items: CoverflowEntryAnimation.values.map((anim) {
                            return DropdownMenuItem<CoverflowEntryAnimation>(
                              value: anim,
                              child: Text(
                                anim.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.pinkAccent,
                        ),
                        onPressed: _reloadCarousel,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Re-trigger Entry Animation'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
