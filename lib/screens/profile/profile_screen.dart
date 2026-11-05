import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _age, _city, _budget;
  late int _people;
  late bool _children;
  late int _childrenCount;
  late String _visitorType;
  late String _time, _period;
  late Set<String> _interests;
  bool _saving = false;
  static const _times = ['2 Hours', '4 Hours', '6 Hours', '8 Hours'];
  static const _categories = ['History', 'Museums', 'Architecture', 'Culture', 'Adventure', 'Photography'];

  bool get ar => context.watch<UserProvider>().language == 'ar';
  String label(String en, String arabic) => ar ? arabic : en;

  @override
  void initState() {
    super.initState();
    final p = context.read<UserProvider>().prefs;
    _name = TextEditingController(text: p.name);
    _age = TextEditingController(text: p.age);
    _city = TextEditingController(text: p.location);
    _budget = TextEditingController(text: p.budget);
    _people = p.familyMembers.clamp(1, 20);
    _children = p.hasChildren;
    _childrenCount = _children ? p.childrenCount.clamp(1, _people) : 0;
    _visitorType = p.visitorType == 'international' ? 'international' : 'egyptian';
    _time = _times.contains(p.availableTime) ? p.availableTime : _times[1];
    _period = p.preferredPeriod == 'Evening' ? 'Evening' : 'Morning';
    _interests = p.interests.toSet();
  }

  @override
  void dispose() {
    _name.dispose(); _age.dispose(); _city.dispose(); _budget.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    await context.read<UserProvider>().savePreferences(UserPreferences(
      name: _name.text.trim(), age: _age.text.trim(),
      location: _city.text.trim(), budget: _budget.text.trim(),
      availableTime: _time, preferredPeriod: _period,
      familyMembers: _people, hasChildren: _children,
      childrenCount: _children ? _childrenCount : 0, visitorType: _visitorType,
      interests: _interests.toList(),
    ));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(label('Profile saved', 'تم حفظ الملف الشخصي'))));
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(label('Edit profile & settings', 'تعديل الملف والإعدادات'))),
      body: Form(key: _form, child: ListView(padding: const EdgeInsets.all(18), children: [
        CircleAvatar(radius: 35, child: Text(account.prefs.name.isNotEmpty ? account.prefs.name[0].toUpperCase() : 'E')),
        const SizedBox(height: 12),
        Center(child: Text(label('Your account', 'حسابك'), style: Theme.of(context).textTheme.headlineSmall)),
        const SizedBox(height: 20),
        TextFormField(controller: _name, decoration: InputDecoration(labelText: label('Name', 'الاسم')),
          validator: (v) => v == null || v.trim().isEmpty ? label('Enter name', 'اكتبي الاسم') : null),
        const SizedBox(height: 12),
        TextFormField(controller: _age, keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label('Age (optional)', 'السن (اختياري)')),
          validator: (v) => v != null && v.trim().isNotEmpty &&
            (int.tryParse(v.trim()) == null || int.parse(v.trim()) < 1 || int.parse(v.trim()) > 120)
                ? label('Enter a valid age', 'أدخلي سن صحيح') : null),
        const SizedBox(height: 12),
        TextFormField(controller: _city, decoration: InputDecoration(labelText: label('City or governorate', 'المدينة أو المحافظة'),
          helperText: label('Manual location only. No GPS access.', 'موقع يدوي فقط بدون GPS')),
          validator: (v) => v == null || v.trim().isEmpty ? label('Enter location', 'اكتبي المحافظة') : null),
        const SizedBox(height: 12),
        TextFormField(controller: _budget, keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label('Budget (EGP)', 'الميزانية بالجنيه')),
          validator: (v) { final number = double.tryParse(v?.trim() ?? '');
            return number == null || !number.isFinite || number <= 0 ? label('Enter a valid budget', 'أدخلي ميزانية صحيحة') : null; }),
        const SizedBox(height: 16),
        Row(children: [Expanded(child: Text(label('Family members', 'عدد الأفراد'))),
          IconButton(onPressed: _people > 1 ? () => setState(() { _people--; if (_childrenCount > _people) _childrenCount = _people; }) : null, icon: const Icon(Icons.remove_circle_outline)),
          Text('$_people'),
          IconButton(onPressed: _people < 20 ? () => setState(() => _people++) : null, icon: const Icon(Icons.add_circle_outline))]),
        SwitchListTile.adaptive(title: Text(label('Traveling with children', 'مع أطفال')),
          value: _children, onChanged: (v) => setState(() { _children = v; _childrenCount = v ? 1 : 0; })),
        if (_children) Row(children: [
          Expanded(child: Text(label('Children count', 'عدد الأطفال'))),
          IconButton(onPressed: _childrenCount > 1 ? () => setState(() => _childrenCount--) : null, icon: const Icon(Icons.remove_circle_outline)),
          Text('$_childrenCount'),
          IconButton(onPressed: _childrenCount < _people ? () => setState(() => _childrenCount++) : null, icon: const Icon(Icons.add_circle_outline)),
        ]),
        DropdownButtonFormField<String>(initialValue: _visitorType,
          decoration: InputDecoration(labelText: label('Ticket category', 'فئة تذاكر الدخول')),
          items: const [DropdownMenuItem(value: 'egyptian', child: Text('Egyptian')),
            DropdownMenuItem(value: 'international', child: Text('International'))],
          onChanged: (v) => setState(() => _visitorType = v ?? _visitorType)),
        DropdownButtonFormField<String>(initialValue: _time,
          decoration: InputDecoration(labelText: label('Available time', 'الوقت المتاح')),
          items: _times.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => setState(() => _time = v ?? _time)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(initialValue: _period,
          decoration: InputDecoration(labelText: label('Preferred period', 'الفترة المفضلة')),
          items: const [DropdownMenuItem(value: 'Morning', child: Text('Morning')),
            DropdownMenuItem(value: 'Evening', child: Text('Evening'))],
          onChanged: (v) => setState(() => _period = v ?? _period)),
        const SizedBox(height: 15),
        Text(label('Interests', 'الاهتمامات')),
        Wrap(spacing: 8, children: _categories.map((c) => FilterChip(
          label: Text(c), selected: _interests.contains(c), onSelected: (v) => setState(() {
            if (v) { _interests.add(c); } else { _interests.remove(c); }
          }))).toList()),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.save),
          label: Text(label('Save changes', 'حفظ التعديلات'))),
        const Divider(height: 36),
        Text(label('Settings', 'الإعدادات'), style: Theme.of(context).textTheme.titleLarge),
        SwitchListTile.adaptive(title: Text(label('Notifications preference', 'إعداد الإشعارات')),
          subtitle: Text(label('Save your preference. Push notifications are not connected yet.',
            'يتم حفظ الاختيار، وإشعارات الهاتف غير مفعلة بعد.')),
          value: account.notificationsEnabled,
          onChanged: (v) => account.setNotifications(v)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(value: account.language,
          decoration: InputDecoration(labelText: label('Language', 'اللغة')),
          items: const [DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'ar', child: Text('العربية'))],
          onChanged: (v) { if (v != null) account.setLanguage(v); }),
        const Divider(height: 36),
        ListTile(leading: const Icon(Icons.card_membership), title: Text(label('Subscription & trial', 'الاشتراك والتجربة')),
          subtitle: Text(account.hasAccess
            ? label('${account.trialDaysRemaining} trial days remaining (preview)', 'متبقي ${account.trialDaysRemaining} أيام تجريبية (نسخة تجريبية)')
            : label('Trial expired (preview)', 'انتهت الفترة التجريبية (نسخة تجريبية)')),
          onTap: () => Navigator.pushNamed(context, '/subscriptions')),
      ])),
    );
  }
}
