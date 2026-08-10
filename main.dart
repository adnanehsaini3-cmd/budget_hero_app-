import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BudgetHeroApp());
}

class BudgetHeroApp extends StatefulWidget {
  const BudgetHeroApp({super.key});

  @override
  State<BudgetHeroApp> createState() => _BudgetHeroAppState();
}

class _BudgetHeroAppState extends State<BudgetHeroApp> {
  String _selectedLang = 'en';
  String _selectedCurrency = 'USD';
  double _dailyLimit = 100.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLang = prefs.getString('lang') ?? 'en';
      _selectedCurrency = prefs.getString('currency') ?? 'USD';
      _dailyLimit = prefs.getDouble('dailyLimit') ?? 100.0;
    });
  }

  void _updateSettings(String lang, String currency, double limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', lang);
    await prefs.setString('currency', currency);
    await prefs.setDouble('dailyLimit', limit);
    setState(() {
      _selectedLang = lang;
      _selectedCurrency = currency;
      _dailyLimit = limit;
    });
  }

  bool _isRTL(String lang) {
    return lang == 'ar' || lang == 'dar';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isRTL(_selectedLang) ? TextDirection.rtl : TextDirection.ltr,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Budget Hero',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F0C20),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C5CE7),
            brightness: Brightness.dark,
          ),
        ),
        home: HomeScreen(
          currentLang: _selectedLang,
          currentCurrency: _selectedCurrency,
          dailyLimit: _dailyLimit,
          onSettingsChanged: _updateSettings,
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String currentLang;
  final String currentCurrency;
  final double dailyLimit;
  final Function(String, String, double) onSettingsChanged;

  const HomeScreen({
    super.key,
    required this.currentLang,
    required this.currentCurrency,
    required this.dailyLimit,
    required this.onSettingsChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _todaySpent = 0.0;
  double _lastAdded = 0.0;
  int _xp = 0;
  int _streak = 1;

  final Map<String, List<String>> _languagesOrdered = {
    'en': ['English', '🇬🇧'],
    'dar': ['الدارجة المغربية', '🇲🇦'],
    'ar': ['العربية', '🇸🇦'],
    'fr': ['Français', '🇫🇷'],
    'es': ['Español', '🇪🇸'],
    'de': ['Deutsch', '🇩🇪'],
    'it': ['Italiano', '🇮🇹'],
    'pt': ['Português', '🇵🇹'],
    'nl': ['Nederlands', '🇳🇱'],
    'pl': ['Polski', '🇵🇱'],
    'cs': ['Čeština', '🇨🇿'],
    'sv': ['Svenska', '🇸🇪'],
    'da': ['Dansk', '🇩🇰'],
    'ru': ['Русский', '🇷🇺'],
    'zh': ['中文', '🇨🇳'],
    'ja': ['日本語', '🇯🇵'],
    'ko': ['한국어', '🇰🇷'],
    'tr': ['Türkçe', '🇹🇷'],
    'vi': ['Tiếng Việt', '🇻🇳'],
    'id': ['Bahasa Indonesia', '🇮🇩'],
    'hi': ['हिन्दी', '🇮🇳'],
  };

  final List<String> _currenciesOrdered = [
    'USD', 'MAD', 'EUR', 'GBP', 'SAR', 'AED', 
    'BRL', 'MXN', 'PLN', 'CZK', 'SEK', 'DKK', 
    'RUB', 'TRY', 'CNY', 'JPY', 'KRW', 'VND', 'IDR', 'INR'
  ];

  final Map<String, Map<String, String>> _translations = {
    'en': {
      'title': 'Budget Hero',
      'spent_today': 'Spent Today',
      'limit': 'Daily Limit',
      'remaining': 'Remaining',
      'quick_add': 'Quick Add',
      'custom': 'Custom',
      'undo': 'Expense added',
      'undo_btn': 'UNDO',
      'reset': 'Reset Day',
      'reset_confirm': 'Are you sure you want to reset today\'s expenses?',
      'settings': 'Settings',
      'level': 'Level',
      'xp': 'XP',
      'streak': 'Day Streak',
      'badges': 'Achievements',
      'badge_1': 'Saving Rookie',
      'badge_2': 'Budget Master',
      'badge_3': 'Streak Legend',
      'save': 'Save',
      'cancel': 'Cancel',
    },
    'dar': {
      'title': 'Budget Hero',
      'spent_today': 'صرفت اليوم',
      'limit': 'الحد اليومي',
      'remaining': 'اللي بقى ليك',
      'quick_add': 'إضافة سريعة',
      'custom': 'مبلغ آخر',
      'undo': 'تزاد المصروف',
      'undo_btn': 'تراجع',
      'reset': 'مسح النهار',
      'reset_confirm': 'واش متأكد بغيتي تمسح مصاريف اليوم؟',
      'settings': 'الإعدادات',
      'level': 'المستوى',
      'xp': 'النقاط',
      'streak': 'أيام متتالية',
      'badges': 'الأوسمة',
      'badge_1': 'مبتدئ التوفير',
      'badge_2': 'بطل الميزانية',
      'badge_3': 'أسطورة الالتزام',
      'save': 'حفظ',
      'cancel': 'إلغاء',
    },
    'ar': {
      'title': 'Budget Hero',
      'spent_today': 'المصروف اليومي',
      'limit': 'الحد اليومي',
      'remaining': 'المتبقي',
      'quick_add': 'إضافة سريعة',
      'custom': 'مبلغ مخصص',
      'undo': 'تمت إضافة المصروف',
      'undo_btn': 'تراجع',
      'reset': 'إعادة ضبط',
      'reset_confirm': 'هل أنت تأكد من مسح مصاريف اليوم؟',
      'settings': 'الإعدادات',
      'level': 'المستوى',
      'xp': 'نقاط',
      'streak': 'أيام متتالية',
      'badges': 'الإنجازات',
      'badge_1': 'مبتدئ التوفير',
      'badge_2': 'خبير الميزانية',
      'badge_3': 'أسطورة الالتزام',
      'save': 'حفظ',
      'cancel': 'إلغاء',
    },
  };

  String _t(String key) {
    return _translations[widget.currentLang]?[key] ?? _translations['en']![key]!;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _todaySpent = prefs.getDouble('todaySpent') ?? 0.0;
      _xp = prefs.getInt('xp') ?? 50;
      _streak = prefs.getInt('streak') ?? 1;
    });
  }

  void _addExpense(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastAdded = amount;
      _todaySpent += amount;
      _xp += 10;
    });
    await prefs.setDouble('todaySpent', _todaySpent);
    await prefs.setInt('xp', _xp);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_t('undo')}: +$amount ${widget.currentCurrency}'),
          action: SnackBarAction(
            label: _t('undo_btn'),
            onPressed: _undoExpense,
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _undoExpense() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _todaySpent = (_todaySpent - _lastAdded).clamp(0.0, double.infinity);
      _xp = (_xp - 10).clamp(0, 999999);
      _lastAdded = 0.0;
    });
    await prefs.setDouble('todaySpent', _todaySpent);
    await prefs.setInt('xp', _xp);
  }

  void _resetDay() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _todaySpent = 0.0;
    });
    await prefs.setDouble('todaySpent', 0.0);
  }

  int get _userLevel => (_xp / 100).floor() + 1;

  @override
  Widget build(BuildContext context) {
    final double remaining = widget.dailyLimit - _todaySpent;
    final double progress = (_todaySpent / widget.dailyLimit).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(_t('reset')),
                  content: Text(_t('reset_confirm')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(_t('cancel')),
                    ),
                    TextButton(
                      onPressed: () {
                        _resetDay();
                        Navigator.pop(ctx);
                      },
                      child: Text(_t('reset'), style: const TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            onPressed: () => _showSettingsModal(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF6C5CE7),
                        radius: 18,
                        child: Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAlignment.start,
                        children: [
                          Text('${_t('level')} $_userLevel', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('$_xp ${_t('xp')}', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      Text('$_streak ${_t('streak')}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: remaining >= 0 
                      ? [const Color(0xFF2A265F), const Color(0xFF1D1942)]
                      : [const Color(0xFF5F262A), const Color(0xFF42191B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(_t('spent_today'), style: const TextStyle(color: Colors.white60, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    '${_todaySpent.toStringAsFixed(1)} ${widget.currentCurrency}',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.white10,
                      color: remaining >= 0 ? const Color(0xFF00FFA3) : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_t('limit')}: ${widget.dailyLimit} ${widget.currentCurrency}', style: const TextStyle(color: Colors.white60, fontSize: 13)),
                      Text(
                        '${_t('remaining')}: ${remaining.toStringAsFixed(1)} ${widget.currentCurrency}',
                        style: TextStyle(
                          color: remaining >= 0 ? const Color(0xFF00FFA3) : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(_t('quick_add'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickBtn('+10'),
                _buildQuickBtn('+20'),
                _buildQuickBtn('+50'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _showCustomAmountDialog(context),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(_t('custom'), style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(_t('badges'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBadge('🛡️', _t('badge_1'), _userLevel >= 1),
                _buildBadge('👑', _t('badge_2'), _userLevel >= 3),
                _buildBadge('⚡', _t('badge_3'), _streak >= 7),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickBtn(String text) {
    final double value = double.parse(text.replaceAll('+', ''));
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.08),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white12),
        ),
      ),
      onPressed: () => _addExpense(value),
      child: Text(
        '$text ${widget.currentCurrency}',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildBadge(String emoji, String title, bool unlocked) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: unlocked ? const Color(0xFF6C5CE7).withOpacity(0.2) : Colors.white10,
            shape: BoxShape.circle,
            border: Border.all(color: unlocked ? const Color(0xFF6C5CE7) : Colors.white12),
          ),
          child: Text(emoji, style: TextStyle(fontSize: 28, color: unlocked ? Colors.white : Colors.white24)),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: unlocked ? Colors.white : Colors.white38),
        ),
      ],
    );
  }

  void _showCustomAmountDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t('custom')),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            suffixText: widget.currentCurrency,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(_t('cancel'))),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                _addExpense(val);
              }
              Navigator.pop(ctx);
            },
            child: Text(_t('save')),
          ),
        ],
      ),
    );
  }

  void _showSettingsModal(BuildContext context) {
    String tempLang = widget.currentLang;
    String tempCurr = widget.currentCurrency;
    double tempLimit = widget.dailyLimit;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF18152E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 24,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAlignment: CrossAlignment.start,
              children: [
                Text(_t('settings'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Language / اللغة', style: TextStyle(color: Colors.white60)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempLang,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white10,
                  ),
                  items: _languagesOrdered.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Text('${e.value[1]}  ${e.value[0]}'),
                    );
                  }).toList(),
                  onChanged: (v) => setModalState(() => tempLang = v!),
                ),
                const SizedBox(height: 16),
                const Text('Currency / العملة', style: TextStyle(color: Colors.white60)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempCurr,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white10,
                  ),
                  items: _currenciesOrdered.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    );
                  }                            
                    
