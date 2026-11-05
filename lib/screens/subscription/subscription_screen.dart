import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/payment_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _payment = PaymentService();
  bool? _configured;
  String _method = 'card';
  bool _working = false;

  static const plans = [
    ('explorer', 'Explorer', 99, 'Essential trip recommendations'),
    ('family', 'Family', 199, 'Family-oriented trip planning'),
    ('premium', 'Premium', 299, 'Extended planning experience'),
  ];

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final active = await _payment.isConfigured();
      if (mounted) setState(() => _configured = active);
    } catch (_) {
      if (mounted) setState(() => _configured = false);
    }
  }

  Future<void> _start(String plan) async {
    final key = GlobalKey<FormState>();
    final first = TextEditingController();
    final last = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    try {
      await showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
        title: const Text('Continue to secure checkout'),
        content: SizedBox(width: 360, child: Form(key: key, child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final input in [(first, 'First name'), (last, 'Last name'), (email, 'Email'), (phone, 'Phone')])
              Padding(padding: const EdgeInsets.only(bottom: 10), child: TextFormField(
                controller: input.$1,
                decoration: InputDecoration(labelText: input.$2),
                validator: (v) => v == null || v.trim().length < 2 ? 'Required' : null,
              )),
          ]),
        ))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: _working ? null : () async {
            if (!key.currentState!.validate()) return;
            Navigator.pop(dialogContext);
            setState(() => _working = true);
            try {
              final order = await _payment.checkout(plan: plan,
                firstName: first.text.trim(), lastName: last.text.trim(),
                email: email.text.trim(), phone: phone.text.trim());
              if (mounted) Navigator.pushNamed(context, '/payment-history', arguments: order);
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Checkout not completed: $e')));
            } finally {
              if (mounted) setState(() => _working = false);
            }
          }, child: const Text('Open hosted checkout')),
        ],
      ));
    } finally {
      first.dispose(); last.dispose(); email.dispose(); phone.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription & payment')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('7 days free', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          const SizedBox(height: 8),
          Text(user.hasAccess ? '${user.trialDaysRemaining} days remaining' : 'Your trial has ended'),
          const Text('No payment details needed to start. No automatic charges after the trial.'),
          const SizedBox(height: 8),
          const Text('Preview only: trial uses local device storage. A login and server-side subscription verification are required for release.',
            style: TextStyle(fontSize: 12, color: Colors.black54)),
        ]))),
        const SizedBox(height: 18),
        const Text('Choose a monthly plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        const Text('Example prices in EGP. Manual renewal every 30 days; not auto-renewing.'),
        for (final plan in plans) Card(margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(padding: const EdgeInsets.all(18), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(plan.$2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 21)),
              const SizedBox(height: 6),
              Text('${plan.$3} EGP / 30 days'),
              const SizedBox(height: 6), Text(plan.$4),
              const SizedBox(height: 10),
              FilledButton(onPressed: kIsWeb && _configured == true && !_working
                ? () => _start(plan.$1) : null,
                child: Text('Choose ${plan.$2}')),
            ]))),
        const SizedBox(height: 16),
        const Text('Preferred payment method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        RadioListTile<String>(title: const Text('Credit / debit card'),
          value: 'card', groupValue: _method, onChanged: (v) => setState(() => _method = v ?? _method)),
        RadioListTile<String>(title: const Text('Google Pay'),
          value: 'google', groupValue: _method, onChanged: (v) => setState(() => _method = v ?? _method)),
        RadioListTile<String>(title: const Text('Apple Pay'),
          value: 'apple', groupValue: _method, onChanged: (v) => setState(() => _method = v ?? _method)),
        const Text('The selected method is a preference only. Available options appear at the secure payment provider checkout, depending on device, region and merchant settings. This screen does not force or activate a wallet.',
          style: TextStyle(fontSize: 12)),
        const SizedBox(height: 14),
        if (!kIsWeb) const Card(child: Padding(padding: EdgeInsets.all(16),
          child: Text('Digital subscriptions on iOS / Google Play need the applicable in-app billing integration. External checkout is disabled in this mobile build.'))),
        if (_configured == false && kIsWeb) const Card(child: Padding(padding: EdgeInsets.all(16),
          child: Text('Paymob is not configured yet. Subscribe buttons stay disabled until merchant test keys and a public HTTPS callback are configured.'))),
      ]),
    );
  }
}
