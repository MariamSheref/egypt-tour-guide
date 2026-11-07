import 'dart:math' as math;

import 'package:flutter/material.dart';

/// ألوان هوية Kemetra (هنستخدمها في كل الشاشات الجاية: تسجيل الدخول، الباقات...)
class KemetraColors {
  static const navy = Color(0xFF12294A);
  static const gold = Color(0xFFD9A441);
  static const goldLight = Color(0xFFF1D9A6);
  static const goldDark = Color(0xFFB98427);
  static const teal = Color(0xFF1F8A92);
  static const tealDark = Color(0xFF0E5E6A);
  static const cream = Color(0xFFFBF7EF);
}

void _fillPoly(Canvas canvas, List<Offset> pts, Color color) {
  final path = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (final p in pts.skip(1)) {
    path.lineTo(p.dx, p.dy);
  }
  path.close();
  canvas.drawPath(path, Paint()..color = color);
}

// ---------------------------------------------------------------------------
// لوجو الدبوس (شمس + أهرامات + نهر)
// ---------------------------------------------------------------------------
class KemetraLogo extends StatelessWidget {
  final double width;
  const KemetraLogo({super.key, this.width = 150});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width * 1.25),
      painter: _LogoPainter(),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // بنرسم على مساحة 100 x 125 وبعدين نكبّرها/نصغّرها حسب الحجم
    canvas.save();
    canvas.scale(size.width / 100, size.height / 125);

    // شكل الدبوس
    final pin = Path()
      ..moveTo(50, 125)
      ..cubicTo(18, 88, 0, 70, 0, 50)
      ..arcTo(
        Rect.fromCircle(center: const Offset(50, 50), radius: 50),
        math.pi,
        math.pi,
        false,
      )
      ..cubicTo(100, 70, 82, 88, 50, 125)
      ..close();
    canvas.clipPath(pin, doAntiAlias: true);

    // الخلفية الكحلي
    canvas.drawPaint(Paint()..color = KemetraColors.navy);

    // الشمس
    const sunCenter = Offset(50, 40);
    final sunRect = Rect.fromCircle(center: sunCenter, radius: 25);
    canvas.drawCircle(
      sunCenter,
      25,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3C969), Color(0xFFD9962B)],
        ).createShader(sunRect),
    );

    // الهرم الصغير (ورا)
    _fillPoly(canvas, const [Offset(60, 74), Offset(76, 54), Offset(79, 74)],
        KemetraColors.goldLight);
    _fillPoly(canvas, const [Offset(76, 54), Offset(94, 74), Offset(79, 74)],
        const Color(0xFFD3A95C));

    // الهرم الكبير (قدام)
    _fillPoly(canvas, const [Offset(18, 74), Offset(44, 40), Offset(50, 74)],
        KemetraColors.goldLight);
    _fillPoly(canvas, const [Offset(44, 40), Offset(74, 74), Offset(50, 74)],
        const Color(0xFFD3A95C));

    // المياه (الجزء التحتاني من الدبوس)
    const waterRect = Rect.fromLTRB(0, 72, 100, 125);
    canvas.drawRect(
      waterRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [KemetraColors.teal, KemetraColors.tealDark],
        ).createShader(waterRect),
    );

    // شريط الرمل
    final sand = Path()
      ..moveTo(0, 76)
      ..cubicTo(30, 70, 62, 88, 100, 78)
      ..lineTo(100, 88)
      ..cubicTo(62, 98, 30, 80, 0, 88)
      ..close();
    canvas.drawPath(
      sand,
      Paint()
        ..shader = const LinearGradient(
          colors: [KemetraColors.goldDark, Color(0xFFE9C77B)],
        ).createShader(const Rect.fromLTRB(0, 70, 100, 98)),
    );

    // النهر
    final river = Path()
      ..moveTo(28, 82)
      ..cubicTo(70, 80, 82, 96, 56, 101)
      ..cubicTo(34, 105, 48, 114, 50, 125);
    canvas.drawPath(
      river,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = KemetraColors.cream,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// كلمة KEMETRA + الشعار تحتها
// ---------------------------------------------------------------------------
class KemetraWordmark extends StatelessWidget {
  final double fontSize;
  final bool showTagline;

  const KemetraWordmark({
    super.key,
    this.fontSize = 36,
    this.showTagline = true,
  });

  Widget _line() => Container(
        width: 26,
        height: 1.5,
        color: KemetraColors.gold,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'KEMETRA',
          style: TextStyle(
            color: KemetraColors.navy,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: fontSize * 0.12,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _line(),
              const SizedBox(width: 10),
              const Text(
                'Explore Egypt Beyond Time',
                style: TextStyle(
                  color: KemetraColors.teal,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              _line(),
            ],
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// المنظر اللي تحت: أهرامات + كثبان + نهر
// ---------------------------------------------------------------------------
class KemetraLandscape extends StatelessWidget {
  const KemetraLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: CustomPaint(painter: _LandscapePainter()),
    );
  }
}

class _LandscapePainter extends CustomPainter {
  const _LandscapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset o(double x, double y) => Offset(x * w, y * h);

    // الهرم الصغير
    _fillPoly(canvas, [o(0.20, 0.68), o(0.38, 0.30), o(0.42, 0.68)],
        const Color(0xFFEBD3A0));
    _fillPoly(canvas, [o(0.38, 0.30), o(0.60, 0.68), o(0.42, 0.68)],
        const Color(0xFFD3A95C));

    // الهرم الكبير
    _fillPoly(canvas, [o(0.40, 0.72), o(0.70, 0.02), o(0.74, 0.72)],
        const Color(0xFFF1DDB0));
    _fillPoly(canvas, [o(0.70, 0.02), o(1.05, 0.72), o(0.74, 0.72)],
        const Color(0xFFD9B26A));

    // كثبان رمل
    final dune1 = Path()
      ..moveTo(0, h * 0.60)
      ..cubicTo(w * 0.12, h * 0.48, w * 0.30, h * 0.58, w * 0.50, h * 0.76)
      ..lineTo(w * 0.50, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(dune1, Paint()..color = const Color(0xFFE2B55A));

    final dune2 = Path()
      ..moveTo(0, h * 0.78)
      ..cubicTo(w * 0.20, h * 0.66, w * 0.45, h * 0.82, w * 0.72, h * 0.96)
      ..lineTo(w * 0.72, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(dune2, Paint()..color = const Color(0xFFC8922F));

    // موجة النهر
    final wave = Path()
      ..moveTo(0, h * 0.90)
      ..cubicTo(w * 0.30, h * 0.62, w * 0.62, h * 1.02, w, h * 0.58)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      wave,
      Paint()
        ..shader = const LinearGradient(
          colors: [KemetraColors.teal, KemetraColors.tealDark],
        ).createShader(Rect.fromLTWH(0, h * 0.5, w, h * 0.5)),
    );

    // خط فاتح على حافة الموجة
    final crest = Path()
      ..moveTo(0, h * 0.88)
      ..cubicTo(w * 0.30, h * 0.60, w * 0.62, h * 1.00, w, h * 0.56);
    canvas.drawPath(
      crest,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = KemetraColors.cream.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
