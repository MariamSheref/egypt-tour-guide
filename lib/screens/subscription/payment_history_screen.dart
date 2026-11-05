import 'package:flutter/material.dart';
import '../../services/payment_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});
  @override State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}
class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final _controller = TextEditingController();
  String _status = 'Enter the order reference to check its verified payment status.';
  bool _busy = false;
  @override void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && _controller.text.isEmpty) _controller.text=arg;
  }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  Future<void> _refresh() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _busy=true);
    try {
      final result=await PaymentService().status(_controller.text.trim());
      if (mounted) setState(() => _status = result['status'] == 'paid'
        ? 'Payment verified. Access until: ${result['access_until']}'
        : 'Status: ${result['status']}. Checkout alone does not mean payment succeeded.');
    } catch (e) { if (mounted) setState(() => _status='Unable to check status: $e'); }
    finally { if (mounted) setState(() => _busy=false); }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Payment status')),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      const Icon(Icons.receipt_long, size: 60), const SizedBox(height: 16),
      Text(_status, textAlign: TextAlign.center), const SizedBox(height: 20),
      TextField(controller: _controller, decoration: const InputDecoration(
        border: OutlineInputBorder(), labelText: 'Order reference')),
      const SizedBox(height: 14),
      FilledButton(onPressed: _busy ? null : _refresh,
        child: Text(_busy ? 'Checking...' : 'Check verified payment status')),
      const SizedBox(height: 16),
      const Text('Order references are shown after checkout. Payment history across devices and subscriber entitlements require authenticated user accounts, not yet implemented.'),
    ]),
  );
}
