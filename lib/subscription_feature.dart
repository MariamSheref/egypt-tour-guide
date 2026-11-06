// subscription_feature.dart
// Smart Heritage – Subscription flow (prototype)
//
// pubspec.yaml:  shared_preferences: ^2.2.0
// main():        WidgetsFlutterBinding.ensureInitialized();
//                await SubscriptionService.instance.load();
//
// NOTE: This is a PROTOTYPE. No real payment is processed.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_feature.dart';

const kBrown = Color(0xFF7A5518);
const kNavy = Color(0xFF12305B);

// ───────────────────────── Plans ─────────────────────────

class Plan {
  final String id, name, tagline;
  final int priceEgp;
  final List<String> features;
  final bool recommended;
  const Plan(
    this.id,
    this.name,
    this.tagline,
    this.priceEgp,
    this.features, {
    this.recommended = false,
  });
}

const plans = <Plan>[
  Plan('basic', 'Explorer', 'Perfect for a single trip', 99, [
    '3 personalised journey plans / month',
    'Smart recommendations by interests',
    'VR preview for 5 places / month',
    'Opening times & verified info',
  ]),
  Plan('premium', 'Pharaoh', 'Everything, unlimited', 199, [
    'Unlimited journey plans',
    'Smart recommendations by interests',
    'Unlimited VR previews',
    'Offline access to your itinerary',
    'Priority support',
  ], recommended: true),
];

// ───────────────────────── State ─────────────────────────

class SubscriptionService extends ChangeNotifier {
  SubscriptionService._();
  static final instance = SubscriptionService._();
  static const trialDays = 7;

  DateTime? _trialStart;
  String? _planId;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final t = p.getString('trial_start');
    _trialStart = t == null ? null : DateTime.tryParse(t);
    _planId = p.getString('plan_id');
    notifyListeners();
  }

  bool get isSubscribed => _planId != null;
  bool get trialUsed => _trialStart != null;

  int get trialDaysLeft {
    if (_trialStart == null) return 0;
    final left = _trialStart!
        .add(const Duration(days: trialDays))
        .difference(DateTime.now());
    return left.isNegative ? 0 : (left.inHours / 24).ceil();
  }

  bool get isTrialActive => trialUsed && !isSubscribed && trialDaysLeft > 0;

  /// Can the user use "Plan My Journey" & other premium features?
  bool get hasAccess => isSubscribed || isTrialActive;

  Future<void> startTrial() async {
    if (trialUsed) return;
    _trialStart = DateTime.now();
    final p = await SharedPreferences.getInstance();
    await p.setString('trial_start', _trialStart!.toIso8601String());
    notifyListeners();
  }

  Future<void> subscribe(String planId) async {
    _planId = planId;
    final p = await SharedPreferences.getInstance();
    await p.setString('plan_id', planId);
    notifyListeners();
  }
}

// ───────────────────── Entry points ─────────────────────

bool _promoShownThisSession = false;

/// Call once from HomePage.initState():
///   WidgetsBinding.instance.addPostFrameCallback((_) => maybeShowSubscribePromo(context));
Future<void> maybeShowSubscribePromo(BuildContext context) async {
  final s = SubscriptionService.instance;
  if (_promoShownThisSession || s.isSubscribed || !context.mounted) return;
  // Only show the subscription promo AFTER the user has signed up / logged in.
  await AuthService.instance.ensureLoaded();
  if (!AuthService.instance.isLoggedIn) return;
  if (!context.mounted) return;
  _promoShownThisSession = true;
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => _SheetBody(
      icon: Icons.workspace_premium_rounded,
      title: 'Unlock Smart Heritage',
      message: s.isTrialActive
          ? 'Your free trial has ${s.trialDaysLeft} day(s) left. Subscribe to keep all features.'
          : 'Subscribe to a plan to build personalised journeys and preview places in VR.',
      button: 'See plans',
      onPressed: () {
        Navigator.pop(ctx);
        openPlans(context);
      },
    ),
  );
}

/// Use before any premium action (e.g. Plan My Journey):
///   onTap: () async { if (await requireAccess(context)) { /* go to questionnaire */ } }
Future<bool> requireAccess(BuildContext context) async {
  // 1) must be logged in (opens Sign up / Log in page for new users)
  if (!await requireLogin(context)) return false;
  if (!context.mounted) return false;
  // 2) must have an active trial or subscription
  final s = SubscriptionService.instance;
  if (s.hasAccess) return true;
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => _SheetBody(
      icon: Icons.lock_outline_rounded,
      title: 'Upgrade to continue',
      message: s.trialUsed
          ? 'Your 7-day free trial has ended. Upgrade to keep planning your journeys.'
          : 'Planning a journey is a premium feature. Upgrade or start your free trial.',
      button: 'Upgrade',
      onPressed: () {
        Navigator.pop(ctx);
        openPlans(context);
      },
    ),
  );
  return false;
}

void openPlans(BuildContext context) => Navigator.of(
  context,
).push(MaterialPageRoute(builder: (_) => const SubscriptionPlansPage()));

class _SheetBody extends StatelessWidget {
  final IconData icon;
  final String title, message, button;
  final VoidCallback onPressed;
  const _SheetBody({
    required this.icon,
    required this.title,
    required this.message,
    required this.button,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: kNavy,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),
          _PrimaryButton(label: button, onPressed: onPressed),
        ],
      ),
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  const _PrimaryButton({
    required this.label,
    this.onPressed,
    this.color = kNavy,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 50,
    child: FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

// ───────────────────── Plans page ─────────────────────

class SubscriptionPlansPage extends StatelessWidget {
  const SubscriptionPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = SubscriptionService.instance;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kNavy,
        title: const Text('Choose your plan'),
      ),
      body: ListenableBuilder(
        listenable: s,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Upgrade for more access',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: kNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cancel anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            for (final p in plans) ...[
              _PlanCard(plan: p),
              const SizedBox(height: 16),
            ],
            if (!s.trialUsed && !s.isSubscribed) _TrialSection(),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Plan plan;
  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isCurrent =
        SubscriptionService.instance.isSubscribed &&
        SubscriptionService.instance._planId == plan.id;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: plan.recommended ? kBrown : Colors.grey.shade300,
          width: plan.recommended ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.recommended)
            const Text(
              'RECOMMENDED',
              style: TextStyle(
                color: kBrown,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          Text(
            plan.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: kNavy,
            ),
          ),
          Text(plan.tagline, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'EGP ${plan.priceEgp}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: kBrown,
                ),
              ),
              const Text(' /mo', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          _PrimaryButton(
            label: isCurrent ? 'Current plan' : 'Get ${plan.name}',
            color: plan.recommended ? kBrown : kNavy,
            onPressed: isCurrent
                ? null
                : () async {
                    // must be logged in before choosing / paying for a plan
                    if (!await requireLogin(context)) return;
                    if (!context.mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CheckoutPage(plan: plan),
                      ),
                    );
                  },
          ),
          const SizedBox(height: 16),
          for (final f in plan.features)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, size: 18, color: kBrown),
                  const SizedBox(width: 8),
                  Expanded(child: Text(f)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TrialSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('OR', style: TextStyle(color: Colors.grey.shade600)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: kNavy,
            side: const BorderSide(color: kNavy),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          icon: const Icon(Icons.card_giftcard),
          label: const Text('Try free for 7 days'),
          onPressed: () async {
            // must be logged in before starting the free trial
            if (!await requireLogin(context)) return;
            if (!context.mounted) return;
            await SubscriptionService.instance.startTrial();
            if (!context.mounted) return;
            Navigator.of(
              context,
            ).popUntil((r) => r.settings.name == '/home' || r.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your 7-day free trial has started 🎉'),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'No payment needed. Full access for 7 days.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
      const SizedBox(height: 24),
    ],
  );
}

// ───────────────────── Checkout page ─────────────────────

class CheckoutPage extends StatefulWidget {
  final Plan plan;
  const CheckoutPage({super.key, required this.plan});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _form = GlobalKey<FormState>();
  bool _save = true, _busy = false;

  double get _vat => widget.plan.priceEgp * 0.14;
  double get _total => widget.plan.priceEgp + _vat;

  Future<void> _complete() async {
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 900)); // fake processing
    await SubscriptionService.instance.subscribe(widget.plan.id);
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.check_circle, color: kBrown, size: 56),
        title: const Text('You\'re subscribed!'),
        content: Text(
          'Welcome to ${widget.plan.name}. Enjoy all features.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Start'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(
      context,
    ).popUntil((r) => r.settings.name == '/home' || r.isFirst);
  }

  Future<void> _applePay() async {
    final paid = await showDialog<bool>(
      context: context,
      builder: (_) => const ApplePayDialog(),
    );
    if (paid == true) _complete();
  }

  void _subscribe() {
    if (_form.currentState!.validate()) _complete();
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('Configure your plan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pay with',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _busy ? null : _applePay,
                  icon: const Icon(Icons.apple, color: Colors.white),
                  label: const Text(
                    'Pay',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                decoration: _dec('Card number', icon: Icons.credit_card),
                validator: (v) => (v ?? '').replaceAll(' ', '').length == 16
                    ? null
                    : 'Enter a valid 16-digit card number',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryFormatter(),
                      ],
                      decoration: _dec('Expiration date (MM/YY)'),
                      validator: _validateExpiry,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: _dec(
                        'Security code',
                        icon: Icons.lock_outline,
                      ),
                      validator: (v) =>
                          (v ?? '').length >= 3 ? null : 'Invalid',
                    ),
                  ),
                ],
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _save,
                onChanged: (v) => setState(() => _save = v ?? false),
                title: const Text(
                  'Save payment details for future purchases.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${plan.name} plan',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _row(
                      'Monthly subscription',
                      'EGP ${plan.priceEgp.toStringAsFixed(2)}',
                    ),
                    _row('VAT (14%)', 'EGP ${_vat.toStringAsFixed(2)}'),
                    const Divider(height: 24),
                    _row(
                      'Due today',
                      'EGP ${_total.toStringAsFixed(2)}',
                      bold: true,
                    ),
                    const SizedBox(height: 14),
                    _PrimaryButton(
                      label: _busy ? 'Processing…' : 'Subscribe',
                      color: Colors.black,
                      onPressed: _busy ? null : _subscribe,
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

  String? _validateExpiry(String? v) {
    final t = (v ?? '');
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(t)) return 'MM/YY';
    final m = int.parse(t.substring(0, 2)),
        y = 2000 + int.parse(t.substring(3));
    if (m < 1 || m > 12) return 'Invalid month';
    final now = DateTime.now();
    if (y < now.year || (y == now.year && m < now.month)) return 'Expired';
    return null;
  }

  Widget _row(String a, String b, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          a,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: bold ? Colors.black : Colors.grey.shade700,
          ),
        ),
        Text(
          b,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    ),
  );

  InputDecoration _dec(String hint, {IconData? icon}) => InputDecoration(
    labelText: hint,
    suffixIcon: icon == null ? null : Icon(icon, color: Colors.grey),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
  );
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    final d = n.text.replaceAll(' ', '');
    final b = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i > 0 && i % 4 == 0) b.write(' ');
      b.write(d[i]);
    }
    return TextEditingValue(
      text: b.toString(),
      selection: TextSelection.collapsed(offset: b.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    final d = n.text.replaceAll('/', '');
    final t = d.length > 2 ? '${d.substring(0, 2)}/${d.substring(2)}' : d;
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}

// ───────────────────── Apple Pay dialog ─────────────────────

class ApplePayDialog extends StatelessWidget {
  const ApplePayDialog({super.key});

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                width: 190,
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(190, 190),
                      painter: _RingsPainter(),
                    ),
                    Container(
                      width: 62,
                      height: 62,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.apple, color: Colors.white, size: 20),
                          Text(
                            'Pay',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Scan Code with iPhone',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Use the Camera app to continue your Apple Pay purchase on your iPhone. Requires iOS 18 or later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            // Prototype only – simulates the user finishing payment on iPhone.
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Simulate payment completed (demo)'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final rnd = math.Random(7);
    for (var ring = 0; ring < 6; ring++) {
      final r = 42.0 + ring * 10.5;
      var a = rnd.nextDouble() * math.pi;
      final end = a + 2 * math.pi;
      while (a < end) {
        final sweep = 0.15 + rnd.nextDouble() * 0.35;
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 5
          ..color = rnd.nextBool() ? Colors.black : Colors.grey.shade500;
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: r),
          a,
          sweep,
          false,
          paint,
        );
        a += sweep + 0.14;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ───────────────── Profile status card + Upgrade button ─────────────────
// Usage inside ProfileScreen:  const SubscriptionStatusCard(),

class SubscriptionStatusCard extends StatelessWidget {
  const SubscriptionStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = SubscriptionService.instance;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final isPremium = s._planId == 'premium';
        String title, subtitle;
        String? button;

        if (s.isSubscribed) {
          final plan = plans.firstWhere((p) => p.id == s._planId);
          title = '${plan.name} plan';
          subtitle = isPremium
              ? 'You have full access to all features.'
              : 'Upgrade to unlock unlimited journeys and VR.';
          button = isPremium ? null : 'Upgrade';
        } else if (s.isTrialActive) {
          title = 'Free trial';
          subtitle =
              '${s.trialDaysLeft} day(s) left. Upgrade now to keep full access.';
          button = 'Upgrade';
        } else if (s.trialUsed) {
          title = 'Trial ended';
          subtitle = 'Upgrade to keep planning your journeys.';
          button = 'Upgrade';
        } else {
          title = 'No active plan';
          subtitle = 'Start a free trial or choose a plan.';
          button = 'Upgrade';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [kNavy, Color(0xFF1F4A85)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xffffcc87),
                size: 34,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (button != null) ...[
                const SizedBox(width: 10),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xffffcc87),
                    foregroundColor: kNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => openPlans(context),
                  child: Text(button),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
