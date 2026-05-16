import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/game_widgets.dart';
import '../services/supabase_service.dart';

class GameWordsScreen extends StatefulWidget {
  final String locationName;
  const GameWordsScreen({super.key, required this.locationName});
  @override
  State<GameWordsScreen> createState() => _GameWordsScreenState();
}

class _GameWordsScreenState extends State<GameWordsScreen> {
  List<Map<String, String>> _words = [];
  List<Map<String, String>> _roundWords = [];
  List<String> _options = [];
  int _current = 0;
  int _correct = 0;
  final int _total = 8;
  bool? _lastAnswer;
  bool _done = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAndInit();
  }

  Future<void> _loadAndInit() async {
    final data = await SupabaseService.getWords();
    if (!mounted) return;
    setState(() {
      _words = data.map((w) {
        return <String, String>{
          'kz': w['kz'] as String,
          'ru': w['ru'] as String,
          'image': 'assets/${w['image_path']}',
        };
      }).toList();
      _loading = false;
    });
    _initGame();
  }

  void _initGame() {
    if (_words.isEmpty) return;
    final rng = Random();
    _roundWords = List.from(_words)..shuffle(rng);
    _roundWords = _roundWords.take(_total).toList();
    _current = 0;
    _correct = 0;
    _lastAnswer = null;
    _done = false;
    _generateOptions();
  }

  void _generateOptions() {
    final rng = Random();
    final correctImage = _roundWords[_current]['image']!;
    final others = _words
        .where((w) => w['image'] != correctImage)
        .toList()
      ..shuffle(rng);
    _options = [correctImage, others[0]['image']!, others[1]['image']!, others[2]['image']!];
    _options.shuffle(rng);
  }

  void _answer(String image) {
    final isCorrect = image == _roundWords[_current]['image'];
    setState(() {
      _lastAnswer = isCorrect;
      if (isCorrect) _correct++;
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _lastAnswer = null;
        if (_current < _total - 1) {
          _current++;
          _generateOptions();
        } else {
          _done = true;
          _onComplete();
        }
      });
    });
  }

  void _onComplete() {
    final p = context.read<GameProvider>();
    int stars = _correct >= 7 ? 3 : _correct >= 5 ? 2 : 1;
    p.completeGame('words', stars * 10, _correct);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();
    if (_loading) {
      return Scaffold(body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF11998e), Color(0xFF38ef7d)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      ));
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(child: Column(children: [
          _header(p),
          _progress(),
          if (!_done) Expanded(child: SingleChildScrollView(child: Column(children: [
            const SizedBox(height: 8),
            _question(p),
            const SizedBox(height: 24),
            _optionsGrid(),
            const SizedBox(height: 12),
            if (_lastAnswer != null) _feedback(p),
            const SizedBox(height: 20),
          ]))),
          if (_done) _complete(p),
        ])),
      ),
    );
  }

  Widget _header(GameProvider p) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(p.t('📝 Қазақ сөздері', '📝 Казахские слова'),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white))),
      BotakoinCounter(count: p.profile.botakoins, fontSize: 14),
    ]),
  );

  Widget _progress() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('${_current + 1}/$_total', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
        Text('✅ $_correct', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: (_current + 1) / _total,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          valueColor: const AlwaysStoppedAnimation(Colors.white),
          minHeight: 8,
        ),
      ),
    ]),
  );

  Widget _question(GameProvider p) {
    final word = _roundWords[_current];
    return Column(children: [
      KambotAvatar(
        size: 80,
        showSpeechBubble: true,
        speechText: p.t('Бұл сөзге сурет тап!', 'Найди картинку к слову!'),
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Text(word['kz']!, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        ]),
      ),
    ]);
  }

  Widget _optionsGrid() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Wrap(
      spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
      children: _options.map((image) {
        final isCorrect = image == _roundWords[_current]['image'];
        final showResult = _lastAnswer != null;
        Color borderColor = Colors.white;
        if (showResult && isCorrect) borderColor = AppColors.success;

        return GestureDetector(
          onTap: _lastAnswer == null ? () => _answer(image) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 80, height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
                width: showResult && isCorrect ? 3 : 2,
              ),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(image, fit: BoxFit.cover),
            ),
          ),
        );
      }).toList(),
    ),
  );

  Widget _feedback(GameProvider p) => AnimatedOpacity(
    opacity: _lastAnswer != null ? 1 : 0,
    duration: const Duration(milliseconds: 300),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: _lastAnswer == true ? AppColors.success : AppColors.error,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _lastAnswer == true ? p.t('Дұрыс! ✅', 'Правильно! ✅') : p.t('Қате! ❌', 'Неправильно! ❌'),
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
  );

  Widget _complete(GameProvider p) {
    int stars = _correct >= 7 ? 3 : _correct >= 5 ? 2 : 1;
    int earned = 5 + (_correct * 2) + (stars == 3 ? 5 : 0);
    return Expanded(child: Center(child: Container(
      margin: const EdgeInsets.all(24), padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(p.t('Жарайсың! 🎉', 'Молодец! 🎉'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (j) =>
          Icon(j < stars ? Icons.star_rounded : Icons.star_border_rounded,
            color: j < stars ? AppColors.botakoin : Colors.grey.shade300, size: 36))),
        const SizedBox(height: 8),
        Text('$_correct/$_total ${p.t("дұрыс", "правильно")}',
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Text('+$earned 🪙', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: GameButton(text: p.t('Қайта', 'Снова'), onPressed: () => setState(() => _initGame()),
            color: AppColors.secondary, height: 44, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: GameButton(text: p.t('Картаға', 'На карту'), onPressed: () => Navigator.pop(context),
            color: AppColors.primary, height: 44, fontSize: 14)),
        ]),
      ]),
    )));
  }
}
