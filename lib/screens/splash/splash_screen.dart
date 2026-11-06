import 'package:flutter/material.dart';

/// KemetRa splash screen.
/// Shows the illustrated splash for a few seconds, then goes to /onboarding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.onFinish,
    this.duration = const Duration(milliseconds: 3500),
  });

  /// Optional. If null, the splash navigates to '/onboarding'.
  final VoidCallback? onFinish;
  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _asset = 'assets/images/splash_bg.png';
  static const _imageAspect = 590 / 1280;
  static const _sand = Color(0xFFF4D9BE);

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _fadeIn = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
  );
  late final Animation<double> _zoom = Tween<double>(
    begin: 1.10,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

  bool _started = false;

  void _finish() {
    if (!mounted) return;
    if (widget.onFinish != null) {
      widget.onFinish!();
    } else {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    precacheImage(const AssetImage(_asset), context).whenComplete(() {
      if (!mounted) return;
      _c.forward().whenComplete(_finish);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _sand,
      body: LayoutBuilder(
        builder: (context, box) {
          final isWide = box.maxWidth / box.maxHeight > 0.75;

          Widget art = AnimatedBuilder(
            animation: _c,
            builder: (_, child) => Opacity(
              opacity: _fadeIn.value,
              child: Transform.scale(scale: _zoom.value, child: child),
            ),
            child: Image.asset(
              _asset,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              filterQuality: FilterQuality.high,
            ),
          );

          if (isWide) {
            art = Center(
              child: AspectRatio(
                aspectRatio: _imageAspect,
                child: ClipRect(child: art),
              ),
            );
          } else {
            art = ClipRect(child: art);
          }
          return SizedBox.expand(child: art);
        },
      ),
    );
  }
}
