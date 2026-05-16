import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/game_widgets.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});
  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  bool _authenticated = false;
  final _pinController = TextEditingController();
  final _apiKeyController = TextEditingController();
  String _pinError = '';

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  void _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('gemini_api_key') ?? 'AIzaSyCgRDbyjoc3h2oDON3k1UJXhagOYM1hpyI';
    setState(() {
      _apiKeyController.text = key;
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _checkPin(GameProvider p) {
    if (p.verifyParentPin(_pinController.text)) {
      setState(() { _authenticated = true; _pinError = ''; });
      p.enterParentMode();
    } else {
      setState(() => _pinError = p.t('Қате PIN', 'Неверный PIN'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          colors: [AppColors.bgDark, AppColors.bgDarkMid],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        )),
        child: SafeArea(child: _authenticated ? _dashboard(p) : _pinScreen(p)),
      ),
    );
  }

  Widget _pinScreen(GameProvider p) => SingleChildScrollView(child: Column(children: [
    _header(p),
    const SizedBox(height: 40),
    const Icon(Icons.lock_rounded, size: 64, color: AppColors.textOnDarkSecondary),
    const SizedBox(height: 16),
    Text(p.t('Ата-ана бөлімі', 'Раздел для родителей'),
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textOnDark)),
    const SizedBox(height: 8),
    Text(p.t('PIN-кодты енгізіңіз', 'Введите PIN-код'),
      style: const TextStyle(fontSize: 14, color: AppColors.textOnDarkSecondary)),
    const SizedBox(height: 4),
    Text(p.t('(Әдепкі: 1234)', '(По умолчанию: 1234)'),
      style: TextStyle(fontSize: 12, color: AppColors.textOnDarkSecondary.withValues(alpha: 0.6))),
    const SizedBox(height: 24),
    Container(
      width: 200,
      decoration: BoxDecoration(color: AppColors.glassBg, border: Border.all(color: AppColors.glassBorder), borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)]),
      child: TextField(
        controller: _pinController,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        obscureText: true,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 12),
        decoration: InputDecoration(
          hintText: '••••',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.all(16),
        ),
        maxLength: 4,
        onSubmitted: (_) => _checkPin(p),
      ),
    ),
    if (_pinError.isNotEmpty) Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(_pinError, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
    ),
    const SizedBox(height: 24),
    GameButton(text: p.t('Кіру', 'Войти'), onPressed: () => _checkPin(p),
      color: AppColors.accentBlue, width: 200, height: 48),
    const SizedBox(height: 40),
  ]));

  Widget _dashboard(GameProvider p) => Column(children: [
    _header(p),
    Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
      _profileCard(p),
      const SizedBox(height: 12),
      _statsCard(p),
      const SizedBox(height: 12),
      _screenTimeCard(p),
      const SizedBox(height: 12),
      _achievementsCard(p),
      const SizedBox(height: 12),
      _apiKeyCard(p),
      const SizedBox(height: 20),
      Center(child: GameButton(
        text: p.t('Прогрессті тазалау', 'Сбросить прогресс'),
        onPressed: () => _confirmReset(p),
        color: AppColors.error, width: 220, height: 44, fontSize: 14)),
    ])),
  ]);

  Widget _header(GameProvider p) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(children: [
      GestureDetector(
        onTap: () { p.exitParentMode(); Navigator.pop(context); },
        child: Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.glassBg, border: Border.all(color: AppColors.glassBorder), borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
          child: const Icon(Icons.arrow_back_rounded, color: AppColors.textOnDark)),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(p.t('Ата-ана', 'Родитель'),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textOnDark))),
      GestureDetector(
        onTap: () => p.toggleLanguage(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.glassBg, border: Border.all(color: AppColors.glassBorder), borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
          child: Text(p.isRussian ? 'Қаз' : 'Рус', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
      ),
    ]),
  );

  Widget _profileCard(GameProvider p) => GlassCard(
    child: Row(children: [
      Container(width: 56, height: 56,
        decoration: BoxDecoration(shape: BoxShape.circle,
          gradient: AppColors.primaryGradient),
        child: ClipOval(child: Image.asset('assets/cumbot/glad.png', width: 28, height: 28, fit: BoxFit.cover))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.profile.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textOnDark)),
        Text('${p.t("Жас", "Возраст")}: ${p.profile.age}',
          style: const TextStyle(fontSize: 13, color: AppColors.textOnDarkSecondary)),
        Text('${p.t("Деңгей", "Уровень")}: ${p.profile.level} - ${p.profile.levelTitle}',
          style: const TextStyle(fontSize: 13, color: AppColors.textOnDarkSecondary)),
      ])),
      BotakoinCounter(count: p.profile.botakoins, fontSize: 14),
    ]),
  );

  Widget _statsCard(GameProvider p) => GlassCard(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(p.t('Статистика', 'Статистика'),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textOnDark)),
      const SizedBox(height: 12),
      _statRow(p.t('Ойындар ойналды', 'Игр сыграно'), '${p.profile.totalGamesPlayed}', ''),
      _statRow(p.t('Дұрыс жауаптар', 'Правильных ответов'), '${p.profile.totalCorrectAnswers}', ''),
      _statRow(p.t('Жетістіктер', 'Достижений'), '${p.profile.achievements.length}/${GameProvider.achievementDefs.length}', ''),
      _statRow(p.t('Ашылған локациялар', 'Открыто локаций'), '${p.profile.unlockedLocations.length}/5', ''),
      _statRow(p.t('Есептер шығарылды', 'Задач решено'), '${p.profile.mathProblemsSolved}', ''),
      _statRow(p.t('Викториналар өтілді', 'Викторин пройдено'), '${p.profile.quizQuestionsAnswered}', ''),
      _statRow(p.t('Жұптар табылды', 'Пар найдено'), '${p.profile.memoryPairsFound}', ''),
      _statRow(p.t('Юрталар құрастырылды', 'Юрт построено'), '${p.profile.yurtsBuilt}', ''),
      _statRow(p.t('Купондар алынды', 'Купонов получено'), '${p.profile.couponsRedeemed}', ''),
      _statRow(p.t('Күн қатары', 'Серия дней'), '${p.profile.currentStreak} ${_streakLabel(p.profile.currentStreak, p)}', ''),
      const SizedBox(height: 8),
      ProgressIndicatorBar(
        progress: p.profile.progressToNextLevel,
        label: p.t('Келесі деңгейге дейін', 'До следующего уровня'),
        color: AppColors.primary),
    ],
  ));

  Widget _screenTimeCard(GameProvider p) => GlassCard(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(p.t('Экран уақыты', 'Экранное время'),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textOnDark)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(p.t('Бүгін қолданылды', 'Использовано сегодня'),
          style: const TextStyle(fontSize: 13, color: AppColors.textOnDarkSecondary)),
        Text('${p.profile.dailyMinutesUsed} ${p.t("мин", "мин")}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textOnDark)),
      ]),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(p.t('Күндік лимит', 'Дневной лимит'),
          style: const TextStyle(fontSize: 13, color: AppColors.textOnDarkSecondary)),
        Text('${p.profile.screenTimeLimit} ${p.t("мин", "мин")}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textOnDark)),
      ]),
      const SizedBox(height: 12),
      Text(p.t('Соңғы 7 күн:', 'Последние 7 дней:'),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textOnDark)),
      const SizedBox(height: 8),
      _weeklyHistory(p),
      const SizedBox(height: 12),
      Text(p.t('Лимитті өзгерту:', 'Изменить лимит:'),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textOnDark)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [15, 30, 45, 60].map((m) => GestureDetector(
        onTap: () => p.setScreenTimeLimit(m),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: p.profile.screenTimeLimit == m ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12)),
          child: Text('$m ${p.t("мин", "мин")}',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
              color: p.profile.screenTimeLimit == m ? Colors.white : AppColors.textOnDarkSecondary)),
        ),
      )).toList()),
    ],
  ));

  Widget _achievementsCard(GameProvider p) => GlassCard(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(p.t('Жетістіктер', 'Достижения'),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textOnDark)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: GameProvider.achievementDefs.entries.map((e) {
        final unlocked = p.profile.achievements.contains(e.key);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: unlocked ? AppColors.primary.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: unlocked ? AppColors.primary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(p.isRussian ? e.value['nameRu']! : e.value['nameKz']!,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: unlocked ? Colors.white : Colors.white38)),
          ),
        );
      }).toList()),
    ],
  ));

  Widget _statRow(String label, String value, String emoji) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textOnDarkSecondary))),
      Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textOnDark)),
    ]),
  );

  Widget _weeklyHistory(GameProvider p) {
    final now = DateTime.now();
    final days = <Map<String, dynamic>>[];
    for (var i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final iso = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final minutes = p.profile.dailyMinutes[iso] ?? 0;
      days.add({'label': _dayLabel(d.weekday, p), 'minutes': minutes});
    }
    final maxMinutes = days.fold<int>(0, (m, day) {
      final v = day['minutes'] as int;
      return v > m ? v : m;
    });
    final scale = maxMinutes < p.profile.screenTimeLimit ? p.profile.screenTimeLimit : maxMinutes;
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: days.map((day) {
          final minutes = day['minutes'] as int;
          final ratio = scale > 0 ? (minutes / scale).clamp(0.0, 1.0) : 0.0;
          final overLimit = minutes >= p.profile.screenTimeLimit && minutes > 0;
          return Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('$minutes',
                style: const TextStyle(fontSize: 9, color: AppColors.textOnDarkSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Container(
                height: 48 * ratio,
                decoration: BoxDecoration(
                  gradient: overLimit
                    ? const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        begin: Alignment.bottomCenter, end: Alignment.topCenter)
                    : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text(day['label'] as String,
                style: const TextStyle(fontSize: 10, color: AppColors.textOnDarkSecondary)),
            ]),
          ));
        }).toList(),
      ),
    );
  }

  /// Kazakh doesn't inflect for number; Russian has 3 plural forms.
  String _streakLabel(int n, GameProvider p) {
    if (!p.isRussian) return 'күн';
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return 'день';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'дня';
    return 'дней';
  }

  String _dayLabel(int weekday, GameProvider p) {
    const ru = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    const kz = ['Дс', 'Сс', 'Ср', 'Бс', 'Жм', 'Сб', 'Жс'];
    final idx = (weekday - 1).clamp(0, 6);
    return p.isRussian ? ru[idx] : kz[idx];
  }

  Widget _apiKeyCard(GameProvider p) => GlassCard(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(p.t('Gemini API Кілті', 'Ключ Gemini API'),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textOnDark)),
      const SizedBox(height: 8),
      Text(p.t('Чат жұмыс істеуі үшін ключ қажет', 'Ключ необходим для работы чата'),
        style: const TextStyle(fontSize: 12, color: AppColors.textOnDarkSecondary)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: Container(
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
          child: TextField(
            controller: _apiKeyController,
            style: const TextStyle(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'AIzaSy...',
              hintStyle: const TextStyle(color: Colors.white24),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        )),
        const SizedBox(width: 8),
        GameButton(
          text: p.t('Сақтау', 'Сохранить'),
          onPressed: () => _saveApiKey(p),
          color: AppColors.primary, width: 90, height: 36, fontSize: 12),
      ]),
    ],
  ));

  void _saveApiKey(GameProvider p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', _apiKeyController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(p.t('Кілті сақталды', 'Ключ сохранен!'))),
      );
    }
  }



  void _confirmReset(GameProvider p) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(p.t('⚠️ Прогрессті тазалау', '⚠️ Сбросить прогресс')),
      content: Text(p.t(
        'Барлық деректер жойылады. Сенімдісіз бе?',
        'Все данные будут удалены. Вы уверены?')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: Text(p.t('Жоқ', 'Нет'))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () {
            p.resetProgress();
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: Text(p.t('Иә', 'Да'), style: const TextStyle(color: Colors.white))),
      ],
    ));
  }
}
