import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/game_widgets.dart';

class GameMathScreen extends StatefulWidget {
  final String locationName;
  const GameMathScreen({super.key, required this.locationName});
  @override
  State<GameMathScreen> createState() => _GameMathScreenState();
}

class _GameMathScreenState extends State<GameMathScreen> {
  final rng = Random();
  int _current = 0, _correct = 0; final int _total = 10;
  late int _a, _b, _answer;
  late String _op;
  List<int> _options = [];
  bool? _lastAnswer;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    _lastAnswer = null;
    final ops = ['+', '-', '×'];
    _op = ops[rng.nextInt(ops.length)];
    switch (_op) {
      case '+':
        _a = rng.nextInt(20) + 1;
        _b = rng.nextInt(20) + 1;
        _answer = _a + _b;
        break;
      case '-':
        _a = rng.nextInt(20) + 10;
        _b = rng.nextInt(_a) + 1;
        _answer = _a - _b;
        break;
      case '×':
        _a = rng.nextInt(9) + 2;
        _b = rng.nextInt(9) + 2;
        _answer = _a * _b;
        break;
    }
    _options = [_answer];
    while (_options.length < 4) {
      int fake = _answer + rng.nextInt(11) - 5;
      if (fake != _answer && fake >= 0 && !_options.contains(fake)) {
        _options.add(fake);
      }
    }
    _options.shuffle(rng);
  }

  void _onAnswer(int ans) {
    bool isCorrect = ans == _answer;
    setState(() {
      _lastAnswer = isCorrect;
      if (isCorrect) _correct++;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        if (_current < _total - 1) {
          _current++;
          _generateQuestion();
        } else {
          _done = true;
          _onComplete();
        }
      });
    });
  }

  void _onComplete() {
    final p = context.read<GameProvider>();
    int stars = _correct >= 9 ? 3 : _correct >= 6 ? 2 : 1;
    p.completeGame('math', stars * 10, _correct);
  }

  void _restart() {
    setState(() {
      _current = _correct = 0;
      _done = false;
      _generateQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();
    return Scaffold(body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
        colors: [Color(0xFFf857a6), Color(0xFFff5858)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      )),
      child: SafeArea(child: Column(children: [
        _header(p), _progress(),
        if (!_done) Expanded(child: SingleChildScrollView(child: Column(children: [
          const SizedBox(height: 16),
          _question(p),
          const SizedBox(height: 24),
          _optionsWidget(),
          const SizedBox(height: 12),
          if (_lastAnswer != null) _feedback(p),
          const SizedBox(height: 20),
        ]))),
        if (_done) _complete(p),
      ])),
    ));
  }

  Widget _header(GameProvider p) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(p.t('🔢 Бота санайды', '🔢 Считай с Ботой'),
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
      ClipRRect(borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(value: (_current + 1) / _total,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          valueColor: const AlwaysStoppedAnimation(Colors.white), minHeight: 8)),
    ]),
  );

  Widget _question(GameProvider p) => Column(children: [
    const KambotAvatar(size: 70),
    const SizedBox(height: 16),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _candyGroup(_a),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(_op, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white))),
        _candyGroup(_b),
      ]),
    ),
    const SizedBox(height: 16),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12)]),
      child: Text('$_a $_op $_b = ?',
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
    ),
  ]);

  Widget _candyGroup(int count) {
    int show = count > 10 ? 10 : count;
    return Wrap(spacing: 2, runSpacing: 2,
      children: List.generate(show, (idx) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset('assets/candies/candy${idx % 5}.jpeg', width: 18, height: 18, fit: BoxFit.cover),
      )));
  }

  Widget _optionsWidget() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
      children: _options.map((opt) {
        Color bg = Colors.white;
        if (_lastAnswer != null && opt == _answer) bg = AppColors.success.withValues(alpha: 0.3);
        return GestureDetector(
          onTap: _lastAnswer == null ? () => _onAnswer(opt) : null,
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            width: 76, height: 76,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))]),
            child: Center(child: Text('$opt', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)))),
        );
      }).toList()),
  );

  Widget _feedback(GameProvider p) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 40),
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    decoration: BoxDecoration(
      color: _lastAnswer == true ? AppColors.success : AppColors.error,
      borderRadius: BorderRadius.circular(16)),
    child: Text(
      _lastAnswer == true ? p.t('Дұрыс! ✅', 'Правильно! ✅') : p.t('Қате! Жауабы: $_answer', 'Неправильно! Ответ: $_answer'),
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
  );

  Widget _complete(GameProvider p) {
    int stars = _correct >= 9 ? 3 : _correct >= 6 ? 2 : 1;
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
        Text('+$earned', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: GameButton(text: p.t('Қайта', 'Снова'), onPressed: _restart,
            color: AppColors.secondary, height: 44, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: GameButton(text: p.t('Картаға', 'На карту'), onPressed: () => Navigator.pop(context),
            color: AppColors.primary, height: 44, fontSize: 14)),
        ]),
      ]),
    )));
  }
}
