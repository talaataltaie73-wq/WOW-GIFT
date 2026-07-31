import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ribbonController;
  late final AnimationController _giftBoxController;
  late final AnimationController _itemsController;
  late final AnimationController _taglineController;

  late final Animation<double> _ribbonProgress;
  late final Animation<double> _boxLidRotation;
  late final Animation<double> _itemsEmerge;
  late final Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();

    // Phase 1: Ribbons animate in (0 – 1.5 s)
    _ribbonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _ribbonProgress = CurvedAnimation(
      parent: _ribbonController,
      curve: Curves.easeInOut,
    );

    // Phase 2: Gift box opens, items emerge (1.5 – 3 s)
    _giftBoxController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _boxLidRotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -0.9).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.9, end: -1.0).chain(
          CurveTween(curve: Curves.elasticOut),
        ),
        weight: 40,
      ),
    ]).animate(_giftBoxController);

    _itemsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _itemsEmerge = CurvedAnimation(
      parent: _itemsController,
      curve: Curves.easeOutCubic,
    );

    // Phase 3: Tagline fades in (3 – 4 s)
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _taglineOpacity = CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeIn,
    );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    // Phase 1
    _ribbonController.forward();
    await Future.delayed(const Duration(milliseconds: 1500));

    // Phase 2
    _giftBoxController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _itemsController.forward();
    await Future.delayed(const Duration(milliseconds: 1100));

    // Phase 3
    _taglineController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _ribbonController.dispose();
    _giftBoxController.dispose();
    _itemsController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B2838),
              Color(0xFF0F766E),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background ribbon painter
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ribbonProgress,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _RibbonPainter(
                      progress: _ribbonProgress.value,
                      primaryColor: AppColors.primary,
                      accentColor: AppColors.accent,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),

            // Sparkle particles behind the gift box
            ..._buildSparkles(size),

            // Gift box + emerging items
            Positioned(
              top: size.height * 0.28,
              child: _buildGiftBoxSection(size),
            ),

            // "Wow Gift" text
            Positioned(
              top: size.height * 0.15,
              child: AnimatedBuilder(
                animation: _ribbonProgress,
                builder: (context, _) {
                  return Opacity(
                    opacity: _ribbonProgress.value,
                    child: Transform.scale(
                      scale: 0.8 + 0.2 * _ribbonProgress.value,
                      child: Text(
                        'Wow Gift',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [
                                AppColors.accent,
                                Color(0xFFF5E6A3),
                                AppColors.accent,
                              ],
                            ).createShader(
                              const Rect.fromLTWH(0, 0, 280, 60),
                            ),
                          letterSpacing: 3,
                          shadows: [
                            Shadow(
                              color: AppColors.accent.withValues(alpha: 0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Tagline
            Positioned(
              bottom: size.height * 0.15,
              child: AnimatedBuilder(
                animation: _taglineOpacity,
                builder: (context, _) {
                  return Opacity(
                    opacity: _taglineOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _taglineOpacity.value)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 1.5,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.accent.withValues(alpha: 0.0),
                                  AppColors.accent,
                                  AppColors.accent.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            'أهدي بطريقة تُبهر.',
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.95),
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.6),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 60,
                            height: 1.5,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.accent.withValues(alpha: 0.0),
                                  AppColors.accent,
                                  AppColors.accent.withValues(alpha: 0.0),
                                ],
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
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSparkles(Size screenSize) {
    final random = Random(42);
    return List.generate(18, (index) {
      final left = random.nextDouble() * screenSize.width;
      final top =
          screenSize.height * 0.25 + random.nextDouble() * screenSize.height * 0.45;
      final delay = 1500 + random.nextInt(2000);
      final sparkleSize = 3.0 + random.nextDouble() * 5.0;
      final isGold = index % 3 != 0;

      return Positioned(
        left: left,
        top: top,
        child: Container(
          width: sparkleSize,
          height: sparkleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isGold
                ? AppColors.accent.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.7),
            boxShadow: [
              BoxShadow(
                color: isGold
                    ? AppColors.accent.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        )
            .animate(
              delay: Duration(milliseconds: delay),
            )
            .fadeIn(duration: 400.ms)
            .then()
            .shimmer(
              duration: 1200.ms,
              color: Colors.white.withValues(alpha: 0.3),
            )
            .then()
            .fadeOut(duration: 600.ms),
      );
    });
  }

  Widget _buildGiftBoxSection(Size screenSize) {
    const boxWidth = 140.0;
    const boxHeight = 120.0;

    return SizedBox(
      width: boxWidth + 120,
      height: boxHeight + 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Emerging items (flowers, chocolates, ribbons)
          ..._buildEmergingItems(boxWidth, boxHeight),

          // Gift box body
          Positioned(
            bottom: 20,
            child: AnimatedBuilder(
              animation: _giftBoxController,
              builder: (context, _) {
                return Transform.scale(
                  scale: 1.0 + 0.03 * sin(_giftBoxController.value * pi),
                  child: _buildBoxBody(boxWidth, boxHeight),
                );
              },
            ),
          ),

          // Gift box lid
          Positioned(
            bottom: boxHeight + 10,
            child: AnimatedBuilder(
              animation: _boxLidRotation,
              builder: (context, _) {
                return Transform(
                  alignment: Alignment.bottomLeft,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateZ(_boxLidRotation.value),
                  child: _buildBoxLid(boxWidth),
                );
              },
            ),
          ),

          // Glow effect under the box
          Positioned(
            bottom: 0,
            child: AnimatedBuilder(
              animation: _itemsEmerge,
              builder: (context, _) {
                return Container(
                  width: boxWidth + 40,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent
                            .withValues(alpha: 0.3 * _itemsEmerge.value),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxBody(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB8860B),
            AppColors.accent,
            Color(0xFFF5E6A3),
            AppColors.accent,
          ],
          stops: [0.0, 0.3, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Vertical ribbon stripe
          Positioned(
            left: width / 2 - 10,
            top: 0,
            bottom: 0,
            child: Container(
              width: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.9),
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
          // Horizontal ribbon stripe
          Positioned(
            left: 0,
            right: 0,
            top: height / 2 - 10,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.8),
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),
          // Subtle shine overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.05),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxLid(double width) {
    const lidHeight = 30.0;
    return Container(
      width: width + 12,
      height: lidHeight,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB8860B),
            AppColors.accent,
            Color(0xFFF5E6A3),
            AppColors.accent,
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ribbon on lid
          Container(
            width: 20,
            height: lidHeight,
            color: AppColors.primary,
          ),
          // Bow
          Positioned(
            top: -14,
            child: _buildBow(),
          ),
        ],
      ),
    );
  }

  Widget _buildBow() {
    return SizedBox(
      width: 60,
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left loop
          Positioned(
            left: 0,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 28,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Right loop
          Positioned(
            right: 0,
            child: Transform.rotate(
              angle: 0.3,
              child: Container(
                width: 28,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.8),
                      AppColors.primary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Center knot
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEmergingItems(double boxWidth, double boxHeight) {
    // Each item: type, offsetX, offsetY at full emergence, color, size
    final items = <_EmergingItem>[
      // Flowers (petal clusters)
      _EmergingItem(
        type: _ItemType.flower,
        dx: -40,
        dy: -80,
        color: const Color(0xFFE91E63),
        size: 28,
      ),
      _EmergingItem(
        type: _ItemType.flower,
        dx: 35,
        dy: -100,
        color: const Color(0xFFFF5722),
        size: 24,
      ),
      _EmergingItem(
        type: _ItemType.flower,
        dx: 0,
        dy: -110,
        color: const Color(0xFFF48FB1),
        size: 22,
      ),
      // Chocolates (rounded squares)
      _EmergingItem(
        type: _ItemType.chocolate,
        dx: -55,
        dy: -55,
        color: const Color(0xFF5D4037),
        size: 18,
      ),
      _EmergingItem(
        type: _ItemType.chocolate,
        dx: 50,
        dy: -65,
        color: const Color(0xFF6D4C41),
        size: 16,
      ),
      _EmergingItem(
        type: _ItemType.chocolate,
        dx: 15,
        dy: -50,
        color: const Color(0xFF4E342E),
        size: 14,
      ),
      // Ribbon curls
      _EmergingItem(
        type: _ItemType.ribbon,
        dx: -30,
        dy: -95,
        color: AppColors.accent,
        size: 20,
      ),
      _EmergingItem(
        type: _ItemType.ribbon,
        dx: 45,
        dy: -85,
        color: AppColors.primary,
        size: 18,
      ),
      // Small hearts
      _EmergingItem(
        type: _ItemType.heart,
        dx: -20,
        dy: -120,
        color: const Color(0xFFE53935),
        size: 14,
      ),
      _EmergingItem(
        type: _ItemType.heart,
        dx: 25,
        dy: -130,
        color: const Color(0xFFEC407A),
        size: 12,
      ),
    ];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final staggerDelay = index * 0.08;

      return Positioned(
        bottom: 20 + boxHeight / 2,
        child: AnimatedBuilder(
          animation: _itemsEmerge,
          builder: (context, _) {
            final adjustedProgress =
                ((_itemsEmerge.value - staggerDelay) / (1.0 - staggerDelay))
                    .clamp(0.0, 1.0);
            final curvedProgress = Curves.easeOutBack.transform(adjustedProgress);

            return Transform.translate(
              offset: Offset(
                item.dx * curvedProgress,
                item.dy * curvedProgress,
              ),
              child: Opacity(
                opacity: adjustedProgress.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: curvedProgress,
                  child: Transform.rotate(
                    angle: (1 - curvedProgress) * pi * 0.5 * (index.isEven ? 1 : -1),
                    child: _buildItemWidget(item),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildItemWidget(_EmergingItem item) {
    switch (item.type) {
      case _ItemType.flower:
        return _buildFlower(item.size, item.color);
      case _ItemType.chocolate:
        return _buildChocolate(item.size, item.color);
      case _ItemType.ribbon:
        return _buildRibbonCurl(item.size, item.color);
      case _ItemType.heart:
        return _buildHeart(item.size, item.color);
    }
  }

  Widget _buildFlower(double size, Color color) {
    // A flower made of overlapping petal circles around a center
    final petalSize = size * 0.5;
    final offset = size * 0.25;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Petals at cardinal directions
          Positioned(
            top: 0,
            left: size / 2 - petalSize / 2,
            child: _petal(petalSize, color),
          ),
          Positioned(
            bottom: 0,
            left: size / 2 - petalSize / 2,
            child: _petal(petalSize, color),
          ),
          Positioned(
            left: 0,
            top: size / 2 - petalSize / 2,
            child: _petal(petalSize, color),
          ),
          Positioned(
            right: 0,
            top: size / 2 - petalSize / 2,
            child: _petal(petalSize, color),
          ),
          // Diagonal petals
          Positioned(
            top: offset * 0.3,
            left: offset * 0.3,
            child: _petal(petalSize * 0.9, color.withValues(alpha: 0.8)),
          ),
          Positioned(
            top: offset * 0.3,
            right: offset * 0.3,
            child: _petal(petalSize * 0.9, color.withValues(alpha: 0.8)),
          ),
          // Center
          Center(
            child: Container(
              width: petalSize * 0.7,
              height: petalSize * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFEB3B),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _petal(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildChocolate(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            Color.lerp(color, Colors.white, 0.2)!,
            color,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.3,
          height: size * 0.3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
      ),
    );
  }

  Widget _buildRibbonCurl(double size, Color color) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RibbonCurlPainter(color: color),
      ),
    );
  }

  Widget _buildHeart(double size, Color color) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HeartPainter(color: color),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ribbon Painter – draws animated curved paths forming decorative ribbons
// ---------------------------------------------------------------------------
class _RibbonPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color accentColor;

  _RibbonPainter({
    required this.progress,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final goldPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final primaryPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final thinGoldPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Ribbon path 1: sweeping S-curve from top-left
    _drawAnimatedPath(
      canvas,
      _buildRibbonPath1(size),
      goldPaint,
      progress,
    );

    // Ribbon path 2: sweeping curve from top-right
    _drawAnimatedPath(
      canvas,
      _buildRibbonPath2(size),
      primaryPaint,
      progress,
    );

    // Ribbon path 3: bottom-left decorative swirl
    _drawAnimatedPath(
      canvas,
      _buildRibbonPath3(size),
      thinGoldPaint,
      progress,
    );

    // Ribbon path 4: bottom-right accent
    _drawAnimatedPath(
      canvas,
      _buildRibbonPath4(size),
      primaryPaint..color = primaryColor.withValues(alpha: 0.35),
      progress,
    );

    // Ribbon path 5: central decorative loop
    if (progress > 0.3) {
      final centralProgress = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);
      _drawAnimatedPath(
        canvas,
        _buildCentralRibbon(size),
        goldPaint..strokeWidth = 2.0,
        centralProgress,
      );
    }
  }

  Path _buildRibbonPath1(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.15);
    path.cubicTo(
      size.width * 0.2, size.height * 0.05,
      size.width * 0.35, size.height * 0.25,
      size.width * 0.5, size.height * 0.18,
    );
    path.cubicTo(
      size.width * 0.65, size.height * 0.11,
      size.width * 0.8, size.height * 0.22,
      size.width, size.height * 0.12,
    );
    return path;
  }

  Path _buildRibbonPath2(Size size) {
    final path = Path();
    path.moveTo(size.width, size.height * 0.3);
    path.cubicTo(
      size.width * 0.75, size.height * 0.35,
      size.width * 0.6, size.height * 0.2,
      size.width * 0.45, size.height * 0.32,
    );
    path.cubicTo(
      size.width * 0.3, size.height * 0.44,
      size.width * 0.15, size.height * 0.28,
      0, size.height * 0.38,
    );
    return path;
  }

  Path _buildRibbonPath3(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.75);
    path.cubicTo(
      size.width * 0.15, size.height * 0.68,
      size.width * 0.25, size.height * 0.82,
      size.width * 0.4, size.height * 0.72,
    );
    path.cubicTo(
      size.width * 0.5, size.height * 0.65,
      size.width * 0.55, size.height * 0.78,
      size.width * 0.65, size.height * 0.7,
    );
    return path;
  }

  Path _buildRibbonPath4(Size size) {
    final path = Path();
    path.moveTo(size.width, size.height * 0.82);
    path.cubicTo(
      size.width * 0.85, size.height * 0.88,
      size.width * 0.7, size.height * 0.78,
      size.width * 0.55, size.height * 0.85,
    );
    path.cubicTo(
      size.width * 0.4, size.height * 0.92,
      size.width * 0.25, size.height * 0.82,
      size.width * 0.1, size.height * 0.9,
    );
    return path;
  }

  Path _buildCentralRibbon(Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final path = Path();
    path.moveTo(cx - 80, cy);
    path.cubicTo(
      cx - 60, cy - 40,
      cx - 20, cy + 30,
      cx, cy,
    );
    path.cubicTo(
      cx + 20, cy - 30,
      cx + 60, cy + 40,
      cx + 80, cy,
    );
    return path;
  }

  void _drawAnimatedPath(
    Canvas canvas,
    Path fullPath,
    Paint paint,
    double progress,
  ) {
    final metrics = fullPath.computeMetrics().toList();
    for (final metric in metrics) {
      final extractLength = metric.length * progress;
      final extracted = metric.extractPath(0, extractLength);
      canvas.drawPath(extracted, paint);
    }
  }

  @override
  bool shouldRepaint(_RibbonPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ---------------------------------------------------------------------------
// Ribbon curl painter for emerging items
// ---------------------------------------------------------------------------
class _RibbonCurlPainter extends CustomPainter {
  final Color color;

  _RibbonCurlPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height);
    path.cubicTo(
      size.width * 0.1, size.height * 0.5,
      size.width * 0.9, size.height * 0.6,
      size.width * 0.5, size.height * 0.1,
    );
    path.cubicTo(
      size.width * 0.3, size.height * 0.3,
      size.width * 0.8, size.height * 0.2,
      size.width * 0.7, size.height * 0.0,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Heart painter for emerging items
// ---------------------------------------------------------------------------
class _HeartPainter extends CustomPainter {
  final Color color;

  _HeartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.5, h * 0.35);
    path.cubicTo(w * 0.5, h * 0.25, w * 0.35, h * 0.0, w * 0.15, h * 0.15);
    path.cubicTo(w * -0.05, h * 0.3, w * 0.0, h * 0.6, w * 0.5, h);
    path.cubicTo(w, h * 0.6, w * 1.05, h * 0.3, w * 0.85, h * 0.15);
    path.cubicTo(w * 0.65, h * 0.0, w * 0.5, h * 0.25, w * 0.5, h * 0.35);
    path.close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------
enum _ItemType { flower, chocolate, ribbon, heart }

class _EmergingItem {
  final _ItemType type;
  final double dx;
  final double dy;
  final Color color;
  final double size;

  const _EmergingItem({
    required this.type,
    required this.dx,
    required this.dy,
    required this.color,
    required this.size,
  });
}
