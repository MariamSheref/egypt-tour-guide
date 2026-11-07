// auth_feature.dart
// Smart Heritage – Sign up / Log in (prototype)
//
// PROTOTYPE ONLY: accounts are stored locally in the browser/device with
// shared_preferences. For a real app use a backend (Firebase Auth, etc.)
// and never store passwords on the device.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _navy = Color(0xFF12305B);
const _brown = Color(0xFF7A5518);

// ───────────────────────── State ─────────────────────────

class AuthService extends ChangeNotifier {
  AuthService._();
  static final instance = AuthService._();

  bool _loaded = false;
  Map<String, dynamic> _users = {}; // email -> {name, hash}
  String? _currentEmail;

  bool get isLoggedIn => _currentEmail != null;
  String? get email => _currentEmail;
  String get name =>
      _currentEmail == null ? '' : (_users[_currentEmail]?['name'] ?? '');

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('auth_users');
    _users = raw == null ? {} : Map<String, dynamic>.from(jsonDecode(raw));
    _currentEmail = p.getString('auth_current');
    _loaded = true;
    notifyListeners();
  }

  // Simple non-secure hash (prototype only).
  String _hash(String s) {
    var h = 5381;
    for (final c in s.codeUnits) {
      h = ((h << 5) + h + c) & 0x7fffffff;
    }
    return h.toString();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('auth_users', jsonEncode(_users));
    if (_currentEmail == null) {
      await p.remove('auth_current');
    } else {
      await p.setString('auth_current', _currentEmail!);
    }
  }

  /// Returns an error message, or null on success.
  Future<String?> signUp(String name, String email, String password) async {
    await ensureLoaded();
    final e = email.trim().toLowerCase();
    if (_users.containsKey(e)) return 'This email is already registered. Please log in.';
    _users[e] = {'name': name.trim(), 'hash': _hash(password)};
    _currentEmail = e;
    await _save();
    notifyListeners();
    return null;
  }

  /// Returns an error message, or null on success.
  Future<String?> logIn(String email, String password) async {
    await ensureLoaded();
    final e = email.trim().toLowerCase();
    final u = _users[e];
    if (u == null) return 'No account found with this email. Please sign up.';
    if (u['hash'] != _hash(password)) return 'Incorrect password.';
    _currentEmail = e;
    await _save();
    notifyListeners();
    return null;
  }

  Future<void> logOut() async {
    _currentEmail = null;
    await _save();
    notifyListeners();
  }
}

// ───────────────────── Gate ─────────────────────

/// Returns true if the user is logged in (opens the Sign up / Log in page if not).
Future<bool> requireLogin(BuildContext context) async {
  final a = AuthService.instance;
  await a.ensureLoaded();
  if (a.isLoggedIn) return true;
  if (!context.mounted) return false;
  final ok = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const AuthPage()),
  );
  return ok == true;
}

// ───────────────────── Auth page ─────────────────────

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _signUp = true, _hide = true, _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final a = AuthService.instance;
    final err = _signUp
        ? await a.signUp(_name.text, _email.text, _pass.text)
        : await a.logIn(_email.text, _pass.text);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _busy = false;
        _error = err;
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _navy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CircleAvatar(
                radius: 28,
                backgroundColor: _navy,
                child: Icon(Icons.account_balance, color: Colors.white)),
            const SizedBox(height: 16),
            Text(_signUp ? 'Create your account' : 'Welcome back',
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w700, color: _navy)),
            const SizedBox(height: 6),
            Text(
                _signUp
                    ? 'Sign up to plan your journey and save your preferences.'
                    : 'Log in to continue planning your journey.',
                style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: true, label: Text('Sign up')),
                  ButtonSegment(value: false, label: Text('Log in')),
                ],
                selected: {_signUp},
                onSelectionChanged: (s) => setState(() {
                  _signUp = s.first;
                  _error = null;
                }),
              ),
            ),
            const SizedBox(height: 20),
            if (_signUp) ...[
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: _dec('Full name', Icons.person_outline),
                validator: (v) =>
                    (v ?? '').trim().length >= 2 ? null : 'Enter your name',
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: _dec('Email', Icons.email_outlined),
              validator: (v) =>
                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim())
                      ? null
                      : 'Enter a valid email',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pass,
              obscureText: _hide,
              decoration: _dec('Password', Icons.lock_outline).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _hide = !_hide),
                ),
              ),
              validator: (v) =>
                  (v ?? '').length >= 6 ? null : 'At least 6 characters',
            ),
            if (_signUp) ...[
              const SizedBox(height: 12),
              TextFormField(
                obscureText: _hide,
                decoration: _dec('Confirm password', Icons.lock_outline),
                validator: (v) =>
                    v == _pass.text ? null : 'Passwords do not match',
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: _brown,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25))),
                onPressed: _busy ? null : _submit,
                child: Text(
                    _busy ? 'Please wait…' : (_signUp ? 'Create account' : 'Log in'),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => setState(() {
                  _signUp = !_signUp;
                  _error = null;
                }),
                child: Text(_signUp
                    ? 'Already have an account? Log in'
                    : 'New here? Create an account'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      );
}

// ───────────────── Optional: account tile for Profile page ─────────────────
// Usage inside ProfileScreen:  const AccountTile(),

class AccountTile extends StatefulWidget {
  const AccountTile({super.key});
  @override
  State<AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends State<AccountTile> {
  @override
  void initState() {
    super.initState();
    AuthService.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final a = AuthService.instance;
    return ListenableBuilder(
      listenable: a,
      builder: (context, _) {
        if (!a.isLoggedIn) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Icon(Icons.account_circle_outlined, color: _navy),
            title: Text(a.name.isEmpty ? 'My account' : a.name),
            subtitle: Text(a.email ?? ''),
            trailing: TextButton(
              onPressed: a.logOut,
              child: const Text('Log out'),
            ),
          ),
        );
      },
    );
  }
}
